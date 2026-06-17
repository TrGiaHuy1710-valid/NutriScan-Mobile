from fastapi import APIRouter, UploadFile, File, Form, Depends
from sqlalchemy.orm import Session
from app.utils.database import get_db
from app.services.food_service import FoodService
from app.services.gemini_service import GeminiService

router = APIRouter(prefix="/api/v1/food", tags=["Food"])

# Dependency Injection for services
def get_food_service():
    gemini = GeminiService()
    return FoodService(gemini)

@router.post("/analyze")
async def analyze_food(
    image: UploadFile = File(..., description="Image file of the food to analyze"),
    people_count: int = Form(1, description="Number of people sharing the food"),
    db: Session = Depends(get_db),
    food_service: FoodService = Depends(get_food_service)
):
    """
    Analyzes an uploaded image of food using Gemini AI to estimate calories, macros, and identified dishes.
    """
    image_bytes = await image.read()
    content_type = image.content_type
    
    result = await food_service.analyze_food_image(
        image_bytes=image_bytes,
        content_type=content_type,
        people_count=people_count,
        db=db
    )
    return result
