import io
from sqlalchemy.orm import Session
from app.services.gemini_service import GeminiService
from app.services.fallback_service import FallbackService
from app.utils.database import log_analysis
from app.utils.logger import logger
from app.utils.exceptions import ImageTooLargeException, ImageNotSupportedException

class FoodService:
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

    async def analyze_food_image(
        self, 
        image_bytes: bytes, 
        content_type: str, 
        people_count: int, 
        db: Session
    ) -> dict:
        """
        Coordinates food image validation, calling Gemini, saving to DB history, and handling fallback cases.
        """
        # Validate size and format
        self.validate_image(len(image_bytes), content_type)

        input_summary = {
            "image_size": len(image_bytes),
            "content_type": content_type,
            "people_count": people_count
        }

        try:
            # Call Gemini
            analysis_result = await self.gemini_service.analyze_food(
                image_bytes, 
                content_type, 
                people_count
            )

            # Check for low confidence fallback
            if analysis_result.confidence.lower() == "low":
                logger.warning("Gemini analysis returned LOW confidence. Triggering manual fallback.")
                fallback_data = FallbackService.get_food_fallback("Gemini analysis returned low confidence.")
                log_analysis(
                    db, 
                    analysis_type="food", 
                    status="manual_input_required", 
                    input_data=input_summary, 
                    output_data=fallback_data
                )
                return fallback_data

            # Success
            result_data = analysis_result.model_dump()
            response_payload = {
                "success": True,
                "status": "completed",
                "data": result_data
            }

            # Log to DB
            log_analysis(
                db, 
                analysis_type="food", 
                status="completed", 
                input_data=input_summary, 
                output_data=response_payload
            )
            return response_payload

        except Exception as e:
            logger.error(f"Error analyzing food image: {str(e)}. Falling back to manual input.")
            fallback_data = FallbackService.get_food_fallback(f"AI estimation failed: {str(e)}")
            log_analysis(
                db, 
                analysis_type="food", 
                status="failed", 
                input_data=input_summary, 
                output_data=fallback_data
            )
            return fallback_data
