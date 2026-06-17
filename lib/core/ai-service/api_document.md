# Nutrition AI API Documentation

This API is designed to support the **HealTrack Daily** application by providing backend endpoints for:
1. Food image calorie estimation
2. Ingredient health analysis (from text and labels)
3. Barcode nutrition lookup

---

## Base URL
* Local development: `http://localhost:8000`
* Public Ngrok URL: `https://<your-subdomain>.ngrok-free.app`

---

## Authentication
This MVP version does not require API keys or bearer tokens for client request authentication. However, the backend requires a valid `GEMINI_API_KEY` set in its `.env` file to communicate with Google Gemini models.

---

## Swagger & OpenAPI Docs
FastAPI automatically compiles and generates interactive document pages:
* **Swagger UI:** `/docs` (Recommended for testing)
* **ReDoc:** `/redoc`

---

## Endpoint Specifications

### 1. GET `/`
Root endpoint to check backend status.

* **Response Example:**
  ```json
  {
    "name": "Nutrition AI Backend",
    "version": "1.0.0"
  }
  ```

---

### 2. GET `/health`
Health check endpoint.

* **Response Example:**
  ```json
  {
    "status": "healthy"
  }
  ```

---

### 3. POST `/api/v1/food/analyze`
Estimates dishes, ingredients, and calories from an uploaded food photo.

* **Content-Type:** `multipart/form-data`
* **Request Fields:**
  * `image`: Binary file (Supported: `.jpg`, `.jpeg`, `.png`, `.webp`, `.heic`)
  * `people_count`: Integer (Optional, default: `1`)
* **Success Response (Status: `completed`):**
  ```json
  {
    "success": true,
    "status": "completed",
    "data": {
      "dishes": [
        {
          "name": "Grilled Chicken Breast Salad",
          "estimated_weight_g": 350.0,
          "calories": 420.0,
          "protein_g": 35.0,
          "carbs_g": 12.0,
          "fat_g": 15.0,
          "ingredients": ["chicken breast", "lettuce", "cherry tomatoes", "olive oil"]
        }
      ],
      "total_calories": 420.0,
      "people_count": 1,
      "calories_per_person": 420.0,
      "confidence": "high"
    }
  }
  ```
* **Fallback Response (Status: `manual_input_required`):**
  Triggered if Gemini fails (e.g. timeout, quota, unparseable response) or determines confidence is **low**.
  ```json
  {
    "success": false,
    "status": "manual_input_required",
    "message": "Unable to estimate calories accurately.",
    "manual_fields": [
      "dish_name",
      "estimated_weight"
    ]
  }
  ```

---

### 4. POST `/api/v1/ingredients/analyze`
Analyzes ingredients either by uploading an image of a label/packaging or sending a text list.

* **Supported Requests:**
  * **Option A: JSON list of ingredients**
    * **Content-Type:** `application/json`
    * **Body:**
      ```json
      {
        "ingredients": [
          "chicken breast",
          "white rice",
          "broccoli"
        ]
      }
      ```
  * **Option B: Image upload**
    * **Content-Type:** `multipart/form-data`
    * **Field:** `image` (Binary file of nutrition packaging label)

* **Success Response (Status: `completed`):**
  ```json
  {
    "success": true,
    "status": "completed",
    "data": {
      "ingredients": [
        {
          "name": "chicken breast",
          "benefits": ["high lean protein", "muscle recovery"],
          "risks": ["salmonella risk if undercooked"],
          "score": 95
        },
        {
          "name": "white rice",
          "benefits": ["quick carbohydrate source", "easy digestion"],
          "risks": ["spikes blood sugar if eaten in excess"],
          "score": 70
        }
      ],
      "overall_score": 82
    }
  }
  ```
* **Fallback Response (Status: `manual_input_required`):**
  Triggered if the image is unclear or the analysis fails.
  ```json
  {
    "success": false,
    "status": "manual_input_required",
    "manual_fields": [
      "ingredient_list"
    ]
  }
  ```

---

### 5. POST `/api/v1/barcode/analyze`
Performs a barcode query against the OpenFoodFacts database.

* **Content-Type:** `application/json`
* **Body Example:**
  ```json
  {
    "barcode": "8938505974191"
  }
  ```
* **Success Response (Status: `completed`):**
  ```json
  {
    "success": true,
    "status": "completed",
    "data": {
      "product_name": "Greek Yogurt Plain",
      "nutrition_grade": "a",
      "energy_kcal": 130.0,
      "protein": 12.0,
      "fat": 2.5,
      "sugar": 4.0
    }
  }
  ```
* **Fallback Response (Status: `barcode_not_found`):**
  Triggered if the barcode is invalid or does not exist in the OpenFoodFacts directory.
  ```json
  {
    "success": false,
    "status": "barcode_not_found",
    "manual_input_required": true,
    "fields": [
      "product_name",
      "ingredients"
    ]
  }
  ```

---

## Global Exception Codes
If a request fails with an HTTP error status (4xx or 5xx), the response body is formatted as:
```json
{
  "success": false,
  "error_code": "GEMINI_TIMEOUT",
  "message": "Detailed error message"
}
```

### Supported Error Codes:
* `GEMINI_TIMEOUT` (504 Gateway Timeout): Gemini API call timed out.
* `GEMINI_QUOTA_EXCEEDED` (429 Too Many Requests): Gemini API limit reached or key not configured.
* `GEMINI_INVALID_RESPONSE` (502 Bad Gateway): Gemini API returned empty/invalid JSON, or the JSON failed backend model validation constraints.
* `IMAGE_TOO_LARGE` (400 Bad Request): Image file exceeds 10MB size limit.
* `IMAGE_NOT_SUPPORTED` (400 Bad Request): File format is not standard image mime-type (JPEG, PNG, WEBP, HEIC).
* `BARCODE_NOT_FOUND` (404 Not Found): Barcode failed lookup and has been logged for manual fallback.
* `VALIDATION_ERROR` (400 Bad Request): Request parameters or request body failed type or formatting constraints.
* `HTTP_ERROR` (4xx): Base router/server redirection or missing path issues.
* `UNKNOWN_ERROR` (500 Internal Server Error): Unexpected system crash.

---

## Technical Notes (AI JSON Generation & Backend Validation)

### Prompt-based JSON Enforcement
To avoid schema compatibility errors with the Gemini API (specifically the `Unknown field for Schema: default` error generated when using Pydantic models directly as `response_schema` in `GenerationConfig`), the backend implements prompt-based JSON enforcement.

1. The API calls the Gemini 2.5 Flash model with an explicit description of the expected output JSON structure inside the prompt.
2. The config is set to `response_mime_type="application/json"` to ensure the model outputs a valid JSON string.

### Backend Sanitization and Validation Flow
Once a response is returned by the Gemini API, the following pipeline is executed:

1. **Sanitization:** The `safe_parse_gemini_json` utility cleans the output, strips whitespace, and removes markdown code block fences (e.g. ` ```json ... ``` `) if present.
2. **Parsing:** The string is loaded into a dictionary using Python's native `json.loads`.
3. **Validation:** The dictionary is validated against the target Pydantic schemas (`FoodAnalysisData` or `IngredientAnalysisData`) using `.model_validate()`.
4. **Fallback Execution:** If any stage of sanitization, parsing, or validation fails, the system logs the incident and returns the standard `manual_input_required` fallback payload with a success status of `false`, allowing the mobile client to render manual inputs gracefully.

