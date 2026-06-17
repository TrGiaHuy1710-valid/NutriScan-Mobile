import os
import sys
import uvicorn
from dotenv import load_dotenv

# Pre-load dotenv before import config
load_dotenv()

from app.utils.config import settings
from app.utils.logger import logger
from app.utils.database import init_db

def main():
    logger.info("Checking environment variables and configuration...")
    
    # Validate critical variables
    if not settings.GEMINI_API_KEY or settings.GEMINI_API_KEY == "your_gemini_api_key_here":
        logger.warning(
            "GEMINI_API_KEY is not configured or set to placeholder. "
            "Gemini queries will fail and trigger manual fallback options."
        )
    else:
        logger.info("GEMINI_API_KEY successfully detected.")

    # Ensure Database directory and Schema exist
    logger.info("Ensuring SQLite tables are initialized...")
    try:
        init_db()
        logger.info("SQLite tables verified/created successfully.")
    except Exception as e:
        logger.critical(f"Failed to initialize SQLite database: {str(e)}")
        sys.exit(1)

    # Launch FastAPI Server
    port = 8000
    host = "0.0.0.0"
    logger.info(f"Launching FastAPI on http://{host}:{port}")
    
    uvicorn.run(
        "app.main:app",
        host=host,
        port=port,
        reload=(settings.APP_ENV == "development")
    )

if __name__ == "__main__":
    main()
