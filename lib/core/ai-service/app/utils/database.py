import datetime
import json
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.utils.config import settings

engine = create_engine(
    settings.DATABASE_URL, connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class AnalysisHistory(Base):
    __tablename__ = "analysis_history"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    analysis_type = Column(String(50), nullable=False)  # "food", "ingredient", "barcode"
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    status = Column(String(50), nullable=False)  # "completed", "failed", "manual_input_required"
    input_summary = Column(Text, nullable=True)  # JSON-stringified input
    output_summary = Column(Text, nullable=True)  # JSON-stringified output

def init_db():
    Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def log_analysis(db, analysis_type: str, status: str, input_data: dict, output_data: dict):
    """
    Utility helper to log successful or fallback analyses into SQLite.
    """
    try:
        history = AnalysisHistory(
            analysis_type=analysis_type,
            status=status,
            input_summary=json.dumps(input_data),
            output_summary=json.dumps(output_data)
        )
        db.add(history)
        db.commit()
        db.refresh(history)
        return history
    except Exception as e:
        db.rollback()
        # Non-blocking log failure
        from app.utils.logger import logger
        logger.error(f"Failed to log analysis to SQLite: {str(e)}")
        return None
