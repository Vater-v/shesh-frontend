import uuid
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_, delete
from fastapi import HTTPException, status
from datetime import datetime, timedelta, timezone

from . import models, schemas, security, config

class AuthService:
    def __init__(self, db: AsyncSession):
        self.db = db

    # --- Utils ---
    def mock_email(self, to: str, subject: str, body: str):
        # In production, replace with actual email sending logic
        print(f"\n[MOCK EMAIL] To: {to} | Subject: {subject}")
        print(f"Body: {body}\n")

    async def get_user_by_uuid(self, uuid: str) -> models.User | None:
        return await self.db.get(models.User, uuid)

    # --- Core Auth ---
    async def register_user(self, payload: schemas.UserRegister) -> schemas.Token:
        # 1. Dynamic Check for existing users based on provided fields
        conditions = []
        if payload.email:
            conditions.append(models.User.email == payload.email)
        if payload.login:
            conditions.append(models.User.login == payload.login)
        
        # We use OR because if either matches, we have a conflict
        if conditions:
            stmt = select(models.User).where(or_(*conditions))
            result = await self.db.execute(stmt)
            existing_user = result.scalar_one_or_none()
            
            if existing_user:
                # Provide specific error messages for UX
                if payload.email and existing_user.email == payload.email:
                    raise HTTPException(status_code=409, detail="Email is already taken")
                if payload.login and existing_user.login == payload.login:
                    raise HTTPException(status_code=409, detail="Login is already taken")
                raise HTTPException(status_code=409, detail="User already exists")
        
        # 2. Determine Verification Status
        # - Email provided: Require verification (is_verified = False)
        # - Login only: Immediate activation (is_verified = True)
        is_verified = True
        verification_token = None
        
        if payload.email:
            is_verified = False
            # Generate a secure random string for the DB token
            verification_token = str(uuid.uuid4())

        # 3. Create User
        new_user = models.User(
            login=payload.login,
            email=payload.email,
            password_hash=security.get_password_hash(payload.password),
            is_verified=is_verified,
            verification_token=verification_token
        )
        
        self.db.add(new_user)
        await self.db.commit()
        await self.db.refresh(new_user)

        # 4. Trigger Email Flow if needed
        if payload.email and verification_token:
            self.mock_email(payload.email, "Verify Account", f"Token: {verification_token}")

        # 5. Return Session (Auto-login)
        return await self.create_session(new_user)

    async def login_user(self, payload: schemas.UserLogin, user_agent: str) -> schemas.Token:
        # Search against BOTH login and email columns
        stmt = select(models.User).where(
            or_(
                models.User.email == payload.credential,
                models.User.login == payload.credential
            )
        )
        result = await self.db.execute(stmt)
        user = result.scalar_one_or_none()
        
        if not user or not security.verify_password(payload.password, user.password_hash):
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        return await self.create_session(user, user_agent)

    async def create_session(self, user: models.User, user_agent: str = "Unknown") -> schemas.Token:
        access_token = security.create_access_token(user.uuid)
        refresh_token = security.create_refresh_token(user.uuid)
        
        expires_at = datetime.now(timezone.utc) + timedelta(days=config.settings.REFRESH_TOKEN_EXPIRE_DAYS)
        
        session_record = models.Session(
            user_uuid=user.uuid,
            refresh_token_hash=security.hash_token(refresh_token),
            user_agent=user_agent,
            expires_at=expires_at.replace(tzinfo=None)
        )
        self.db.add(session_record)
        await self.db.commit()
        
        return schemas.Token(access_token=access_token, refresh_token=refresh_token)

    async def refresh_token(self, token: str, user_agent: str) -> schemas.Token:
        payload = security.decode_token(token)
        if not payload or payload.get("type") != "refresh":
            raise HTTPException(status_code=401, detail="Invalid token")
        
        user_uuid = payload["sub"]
        token_hash = security.hash_token(token)
        
        result = await self.db.execute(select(models.Session).where(
            models.Session.refresh_token_hash == token_hash
        ))
        session_record = result.scalar_one_or_none()
        
        if not session_record:
            raise HTTPException(status_code=401, detail="Session invalid or revoked")
        
        if session_record.expires_at < datetime.utcnow():
            await self.db.delete(session_record)
            await self.db.commit()
            raise HTTPException(status_code=401, detail="Session expired")

        await self.db.delete(session_record)
        
        user = await self.get_user_by_uuid(user_uuid)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
            
        return await self.create_session(user, user_agent)

    async def logout(self, token: str):
        token_hash = security.hash_token(token)
        result = await self.db.execute(select(models.Session).where(
            models.Session.refresh_token_hash == token_hash
        ))
        session_record = result.scalar_one_or_none()
        if session_record:
            await self.db.delete(session_record)
            await self.db.commit()

    async def delete_account(self, user_uuid: str, password: str):
        user = await self.get_user_by_uuid(user_uuid)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
            
        if not security.verify_password(password, user.password_hash):
            raise HTTPException(status_code=403, detail="Invalid password")
            
        await self.db.delete(user)
        await self.db.commit()

    async def update_user(self, user: models.User, payload: schemas.UserUpdate) -> models.User:
        # 1. Проверка уникальности, если поля предоставлены
        if payload.login and payload.login != user.login:
            stmt = select(models.User).where(models.User.login == payload.login)
            if (await self.db.execute(stmt)).scalar_one_or_none():
                raise HTTPException(status_code=409, detail="Login is already taken")
            user.login = payload.login

        if payload.email and payload.email != user.email:
            stmt = select(models.User).where(models.User.email == payload.email)
            if (await self.db.execute(stmt)).scalar_one_or_none():
                raise HTTPException(status_code=409, detail="Email is already taken")
            
            # При смене Email сбрасываем верификацию
            user.email = payload.email
            user.is_verified = False
            user.verification_token = str(uuid.uuid4())
            # Опционально: отправить письмо с новым токеном
            self.mock_email(user.email, "Verify New Email", f"Token: {user.verification_token}")

        await self.db.commit()
        await self.db.refresh(user)
        return user

    # --- Password Recovery ---
    async def forgot_password(self, email: str) -> str | None:
        result = await self.db.execute(select(models.User).where(models.User.email == email))
        user = result.scalar_one_or_none()
        if not user:
            return None 
        
        token = security.create_token(user.uuid, "reset", timedelta(minutes=config.settings.RESET_TOKEN_EXPIRE_MINUTES))
        self.mock_email(email, "Password Reset", f"Token: {token}")
        return token

    async def reset_password(self, token: str, new_password: str):
        payload = security.decode_token(token)
        if not payload or payload.get("type") != "reset":
            raise HTTPException(status_code=400, detail="Invalid or expired reset token")
            
        user_uuid = payload["sub"]
        user = await self.get_user_by_uuid(user_uuid)
        
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
            
        user.password_hash = security.get_password_hash(new_password)
        await self.db.execute(delete(models.Session).where(models.Session.user_uuid == user_uuid))
        await self.db.commit()

    async def change_password(self, user_uuid: str, old_pw: str, new_pw: str):
        user = await self.get_user_by_uuid(user_uuid)
        if not security.verify_password(old_pw, user.password_hash):
            raise HTTPException(status_code=403, detail="Invalid old password")
            
        user.password_hash = security.get_password_hash(new_pw)
        await self.db.commit()

    # --- Verification ---
    async def send_verification(self, user: models.User) -> str:
        if not user.email:
             raise HTTPException(status_code=400, detail="User has no email to verify.")

        # Generate new DB token (UUID)
        token = str(uuid.uuid4())
        user.verification_token = token
        await self.db.commit()
        
        self.mock_email(user.email, "Verify Account", f"Token: {token}")
        return token

    async def verify_email(self, token: str):
        # Verify against the DB column directly
        result = await self.db.execute(select(models.User).where(models.User.verification_token == token))
        user = result.scalar_one_or_none()
        
        if not user:
            raise HTTPException(status_code=400, detail="Invalid or expired verification token")
            
        user.is_verified = True
        user.verification_token = None # One-time use
        await self.db.commit()

