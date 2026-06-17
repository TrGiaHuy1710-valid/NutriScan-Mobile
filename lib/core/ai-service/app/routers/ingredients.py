from typing import Optional, List
import json
from fastapi import APIRouter, Request, Depends, HTTPException
from sqlalchemy.orm import Session
from app.utils.database import get_db
from app.services.ingredient_service import IngredientService
from app.services.gemini_service import GeminiService

router = APIRouter(prefix="/api/v1/ingredients", tags=["Ingredients"])

def get_ingredient_service():
    gemini = GeminiService()
    return IngredientService(gemini)

@router.post("/analyze")
async def analyze_ingredients(
    request: Request,
    db: Session = Depends(get_db),
    ingredient_service: IngredientService = Depends(get_ingredient_service)
):
    """
    Analyzes ingredients. Supports:
    1. **JSON ingredient list** (Content-Type: `application/json`)
       Body: `{"ingredients": ["chicken breast", "rice", "broccoli"]}`
    2. **Image upload of nutrition label** (Content-Type: `multipart/form-data`)
       Field: `image` (file)
    """
    content_type = request.headers.get("content-type", "")

    if "application/json" in content_type:
        try:
            body = await request.json()
            ingredients = body.get("ingredients")
            if not ingredients or not isinstance(ingredients, list):
                raise HTTPException(
                    status_code=400, 
                    detail="Invalid JSON structure. Expecting 'ingredients' as a list of strings."
                )
            # Ensure elements are strings
            ingredients_list = [str(x) for x in ingredients]
            return await ingredient_service.analyze_ingredients_from_text(ingredients_list, db)
        except json.JSONDecodeError:
            raise HTTPException(status_code=400, detail="Invalid JSON format.")

    elif "multipart/form-data" in content_type:
        form = await request.form()
        image_file = form.get("image")
        if not image_file or not hasattr(image_file, "read"):
            raise HTTPException(
                status_code=400, 
                detail="Missing file under field name 'image' in multipart request."
            )
        
        # In python-multipart, UploadFile is returned
        image_bytes = await image_file.read()
        return await ingredient_service.analyze_ingredients_from_image(
            image_bytes=image_bytes,
            content_type=image_file.content_type,
            db=db
        )
    else:
        raise HTTPException(
            status_code=415,
            detail="Unsupported Content-Type. Must be application/json or multipart/form-data."
        )
