import json
import asyncio
from typing import List, Tuple
import google.generativeai as genai
from google.generativeai.types import GenerationConfig
from google.api_core.exceptions import GoogleAPICallError, ResourceExhausted

from app.utils.config import settings
from app.utils.logger import logger
from app.utils.exceptions import (
    GeminiTimeoutException,
    GeminiQuotaExceededException,
    GeminiInvalidResponseException
)
from app.schemas.food import FoodAnalysisData
from app.schemas.ingredient import IngredientAnalysisData

class GeminiService:
    def __init__(self):
        # Configure Gemini API Key if present
        api_key = settings.GEMINI_API_KEY
        if api_key and api_key != "your_gemini_api_key_here":
            genai.configure(api_key=api_key)
            self._enabled = True
        else:
            self._enabled = False
            logger.warning("GEMINI_API_KEY is not configured or is the default template. Gemini service will run in mock/fallback mode.")

    async def analyze_food(self, image_bytes: bytes, mime_type: str, people_count: int = 1) -> FoodAnalysisData:
        """
        Analyzes a food image using Gemini 2.5 Flash to estimate dishes, ingredients, and calories.
        """
        if not self._enabled:
            # Raise exception to trigger the manual input fallback
            raise GeminiQuotaExceededException("Gemini API key is not configured.")

        # Prepare multi-modal input
        image_part = {
            "mime_type": mime_type,
            "data": image_bytes
        }
        
        prompt = (
            f"Analyze this food image. Identify all visible dishes and ingredients. "
            f"Estimate the calories, protein, carbs, fat, and weight in grams for each dish. "
            f"Set the people count to {people_count} and calculate the calories per person. "
            f"Estimate your confidence level as 'high', 'medium', or 'low'. "
            f"Verify all calculations (e.g. calories_per_person = total_calories / people_count)."
        )

        contents = [image_part, prompt]
        
        # Configure structured output with Pydantic model
        generation_config = GenerationConfig(
            response_mime_type="application/json",
            response_schema=FoodAnalysisData,
            temperature=0.2
        )

        try:
            model = genai.GenerativeModel(settings.GEMINI_MODEL)
            # Invoke async model call with timeout of 20 seconds
            response = await asyncio.wait_for(
                model.generate_content_async(
                    contents,
                    generation_config=generation_config
                ),
                timeout=20.0
            )

            # Check if response text exists
            if not response.text:
                raise GeminiInvalidResponseException("Empty response from Gemini API.")

            # Validate and parse response text into Pydantic
            data_dict = json.loads(response.text)
            
            # Recalculate calories per person to ensure correctness
            data_dict["people_count"] = people_count
            if people_count > 0:
                data_dict["calories_per_person"] = round(data_dict["total_calories"] / people_count, 1)
            else:
                data_dict["calories_per_person"] = data_dict["total_calories"]

            # Parse through Pydantic
            analysis_result = FoodAnalysisData(**data_dict)
            return analysis_result

        except asyncio.TimeoutError:
            logger.error("Gemini food analysis timed out.")
            raise GeminiTimeoutException()
        except ResourceExhausted as e:
            logger.error(f"Gemini quota exceeded: {str(e)}")
            raise GeminiQuotaExceededException()
        except GoogleAPICallError as e:
            logger.error(f"Gemini API call error: {str(e)}")
            raise GeminiInvalidResponseException(f"Gemini API call failed: {str(e)}")
        except json.JSONDecodeError as e:
            logger.error(f"Failed to decode Gemini JSON response: {str(e)}")
            raise GeminiInvalidResponseException("Failed to decode JSON response from Gemini.")
        except Exception as e:
            logger.error(f"Unexpected error during Gemini food analysis: {str(e)}")
            raise GeminiInvalidResponseException(f"Unexpected Gemini service error: {str(e)}")

    async def analyze_ingredients_image(self, image_bytes: bytes, mime_type: str) -> IngredientAnalysisData:
        """
        Analyzes ingredients from an image (e.g. nutrition label or food packaging text).
        """
        if not self._enabled:
            raise GeminiQuotaExceededException("Gemini API key is not configured.")

        image_part = {
            "mime_type": mime_type,
            "data": image_bytes
        }
        
        prompt = (
            "Analyze the ingredient list from this packaging label image. "
            "Identify each ingredient, specify its individual benefits, potential health risks or alerts, "
            "and assign an individual health score from 0 to 100. "
            "Provide an overall health score from 0 to 100 for the combined ingredients."
        )

        contents = [image_part, prompt]

        generation_config = GenerationConfig(
            response_mime_type="application/json",
            response_schema=IngredientAnalysisData,
            temperature=0.2
        )

        try:
            model = genai.GenerativeModel(settings.GEMINI_MODEL)
            response = await asyncio.wait_for(
                model.generate_content_async(
                    contents,
                    generation_config=generation_config
                ),
                timeout=20.0
            )

            if not response.text:
                raise GeminiInvalidResponseException("Empty response from Gemini API.")

            data_dict = json.loads(response.text)
            analysis_result = IngredientAnalysisData(**data_dict)
            return analysis_result

        except asyncio.TimeoutError:
            logger.error("Gemini ingredient label analysis timed out.")
            raise GeminiTimeoutException()
        except ResourceExhausted as e:
            logger.error(f"Gemini quota exceeded: {str(e)}")
            raise GeminiQuotaExceededException()
        except GoogleAPICallError as e:
            logger.error(f"Gemini API call error: {str(e)}")
            raise GeminiInvalidResponseException(f"Gemini API call failed: {str(e)}")
        except Exception as e:
            logger.error(f"Unexpected error during Gemini ingredient label analysis: {str(e)}")
            raise GeminiInvalidResponseException(f"Unexpected Gemini service error: {str(e)}")

    async def analyze_ingredients_text(self, ingredients: List[str]) -> IngredientAnalysisData:
        """
        Analyzes a textual list of ingredients.
        """
        if not self._enabled:
            raise GeminiQuotaExceededException("Gemini API key is not configured.")

        ingredients_str = ", ".join(ingredients)
        prompt = (
            f"Analyze the following list of ingredients: {ingredients_str}. "
            "For each ingredient, specify its individual benefits, potential health risks or alerts, "
            "and assign an individual health score from 0 to 100. "
            "Provide an overall health score from 0 to 100 for the combined ingredients."
        )

        generation_config = GenerationConfig(
            response_mime_type="application/json",
            response_schema=IngredientAnalysisData,
            temperature=0.2
        )

        try:
            model = genai.GenerativeModel(settings.GEMINI_MODEL)
            response = await asyncio.wait_for(
                model.generate_content_async(
                    prompt,
                    generation_config=generation_config
                ),
                timeout=15.0
            )

            if not response.text:
                raise GeminiInvalidResponseException("Empty response from Gemini API.")

            data_dict = json.loads(response.text)
            analysis_result = IngredientAnalysisData(**data_dict)
            return analysis_result

        except asyncio.TimeoutError:
            logger.error("Gemini ingredient text analysis timed out.")
            raise GeminiTimeoutException()
        except ResourceExhausted as e:
            logger.error(f"Gemini quota exceeded: {str(e)}")
            raise GeminiQuotaExceededException()
        except GoogleAPICallError as e:
            logger.error(f"Gemini API call error: {str(e)}")
            raise GeminiInvalidResponseException(f"Gemini API call failed: {str(e)}")
        except Exception as e:
            logger.error(f"Unexpected error during Gemini ingredient text analysis: {str(e)}")
            raise GeminiInvalidResponseException(f"Unexpected Gemini service error: {str(e)}")
