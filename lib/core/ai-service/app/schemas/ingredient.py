from typing import List, Optional
from pydantic import BaseModel, Field

class IngredientAnalysisDetail(BaseModel):
    name: str = Field(..., description="Name of the ingredient")
    benefits: List[str] = Field(default_factory=list, description="List of health benefits")
    risks: List[str] = Field(default_factory=list, description="List of potential health risks or alerts")
    score: int = Field(..., description="Individual health score from 0 to 100")

class IngredientAnalysisData(BaseModel):
    ingredients: List[IngredientAnalysisDetail] = Field(default_factory=list, description="List of ingredients analyzed")
    overall_score: int = Field(..., description="Overall health score of the food from 0 to 100")

class IngredientTextRequest(BaseModel):
    ingredients: List[str] = Field(..., description="List of ingredients to analyze")
