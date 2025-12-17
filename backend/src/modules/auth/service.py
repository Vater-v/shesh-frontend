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
        print(f"\n[MOCK EMAIL] To: {to} | Subject: {subject}")
        print(f"Body: {body}\n")

    async def get_user_by_uuid(self, uuid: str) -> models.User | None:
        return await self.db.get(models.User, uuid)

    # --- Core Auth ---
    async def register_user(self, payload: schemas.UserRegister) -> schemas.Token:
        # Check existing
        result = await self.db.execute(select(models.User).where(
            or_(models.User.email == payload.email, models.User.login == payload.login)
        ))
        if result.scalar_one_or_none():
            raise HTTPException(status_code=409, detail="User already exists")

        new_user = models.User(
            login=payload.login,
            email=payload.email,
            password_hash=security.get_password_hash(payload.password)
        )
        self.db.add(new_user)
        await self.db.commit()
        await self.db.refresh(new_user)
        
        return await self.create_session(new_user)

    async def login_user(self, payload: schemas.UserLogin, user_agent: str) -> schemas.Token:
        result = await self.db.execute(select(models.User).where(
            or_(models.User.email == payload.credential, models.User.login == payload.credential)
        ))
        user = result.scalar_one_or_none()
        
        if not user or not security.verify_password(payload.password, user.password_hash):
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        return await self.create_session(user, user_agent)

    async def create_session(self, user: models.User, user_agent: str = "Unknown") -> schemas.Token:
        access_token = security.create_access_token(user.uuid)
        refresh_token = security.create_refresh_token(user.uuid)
        
        # Store Hash in DB
        expires_at = datetime.now(timezone.utc) + timedelta(days=config.settings.REFRESH_TOKEN_EXPIRE_DAYS)
        session_record = models.Session(
            user_uuid=user.uuid,
            refresh_token_hash=security.hash_token(refresh_token),
            user_agent=user_agent,
            expires_at=expires_at.replace(tzinfo=None) # SQLite compatibility
        )
        self.db.add(session_record)
        await self.db.commit()
        
        return schemas.Token(access_token=access_token, refresh_token=refresh_token)

    async def refresh_token(self, token: str, user_agent: str) -> schemas.Token:
        # 1. Decode (Is it a valid JWT?)
        payload = security.decode_token(token)
        if not payload or payload.get("type") != "refresh":
            raise HTTPException(status_code=401, detail="Invalid token")
        
        user_uuid = payload["sub"]
        token_hash = security.hash_token(token)
        
        # 2. Check DB (Is the session active?)
        result = await self.db.execute(select(models.Session).where(
            models.Session.refresh_token_hash == token_hash
        ))
        session_record = result.scalar_one_or_none()
        
        # Security: If token is valid JWT but not in DB -> Token Reuse / Revoked
        if not session_record:
            raise HTTPException(status_code=401, detail="Session invalid or revoked")
        
        if session_record.expires_at < datetime.utcnow():
            await self.db.delete(session_record)
            await self.db.commit()
            raise HTTPException(status_code=401, detail="Session expired")

        # 3. Rotate (Delete Old, Create New)
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
            
        await self.db.delete(user) # Cascade deletes sessions
        await self.db.commit()

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
        
        # Security Rule: Delete ALL sessions on password reset
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
        token = security.create_token(user.uuid, "verify", timedelta(hours=config.settings.VERIFY_TOKEN_EXPIRE_HOURS))
        self.mock_email(user.email, "Verify Account", f"Token: {token}")
        return token

    async def verify_email(self, token: str):
        payload = security.decode_token(token)
        if not payload or payload.get("type") != "verify":
            raise HTTPException(status_code=400, detail="Invalid token")
            
        user = await self.get_user_by_uuid(payload["sub"])
        if user:
            user.is_verified = True
            await self.db.commit()
