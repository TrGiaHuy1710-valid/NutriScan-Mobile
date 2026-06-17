from typing import Any, Optional
from pydantic import BaseModel

class StandardResponse(BaseModel):
    success: bool
    status: str
    data: Optional[Any] = None
    message: Optional[str] = None

class ErrorResponse(BaseModel):
    success: bool = False
    error_code: str
    message: str
