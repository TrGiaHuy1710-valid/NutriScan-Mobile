from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.utils.database import get_db
from app.schemas.barcode import BarcodeRequest
from app.services.barcode_service import BarcodeService

router = APIRouter(prefix="/api/v1/barcode", tags=["Barcode"])

def get_barcode_service():
    return BarcodeService()

@router.post("/analyze")
async def analyze_barcode(
    payload: BarcodeRequest,
    db: Session = Depends(get_db),
    barcode_service: BarcodeService = Depends(get_barcode_service)
):
    """
    Looks up nutrition facts for a given barcode using the OpenFoodFacts database.
    """
    result = await barcode_service.lookup_barcode(
        barcode=payload.barcode,
        db=db
    )
    return result
