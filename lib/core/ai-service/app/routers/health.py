from fastapi import APIRouter

router = APIRouter(tags=["System"])

@router.get("/health")
async def health_check():
    """
    Simple application health check endpoint.
    """
    return {"status": "healthy"}

@router.get("/")
async def root():
    """
    Root endpoint returning backend metadata.
    """
    return {
        "name": "Nutrition AI Backend",
        "version": "1.0.0"
    }
