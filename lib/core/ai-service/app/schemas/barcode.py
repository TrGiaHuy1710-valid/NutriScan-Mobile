from typing import Optional
from pydantic import BaseModel, Field

class BarcodeRequest(BaseModel):
    barcode: str = Field(..., description="The barcode number to lookup")

class BarcodeData(BaseModel):
    product_name: str = Field(..., description="The name of the product")
    nutrition_grade: Optional[str] = Field(None, description="The OpenFoodFacts nutrition grade (A-E)")
    energy_kcal: float = Field(..., description="Energy in kcal per 100g or serving")
    protein: float = Field(..., description="Protein in grams per 100g or serving")
    fat: float = Field(..., description="Fat in grams per 100g or serving")
    sugar: float = Field(..., description="Sugar in grams per 100g or serving")
