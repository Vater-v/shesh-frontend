from fastapi import APIRouter, Depends, HTTPException, Header, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Annotated

from . import database, schemas, service, models, security

router = APIRouter(prefix="/auth", tags=["Authentication"])

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

# --- Dependencies ---
async def get_auth_service(db: AsyncSession = Depends(database.get_db)) -> service.AuthService:
    return service.AuthService(db)

async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    svc: Annotated[service.AuthService, Depends(get_auth_service)]
) -> models.User:
    payload = security.decode_token(token)
    if not payload or payload.get("type") != "access":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    user = await svc.get_user_by_uuid(payload["sub"])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# --- Endpoints ---

@router.post("/register", response_model=schemas.Token)
async def register(
    payload: schemas.UserRegister, 
    svc: service.AuthService = Depends(get_auth_service),
    user_agent: str = Header(None)
):
    # Registration logic includes conflict checks and verification triggering
    return await svc.register_user(payload)

@router.post("/login", response_model=schemas.Token)
async def login(
    payload: schemas.UserLogin, 
    svc: service.AuthService = Depends(get_auth_service),
    user_agent: str = Header(None)
):
    return await svc.login_user(payload, user_agent or "Unknown")

@router.post("/refresh", response_model=schemas.Token)
async def refresh(
    payload: schemas.RefreshTokenRequest,
    svc: service.AuthService = Depends(get_auth_service),
    user_agent: str = Header(None)
):
    return await svc.refresh_token(payload.refresh_token, user_agent or "Unknown")

@router.post("/logout", response_model=schemas.MessageResponse)
async def logout(
    payload: schemas.LogoutRequest,
    svc: service.AuthService = Depends(get_auth_service)
):
    await svc.logout(payload.refresh_token)
    return {"message": "Logged out successfully"}

@router.get("/me", response_model=schemas.UserRead)
async def get_me(current_user: models.User = Depends(get_current_user)):
    return current_user

@router.delete("/delete", response_model=schemas.MessageResponse)
async def delete_account(
    payload: schemas.AccountDelete,
    current_user: models.User = Depends(get_current_user),
    svc: service.AuthService = Depends(get_auth_service)
):
    await svc.delete_account(current_user.uuid, payload.current_password)
    return {"message": "Account deleted"}

# --- Recovery ---
@router.post("/password/forgot", response_model=schemas.MessageResponse)
async def forgot_password(
    payload: schemas.ForgotPasswordRequest,
    svc: service.AuthService = Depends(get_auth_service)
):
    await svc.forgot_password(payload.email)
    return {"message": "If email exists, reset link sent"}

@router.post("/password/confirm", response_model=schemas.MessageResponse)
async def confirm_reset(payload: schemas.PasswordResetConfirm):
    if not security.decode_token(payload.token):
        raise HTTPException(status_code=400, detail="Invalid token")
    return {"message": "Token is valid"}

@router.post("/password/reset", response_model=schemas.MessageResponse)
async def reset_password(
    payload: schemas.PasswordReset,
    svc: service.AuthService = Depends(get_auth_service)
):
    await svc.reset_password(payload.token, payload.new_password)
    return {"message": "Password reset successfully. Sessions invalidated."}

@router.post("/password/change", response_model=schemas.MessageResponse)
async def change_password(
    payload: schemas.PasswordChange,
    current_user: models.User = Depends(get_current_user),
    svc: service.AuthService = Depends(get_auth_service)
):
    await svc.change_password(current_user.uuid, payload.old_password, payload.new_password)
    return {"message": "Password changed successfully"}

# --- Verify ---
@router.post("/email/resend", response_model=schemas.MessageResponse)
async def resend_verification(
    current_user: models.User = Depends(get_current_user),
    svc: service.AuthService = Depends(get_auth_service)
):
    if current_user.is_verified:
        return {"message": "Already verified"}
    await svc.send_verification(current_user)
    return {"message": "Email sent"}

@router.post("/email/verify", response_model=schemas.MessageResponse)
async def verify_email(
    payload: schemas.VerifyEmailRequest,
    svc: service.AuthService = Depends(get_auth_service)
):
    await svc.verify_email(payload.token)
    return {"message": "Email verified successfully"}

@router.patch("/me", response_model=schemas.UserRead)
async def update_me(
    payload: schemas.UserUpdate,
    current_user: models.User = Depends(get_current_user),
    svc: service.AuthService = Depends(get_auth_service)
):
    """Обновление данных текущего профиля."""
    return await svc.update_user(current_user, payload)