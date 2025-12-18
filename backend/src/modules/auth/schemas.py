from pydantic import BaseModel, EmailStr, Field, ConfigDict, field_validator
from typing import Optional
import re

# --- Shared Schemas ---
class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

class MessageResponse(BaseModel):
    message: str

# --- Register Schema ---
class UserRegister(BaseModel):
    # Optional поля по умолчанию None
    login: Optional[str] = Field(None, min_length=3, max_length=50, description="Unique username")
    email: Optional[EmailStr] = Field(None, description="Unique email address")
    password: str = Field(min_length=8)

    # ВАЖНО: Превращаем пустые строки "" в None ДО валидации.
    # Это решает проблему отправки пустых полей из HTML-форм.
    @field_validator('login', 'email', mode='before')
    @classmethod
    def empty_string_to_none(cls, v):
        if isinstance(v, str) and v.strip() == "":
            return None
        return v

    @field_validator('login')
    @classmethod
    def validate_login_format(cls, v):
        if v:
            if "@" in v:
                raise ValueError("Логин не может содержать '@'. Используйте поле Email.")
            # Только латиница, цифры, точки, тире и подчеркивания
            if not re.match(r"^[a-zA-Z0-9_.-]+$", v):
                raise ValueError("Логин содержит недопустимые символы.")
        return v

    def model_post_init(self, __context):
        # Проверка, что хотя бы одно поле заполнено
        if not self.login and not self.email:
            raise ValueError("Требуется указать либо Email, либо Логин.")

# --- Other Schemas ---
class UserLogin(BaseModel):
    credential: str
    password: str

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class LogoutRequest(BaseModel):
    refresh_token: str

class UserRead(BaseModel):
    uuid: str
    login: Optional[str]
    email: Optional[EmailStr]
    is_verified: bool
    model_config = ConfigDict(from_attributes=True)

class AccountDelete(BaseModel):
    current_password: str

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

class UserUpdate(BaseModel):
    login: Optional[str] = Field(None, min_length=3, max_length=50)
    email: Optional[EmailStr] = Field(None)

    @field_validator('login', 'email', mode='before')
    @classmethod
    def empty_string_to_none(cls, v):
        if isinstance(v, str) and v.strip() == "":
            return None
        return v