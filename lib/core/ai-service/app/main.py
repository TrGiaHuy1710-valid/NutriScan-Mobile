import time
import uuid
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from starlette.middleware.base import BaseHTTPMiddleware

from app.utils.config import settings
from app.utils.logger import logger
from app.utils.database import init_db
from app.utils.exceptions import NutritionAppException
from app.routers import food, ingredients, barcode, health

# Initialize Database Schema on start
init_db()

app = FastAPI(
    title="Nutrition AI Backend",
    description="Production-ready MVP backend service for food, ingredient, and barcode nutrition analysis.",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Custom Logging Middleware
class StructuredLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        request_id = str(uuid.uuid4())
        request.state.request_id = request_id
        start_time = time.time()
        
        response = None
        error_details = None
        
        try:
            response = await call_next(request)
            return response
        except Exception as e:
            error_details = str(e)
            raise e
        finally:
            latency_ms = (time.time() - start_time) * 1000
            status_code = response.status_code if response else 500
            
            # Log format: request_id | endpoint | latency | status | error
            log_line = (
                f"req_id={request_id} | "
                f"method={request.method} | "
                f"path={request.url.path} | "
                f"status={status_code} | "
                f"latency={latency_ms:.2f}ms"
            )
            if error_details:
                log_line += f" | error={error_details}"
                logger.error(log_line)
            elif status_code >= 400:
                logger.warning(log_line)
            else:
                logger.info(log_line)

app.add_middleware(StructuredLoggingMiddleware)

# --- GLOBAL EXCEPTION HANDLERS ---

@app.exception_handler(NutritionAppException)
async def nutrition_app_exception_handler(request: Request, exc: NutritionAppException):
    logger.error(f"AppException [{exc.error_code}]: {exc.message} on path {request.url.path}")
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error_code": exc.error_code,
            "message": exc.message
        }
    )

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = exc.errors()
    message = "; ".join([f"{'.'.join(str(loc) for loc in err['loc'])}: {err['msg']}" for err in errors])
    logger.warning(f"ValidationError: {message} on path {request.url.path}")
    return JSONResponse(
        status_code=status.HTTP_400_BAD_REQUEST,
        content={
            "success": False,
            "error_code": "VALIDATION_ERROR",
            "message": f"Input validation failed: {message}"
        }
    )

@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    logger.warning(f"HTTPException [{exc.status_code}]: {exc.detail} on path {request.url.path}")
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error_code": "HTTP_ERROR",
            "message": exc.detail
        }
    )

@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    logger.error(f"UnhandledException: {str(exc)} on path {request.url.path}", exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "error_code": "UNKNOWN_ERROR",
            "message": "An unexpected server error occurred. Please try again."
        }
    )

# --- REGISTER ROUTERS ---
# Health and root routes
app.include_router(health.router)
# Feature routes
app.include_router(food.router)
app.include_router(ingredients.router)
app.include_router(barcode.router)
