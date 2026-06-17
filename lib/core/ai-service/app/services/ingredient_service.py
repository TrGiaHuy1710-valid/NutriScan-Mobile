from typing import List, Optional
from sqlalchemy.orm import Session
from app.services.gemini_service import GeminiService
from app.services.fallback_service import FallbackService
from app.utils.database import log_analysis
from app.utils.logger import logger
from app.utils.exceptions import ImageTooLargeException, ImageNotSupportedException

class IngredientService:
    def __init__(self, gemini_service: GeminiService):
        self.gemini_service = gemini_service
        self.max_image_size = 10 * 1024 * 1024  # 10 MB limit
        self.supported_mime_types = ["image/jpeg", "image/png", "image/webp", "image/heic"]

    def validate_image(self, file_size: int, content_type: str):
        """
        Validates uploaded image size and MIME type.
        """
        if file_size > self.max_image_size:
            raise ImageTooLargeException(f"Image size exceeds limit of 10MB (Got {file_size / (1024*1024):.2f}MB).")
        
        if content_type not in self.supported_mime_types:
            raise ImageNotSupportedException(f"Supported formats: JPEG, PNG, WEBP, HEIC. Got {content_type}.")

    async def analyze_ingredients_from_image(
        self, 
        image_bytes: bytes, 
        content_type: str, 
        db: Session
    ) -> dict:
        """
        Analyzes ingredient label from an uploaded image.
        """
        self.validate_image(len(image_bytes), content_type)
        input_summary = {
            "image_size": len(image_bytes),
            "content_type": content_type
        }

        try:
            analysis_result = await self.gemini_service.analyze_ingredients_image(
                image_bytes, 
                content_type
            )
            
            result_data = analysis_result.model_dump()
            response_payload = {
                "success": True,
                "status": "completed",
                "data": result_data
            }

            log_analysis(
                db, 
                analysis_type="ingredient_image", 
                status="completed", 
                input_data=input_summary, 
                output_data=response_payload
            )
            return response_payload

        except Exception as e:
            logger.error(f"Error analyzing ingredients from image: {str(e)}. Falling back to manual input.")
            fallback_data = FallbackService.get_ingredient_fallback()
            log_analysis(
                db, 
                analysis_type="ingredient_image", 
                status="failed", 
                input_data=input_summary, 
                output_data=fallback_data
            )
            return fallback_data

    async def analyze_ingredients_from_text(
        self, 
        ingredients: List[str], 
        db: Session
    ) -> dict:
        """
        Analyzes ingredient list from a text list of ingredients.
        """
        input_summary = {
            "ingredients": ingredients
        }

        try:
            analysis_result = await self.gemini_service.analyze_ingredients_text(ingredients)
            
            result_data = analysis_result.model_dump()
            response_payload = {
                "success": True,
                "status": "completed",
                "data": result_data
            }

            log_analysis(
                db, 
                analysis_type="ingredient_text", 
                status="completed", 
                input_data=input_summary, 
                output_data=response_payload
            )
            return response_payload

        except Exception as e:
            logger.error(f"Error analyzing ingredients from text: {str(e)}.")
            # Text analysis errors will also return standard manual entry structure
            fallback_data = FallbackService.get_ingredient_fallback()
            log_analysis(
                db, 
                analysis_type="ingredient_text", 
                status="failed", 
                input_data=input_summary, 
                output_data=fallback_data
            )
            return fallback_data
