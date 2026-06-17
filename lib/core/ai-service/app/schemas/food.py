from typing import List, Optional
from pydantic import BaseModel, Field

class DishDetail(BaseModel):
    name: str = Field(..., description="Name of the identified dish")
    estimated_weight_g: Optional[float] = Field(default=None, description="Estimated weight of the dish in grams")
    calories: float = Field(..., description="Estimated calories of the dish in kcal")
    protein_g: Optional[float] = Field(default=None, description="Estimated protein in grams")
    carbs_g: Optional[float] = Field(default=None, description="Estimated carbohydrates in grams")
    fat_g: Optional[float] = Field(default=None, description="Estimated fat in grams")
    ingredients: List[str] = Field(default_factory=list, description="List of identified ingredients in this dish")

class FoodAnalysisData(BaseModel):
    dishes: List[DishDetail] = Field(default_factory=list, description="List of dishes identified in the image")
    total_calories: float = Field(..., description="Total estimated calories across all dishes")
    people_count: int = Field(default=1, description="Number of people sharing the food")
    calories_per_person: float = Field(..., description="Total calories divided by people_count")
    confidence: str = Field(..., description="Confidence level of the estimation: high, medium, or low")
