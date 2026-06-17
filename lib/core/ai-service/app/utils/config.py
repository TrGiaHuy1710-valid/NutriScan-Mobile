import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    GEMINI_API_KEY: str = ""
    NGROK_AUTHTOKEN: str = ""
    DATABASE_URL: str = "sqlite:///nutrition.db"
    APP_ENV: str = "development"
    GEMINI_MODEL: str = "gemini-2.5-flash"

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()
