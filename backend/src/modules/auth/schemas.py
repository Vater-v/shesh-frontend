from pydantic import BaseModel, EmailStr, Field, ConfigDict, model_validator
from typing import Optional
import re

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
    login: Optional[str] = Field(None, min_length=3, description="Unique username")
    email: Optional[EmailStr] = Field(None, description="Unique email address")
    password: str = Field(min_length=8)

    @model_validator(mode='after')
    def validate_credentials(self) -> 'UserRegister':
        login = self.login
        email = self.email

        # 1. Ensure at least one credential is provided
        if not login and not email:
            raise ValueError("Either 'login' or 'email' must be provided.")

        # 2. Validate Login format to prevent ambiguity with Email
        if login:
            if "@" in login:
                raise ValueError("Login field cannot contain '@'. Please use the email field for email addresses.")
            
            # Optional: Strict regex for login (Alphanumeric, underscores, hyphens, dots)
            if not re.match(r"^[a-zA-Z0-9_.-]+$", login):
                raise ValueError("Login contains invalid characters.")

        return self

class UserLogin(BaseModel):
    credential: str # Can be Login or Email
    password: str

class UserRead(BaseModel):
    uuid: str
    login: Optional[str]
    email: Optional[EmailStr]
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