import httpx
from typing import Optional
from sqlalchemy.orm import Session
from app.utils.logger import logger
from app.utils.exceptions import BarcodeNotFoundException
from app.schemas.barcode import BarcodeData
from app.services.fallback_service import FallbackService
from app.utils.database import log_analysis

class BarcodeService:
    def __init__(self):
        self.base_url = "https://world.openfoodfacts.org/api/v2/product"
        self.headers = {
            "User-Agent": "HealTrackDailyBackend/1.0 (FastAPI/Python)"
        }

    async def lookup_barcode(self, barcode: str, db: Session) -> dict:
        """
        Looks up a product barcode using the OpenFoodFacts API, logs the event, and falls back if not found.
        """
        input_summary = {"barcode": barcode}

        # Simple local validation
        if not barcode or not barcode.isdigit() or len(barcode) < 8:
            logger.warning(f"Invalid barcode format: '{barcode}'")
            fallback_data = FallbackService.get_barcode_fallback()
            log_analysis(
                db, 
                analysis_type="barcode", 
                status="failed", 
                input_data=input_summary, 
                output_data=fallback_data
            )
            return fallback_data

        url = f"{self.base_url}/{barcode}.json"
        
        try:
            async with httpx.AsyncClient(timeout=10.0, headers=self.headers) as client:
                response = await client.get(url)
                
                if response.status_code != 200:
                    logger.error(f"OpenFoodFacts API error status: {response.status_code} for barcode {barcode}")
                    fallback_data = FallbackService.get_barcode_fallback()
                    log_analysis(
                        db, 
                        analysis_type="barcode", 
                        status="failed", 
                        input_data=input_summary, 
                        output_data=fallback_data
                    )
                    return fallback_data

                data = response.json()
                
                if data.get("status") == 0 or "product" not in data:
                    logger.info(f"Barcode not found in OpenFoodFacts database: {barcode}")
                    fallback_data = FallbackService.get_barcode_fallback()
                    log_analysis(
                        db, 
                        analysis_type="barcode", 
                        status="barcode_not_found", 
                        input_data=input_summary, 
                        output_data=fallback_data
                    )
                    return fallback_data

                product = data["product"]
                
                # Extract fields with safe fallbacks
                product_name = (
                    product.get("product_name") or 
                    product.get("product_name_en") or 
                    product.get("generic_name") or 
                    f"Unknown Product ({barcode})"
                )
                
                nutrition_grade = product.get("nutrition_grades") or product.get("nutrition_grade_fr")
                if nutrition_grade:
                    nutrition_grade = nutrition_grade.lower()

                nutriments = product.get("nutriments", {})
                
                # Extract energy / calories
                energy_kcal = (
                    nutriments.get("energy-kcal_100g") or 
                    nutriments.get("energy-kcal_value") or 
                    nutriments.get("energy-kcal") or 
                    0.0
                )
                # If energy in kcal is not present but energy in kJ is, convert it
                if energy_kcal == 0.0 and "energy_100g" in nutriments:
                    try:
                        energy_kj = float(nutriments.get("energy_100g", 0))
                        energy_kcal = round(energy_kj / 4.184, 1)
                    except (ValueError, TypeError):
                        pass

                # Extract macros
                protein = float(nutriments.get("proteins_100g") or nutriments.get("proteins") or 0.0)
                fat = float(nutriments.get("fat_100g") or nutriments.get("fat") or 0.0)
                sugar = float(nutriments.get("sugars_100g") or nutriments.get("sugars") or 0.0)

                barcode_data = BarcodeData(
                    product_name=product_name,
                    nutrition_grade=nutrition_grade,
                    energy_kcal=round(energy_kcal, 1),
                    protein=round(protein, 1),
                    fat=round(fat, 1),
                    sugar=round(sugar, 1)
                )

                result_payload = {
                    "success": True,
                    "status": "completed",
                    "data": barcode_data.model_dump()
                }

                # Log successful query
                log_analysis(
                    db, 
                    analysis_type="barcode", 
                    status="completed", 
                    input_data=input_summary, 
                    output_data=result_payload
                )

                return result_payload

        except Exception as e:
            logger.error(f"Unexpected error in barcode lookup: {str(e)}")
            fallback_data = FallbackService.get_barcode_fallback()
            log_analysis(
                db, 
                analysis_type="barcode", 
                status="failed", 
                input_data=input_summary, 
                output_data=fallback_data
            )
            return fallback_data
