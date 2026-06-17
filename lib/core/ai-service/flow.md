# AGENT.md

## Role

You are a senior Backend Engineer, AI Engineer, and Production Architect.

Build a production-ready MVP backend service for nutrition analysis using:

* Python 3.11+
* FastAPI
* Gemini 2.5 Flash
* OpenFoodFacts
* Pydantic v2
* Uvicorn
* Ngrok support
* Tmux deployment support

Do NOT use:

* LangGraph
* LangChain
* Celery
* Kubernetes
* Docker Swarm

Keep architecture simple and maintainable.

---

# Goal

Build a backend service that supports:

1. Food image calorie estimation
2. Ingredient health analysis
3. Barcode nutrition lookup

All endpoints must support:

* graceful fallback
* validation
* structured error responses
* manual user input fallback

---

# Tech Stack

Backend:

* FastAPI
* Python

AI:

* Gemini 2.5 Flash

External APIs:

* OpenFoodFacts

Storage:

* SQLite

Deployment:

* Ngrok
* Tmux

Documentation:

* Swagger
* OpenAPI
* Markdown API docs

---

# Folder Structure

backend/

app/

routers/

food.py

ingredients.py

barcode.py

health.py

services/

gemini_service.py

food_service.py

ingredient_service.py

barcode_service.py

fallback_service.py

schemas/

food.py

ingredient.py

barcode.py

common.py

utils/

response.py

logger.py

database.py

config.py

main.py

requirements.txt

.env.example

run.py

start_tmux.sh

start_ngrok.sh

api_document.md

README.md

---

# Environment Variables

Create .env.example

GEMINI_API_KEY=

NGROK_AUTHTOKEN=

DATABASE_URL=sqlite:///nutrition.db

APP_ENV=development

---

# API 1

POST /api/v1/food/analyze

multipart/form-data

Fields:

image
people_count

Process:

Validate image

Call Gemini

Prompt Gemini to:

1. identify dishes

2. identify ingredients

3. estimate calories

4. estimate confidence

5. estimate calories per person

Return JSON only

Gemini response must be converted into strongly typed Pydantic models.

---

# API 1 Response

{
"success": true,
"status": "completed",
"data": {
"dishes": [],
"total_calories": 0,
"people_count": 1,
"calories_per_person": 0,
"confidence": "high"
}
}

---

# Food Fallback

If Gemini:

* timeout
* quota exceeded
* invalid image
* low confidence

Return:

{
"success": false,
"status": "manual_input_required",
"message": "Unable to estimate calories accurately.",
"manual_fields": [
"dish_name",
"estimated_weight"
]
}

---

# API 2

POST /api/v1/ingredients/analyze

Support:

A.

multipart image upload

B.

json ingredient list

Request example:

{
"ingredients": [
"chicken breast",
"rice",
"broccoli"
]
}

Gemini should analyze:

benefits
risks
health score

Return structured JSON.

---

# Ingredient Response

{
"success": true,
"status": "completed",
"data": {
"ingredients": [],
"overall_score": 85
}
}

---

# Ingredient Fallback

If image unclear:

{
"success": false,
"status": "manual_input_required",
"manual_fields": [
"ingredient_list"
]
}

---

# API 3

POST /api/v1/barcode/analyze

Request:

{
"barcode": "8938505974191"
}

Flow:

1. validate barcode

2. query OpenFoodFacts

3. parse response

4. return nutrition

---

# Barcode Response

{
"success": true,
"status": "completed",
"data": {
"product_name": "",
"nutrition_grade": "",
"energy_kcal": 0,
"protein": 0,
"fat": 0,
"sugar": 0
}
}

---

# Barcode Fallback

If not found:

{
"success": false,
"status": "barcode_not_found",
"manual_input_required": true,
"fields": [
"product_name",
"ingredients"
]
}

---

# Health Endpoint

GET /health

Response:

{
"status": "healthy"
}

---

# Root Endpoint

GET /

Response:

{
"name": "Nutrition AI Backend",
"version": "1.0.0"
}

---

# Gemini Service Requirements

Implement GeminiService class.

Methods:

analyze_food()

analyze_ingredients()

Requirements:

* timeout handling
* retries
* structured JSON parsing
* response validation

Never return raw Gemini text.

Always parse into Pydantic models.

---

# Error Handling

Create global exception middleware.

Error format:

{
"success": false,
"error_code": "",
"message": ""
}

Supported codes:

GEMINI_TIMEOUT

GEMINI_QUOTA_EXCEEDED

GEMINI_INVALID_RESPONSE

IMAGE_TOO_LARGE

IMAGE_NOT_SUPPORTED

BARCODE_NOT_FOUND

MANUAL_INPUT_REQUIRED

UNKNOWN_ERROR

---

# Logging

Create structured logging.

Log:

request_id

endpoint

latency

status

error

Save logs to logs/app.log

---

# SQLite

Create SQLite database.

Tables:

analysis_history

Columns:

id

analysis_type

created_at

status

input_summary

output_summary

Store successful requests.

---

# Swagger

Enable:

/docs

/redoc

OpenAPI tags:

Food

Ingredients

Barcode

System

---

# Ngrok Support

Create:

start_ngrok.sh

Requirements:

1.

Start FastAPI

2.

Start Ngrok

3.

Print public URL

Example:

https://xxxxx.ngrok-free.app

---

# Tmux Support

Create:

start_tmux.sh

Requirements:

tmux new-session

Run uvicorn

Run ngrok

Keep service alive

Output instructions for attaching:

tmux attach -t nutrition-api

---

# Run Script

Create run.py

Behavior:

* verify env variables
* create database
* launch FastAPI

---

# API Documentation

Generate api_document.md

Include:

Authentication

Endpoints

Request examples

Response examples

Fallback behavior

Error codes

Swagger usage

Ngrok usage

---

# README

Generate complete README.md

Include:

installation

local development

ngrok deployment

tmux deployment

API examples

curl examples

project structure

troubleshooting

---

# Quality Requirements

Use:

* type hints
* async endpoints
* dependency injection
* Pydantic v2

Code must be:

* production-ready
* modular
* readable

Generate all files completely.

No placeholders.

No TODO comments.

Return entire project source code.
