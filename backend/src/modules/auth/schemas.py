from pydantic import BaseModel, EmailStr, Field, ConfigDict
from typing import Optional

# --- Auth & Tokens ---
class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class LogoutRequest(BaseModel):
    refresh_token: str

# --- User Operations ---
class UserRegister(BaseModel):
    login: str = Field(min_length=3)
    email: EmailStr
    password: str = Field(min_length=8)

class UserLogin(BaseModel):
    credential: str # Email or Login
    password: str

class UserRead(BaseModel):
    uuid: str
    login: str
    email: EmailStr
    is_verified: bool
    
    model_config = ConfigDict(from_attributes=True)

class AccountDelete(BaseModel):
    current_password: str

# --- Password & Verification ---
class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class PasswordResetConfirm(BaseModel):
    token: str

class PasswordReset(BaseModel):
    token: str
    new_password: str = Field(min_length=8)

class PasswordChange(BaseModel):
    old_password: str
    new_password: str = Field(min_length=8)

class VerifyEmailRequest(BaseModel):
    token: str

class MessageResponse(BaseModel):
    message: str
