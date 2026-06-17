import os
import logging
from logging.handlers import RotatingFileHandler

# Ensure logs directory exists
os.makedirs("logs", exist_ok=True)

logger = logging.getLogger("nutrition_api")
logger.setLevel(logging.INFO)

# Formatter for structured logs
formatter = logging.Formatter(
    '[%(asctime)s] %(levelname)s - %(message)s'
)

# File handler with max 10MB per file and 5 backups
file_handler = RotatingFileHandler(
    "logs/app.log", maxBytes=10485760, backupCount=5, encoding="utf-8"
)
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)

# Console handler for local output
console_handler = logging.StreamHandler()
console_handler.setFormatter(formatter)
logger.addHandler(console_handler)
