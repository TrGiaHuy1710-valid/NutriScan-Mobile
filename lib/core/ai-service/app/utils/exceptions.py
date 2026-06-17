class NutritionAppException(Exception):
    """Base exception for the nutrition application."""
    def __init__(self, error_code: str, message: str, status_code: int = 400):
        self.error_code = error_code
        self.message = message
        self.status_code = status_code
        super().__init__(message)

class GeminiTimeoutException(NutritionAppException):
    def __init__(self, message: str = "Gemini API request timed out."):
        super().__init__("GEMINI_TIMEOUT", message, 504)

class GeminiQuotaExceededException(NutritionAppException):
    def __init__(self, message: str = "Gemini API quota exceeded."):
        super().__init__("GEMINI_QUOTA_EXCEEDED", message, 429)

class GeminiInvalidResponseException(NutritionAppException):
    def __init__(self, message: str = "Gemini API returned an invalid response."):
        super().__init__("GEMINI_INVALID_RESPONSE", message, 502)

class ImageTooLargeException(NutritionAppException):
    def __init__(self, message: str = "Uploaded image is too large."):
        super().__init__("IMAGE_TOO_LARGE", message, 400)

class ImageNotSupportedException(NutritionAppException):
    def __init__(self, message: str = "Uploaded image format is not supported."):
        super().__init__("IMAGE_NOT_SUPPORTED", message, 400)

class BarcodeNotFoundException(NutritionAppException):
    def __init__(self, message: str = "Barcode not found in database."):
        super().__init__("BARCODE_NOT_FOUND", message, 404)

class ManualInputRequiredException(NutritionAppException):
    def __init__(self, message: str = "Manual input is required."):
        super().__init__("MANUAL_INPUT_REQUIRED", message, 400)
