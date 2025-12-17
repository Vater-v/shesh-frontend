import hashlib
import jwt
from datetime import datetime, timedelta, timezone
from passlib.context import CryptContext
from typing import Union, Any
from .config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# --- Password Hashing ---
def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

# --- Token Hashing ---
def hash_token(token: str) -> str:
    """Hashes a token using SHA256 for secure storage."""
    return hashlib.sha256(token.encode()).hexdigest()

# --- JWT Handling ---
def create_token(subject: str, type: str, expires_delta: timedelta) -> str:
    expire = datetime.now(timezone.utc) + expires_delta
    to_encode = {"sub": subject, "type": type, "exp": expire}
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def create_access_token(user_uuid: str) -> str:
    return create_token(
        subject=user_uuid, 
        type="access", 
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )

def create_refresh_token(user_uuid: str) -> str:
    return create_token(
        subject=user_uuid, 
        type="refresh", 
        expires_delta=timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    )

def decode_token(token: str) -> dict | None:
    try:
        return jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
    except jwt.PyJWTError:
        return None
