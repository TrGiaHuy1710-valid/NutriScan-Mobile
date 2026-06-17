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

    @staticmethod
    def safe_parse_gemini_json(text: str) -> dict:
        """
        Cleans and parses raw JSON text returned by Gemini.
        Removes markdown code block fences if present.
        """
        if not text:
            raise GeminiInvalidResponseException("Empty response received from Gemini API.")

        cleaned = text.strip()
        
        # Strip markdown json block fences if present
        if cleaned.startswith("```"):
            lines = cleaned.splitlines()
            if lines[0].startswith("```"):
                lines = lines[1:]
            if lines and lines[-1].startswith("```"):
                lines = lines[:-1]
            cleaned = "\n".join(lines).strip()
            
        try:
            return json.loads(cleaned)
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON. Raw text: '{text}'. Error: {str(e)}")
            raise GeminiInvalidResponseException(f"Failed to parse JSON response from Gemini: {str(e)}")

    async def analyze_food(self, image_bytes: bytes, mime_type: str, people_count: int = 1) -> FoodAnalysisData:
        """
        Analyzes a food image using Gemini 2.5 Flash to estimate dishes, ingredients, and calories.
        Uses prompt-based JSON enforcement and validates the response against Pydantic models.
        """
        if not self._enabled:
            raise GeminiQuotaExceededException("Gemini API key is not configured.")

        # Prepare multi-modal input
        image_part = {
            "mime_type": mime_type,
            "data": image_bytes
        }
        
        prompt = (
            f"Analyze this food image. Identify all visible dishes and ingredients.\n"
            f"Estimate the calories, protein, carbs, fat, and weight in grams for each dish.\n"
            f"Set the people count to {people_count}.\n"
            f"Estimate your confidence level as 'high', 'medium', or 'low'.\n\n"
            f"You MUST return ONLY a valid JSON object matching the following structure without any markdown, explanations, or enclosing blocks:\n"
            f"{{\n"
            f"  \"dishes\": [\n"
            f"    {{\n"
            f"      \"name\": \"string (name of dish)\",\n"
            f"      \"estimated_weight_g\": 0.0,\n"
            f"      \"calories\": 0.0,\n"
            f"      \"protein_g\": 0.0,\n"
            f"      \"carbs_g\": 0.0,\n"
            f"      \"fat_g\": 0.0,\n"
            f"      \"ingredients\": [\"string (ingredient)\"]\n"
            f"    }}\n"
            f"  ],\n"
            f"  \"total_calories\": 0.0,\n"
            f"  \"people_count\": {people_count},\n"
            f"  \"calories_per_person\": 0.0,\n"
            f"  \"confidence\": \"high\" | \"medium\" | \"low\"\n"
            f"}}\n"
        )

        contents = [image_part, prompt]
        
        # Configure GenerationConfig without response_schema
        generation_config = GenerationConfig(
            response_mime_type="application/json",
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

            # Parse response text using safe helper
            data_dict = self.safe_parse_gemini_json(response.text)
            
            # Recalculate calories per person to ensure correctness
            data_dict["people_count"] = people_count
            if "total_calories" in data_dict:
                try:
                    total_cal = float(data_dict["total_calories"])
                    if people_count > 0:
                        data_dict["calories_per_person"] = round(total_cal / people_count, 1)
                    else:
                        data_dict["calories_per_person"] = total_cal
                except (ValueError, TypeError):
                    data_dict["calories_per_person"] = 0.0
            else:
                data_dict["total_calories"] = 0.0
                data_dict["calories_per_person"] = 0.0

            # Validate through Pydantic model
            try:
                analysis_result = FoodAnalysisData.model_validate(data_dict)
                return analysis_result
            except Exception as ve:
                logger.error(f"Pydantic validation failed for food data: {str(ve)}. Data: {data_dict}")
                raise GeminiInvalidResponseException(f"Gemini response failed model validation: {str(ve)}")

        except asyncio.TimeoutError:
            logger.error("Gemini food analysis timed out.")
            raise GeminiTimeoutException()
        except ResourceExhausted as e:
            logger.error(f"Gemini quota exceeded: {str(e)}")
            raise GeminiQuotaExceededException()
        except GoogleAPICallError as e:
            logger.error(f"Gemini API call error: {str(e)}")
            raise GeminiInvalidResponseException(f"Gemini API call failed: {str(e)}")
        except GeminiInvalidResponseException:
            raise
        except Exception as e:
            logger.error(f"Unexpected error during Gemini food analysis: {str(e)}")
            raise GeminiInvalidResponseException(f"Unexpected Gemini service error: {str(e)}")

    async def analyze_ingredients_image(self, image_bytes: bytes, mime_type: str) -> IngredientAnalysisData:
        """
        Analyzes ingredients from an image (e.g. nutrition label or food packaging text).
        Uses prompt-based JSON enforcement and validates the response against Pydantic models.
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
            "Provide an overall health score from 0 to 100 for the combined ingredients.\n\n"
            "You MUST return ONLY a valid JSON object matching the following structure without any markdown, explanations, or enclosing blocks:\n"
            "{\n"
            "  \"ingredients\": [\n"
            "    {\n"
            "      \"name\": \"string (name of ingredient)\",\n"
            "      \"benefits\": [\"string (benefit)\"],\n"
            "      \"risks\": [\"string (risk/alert)\"],\n"
            "      \"score\": 0\n"
            "    }\n"
            "  ],\n"
            "  \"overall_score\": 0\n"
            "}\n"
        )

        contents = [image_part, prompt]

        generation_config = GenerationConfig(
            response_mime_type="application/json",
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

            # Parse and validate response
            data_dict = self.safe_parse_gemini_json(response.text)
            
            try:
                analysis_result = IngredientAnalysisData.model_validate(data_dict)
                return analysis_result
            except Exception as ve:
                logger.error(f"Pydantic validation failed for ingredients image data: {str(ve)}. Data: {data_dict}")
                raise GeminiInvalidResponseException(f"Gemini response failed model validation: {str(ve)}")

        except asyncio.TimeoutError:
            logger.error("Gemini ingredient label analysis timed out.")
            raise GeminiTimeoutException()
        except ResourceExhausted as e:
            logger.error(f"Gemini quota exceeded: {str(e)}")
            raise GeminiQuotaExceededException()
        except GoogleAPICallError as e:
            logger.error(f"Gemini API call error: {str(e)}")
            raise GeminiInvalidResponseException(f"Gemini API call failed: {str(e)}")
        except GeminiInvalidResponseException:
            raise
        except Exception as e:
            logger.error(f"Unexpected error during Gemini ingredient label analysis: {str(e)}")
            raise GeminiInvalidResponseException(f"Unexpected Gemini service error: {str(e)}")

    async def analyze_ingredients_text(self, ingredients: List[str]) -> IngredientAnalysisData:
        """
        Analyzes a textual list of ingredients.
        Uses prompt-based JSON enforcement and validates the response against Pydantic models.
        """
        if not self._enabled:
            raise GeminiQuotaExceededException("Gemini API key is not configured.")

        ingredients_str = ", ".join(ingredients)
        prompt = (
            f"Analyze the following list of ingredients: {ingredients_str}. "
            "For each ingredient, specify its individual benefits, potential health risks or alerts, "
            "and assign an individual health score from 0 to 100. "
            "Provide an overall health score from 0 to 100 for the combined ingredients.\n\n"
            "You MUST return ONLY a valid JSON object matching the following structure without any markdown, explanations, or enclosing blocks:\n"
            "{\n"
            "  \"ingredients\": [\n"
            "    {\n"
            "      \"name\": \"string (name of ingredient)\",\n"
            "      \"benefits\": [\"string (benefit)\"],\n"
            "      \"risks\": [\"string (risk/alert)\"],\n"
            "      \"score\": 0\n"
            "    }\n"
            "  ],\n"
            "  \"overall_score\": 0\n"
            "}\n"
        )

        generation_config = GenerationConfig(
            response_mime_type="application/json",
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

            # Parse and validate response
            data_dict = self.safe_parse_gemini_json(response.text)
            
            try:
                analysis_result = IngredientAnalysisData.model_validate(data_dict)
                return analysis_result
            except Exception as ve:
                logger.error(f"Pydantic validation failed for ingredients text data: {str(ve)}. Data: {data_dict}")
                raise GeminiInvalidResponseException(f"Gemini response failed model validation: {str(ve)}")

        except asyncio.TimeoutError:
            logger.error("Gemini ingredient text analysis timed out.")
            raise GeminiTimeoutException()
        except ResourceExhausted as e:
            logger.error(f"Gemini quota exceeded: {str(e)}")
            raise GeminiQuotaExceededException()
        except GoogleAPICallError as e:
            logger.error(f"Gemini API call error: {str(e)}")
            raise GeminiInvalidResponseException(f"Gemini API call failed: {str(e)}")
        except GeminiInvalidResponseException:
            raise
        except Exception as e:
            logger.error(f"Unexpected error during Gemini ingredient text analysis: {str(e)}")
            raise GeminiInvalidResponseException(f"Unexpected Gemini service error: {str(e)}")
