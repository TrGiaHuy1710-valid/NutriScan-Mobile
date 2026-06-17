# Nutrition AI Backend Service

A production-ready MVP backend service for food photo calorie estimation, ingredient analysis, and barcode nutrition lookup. Powered by FastAPI, Google Gemini 2.5 Flash, and OpenFoodFacts.

---

## Project Structure

```text
backend/
├── app/
│   ├── main.py                 # FastAPI application and error middleware
│   ├── routers/                # Routing API Controllers
│   │   ├── __init__.py
│   │   ├── barcode.py          # Barcode lookup controller
│   │   ├── food.py             # Food photo estimation controller
│   │   ├── health.py           # Status checks (health & root)
│   │   └── ingredients.py      # Text & Image ingredient list controller
│   ├── schemas/                # Pydantic v2 validation models
│   │   ├── __init__.py
│   │   ├── barcode.py
│   │   ├── common.py
│   │   ├── food.py
│   │   └── ingredient.py
│   ├── services/               # Orchestration and AI logic
│   │   ├── __init__.py
│   │   ├── barcode_service.py  # OpenFoodFacts API service
│   │   ├── fallback_service.py # Standard fallback payload builders
│   │   ├── food_service.py     # Image check and calorie router
│   │   ├── gemini_service.py   # Async Gemini API integrations
│   │   └── ingredient_service.py
│   └── utils/                  # Core helpers and database configuration
│       ├── __init__.py
│       ├── config.py           # Environment variable settings
│       ├── database.py         # SQLAlchemy & SQLite database schema
│       ├── exceptions.py       # Standard HTTP error types
│       └── logger.py           # Rotating structured logger to logs/app.log
├── logs/
│   └── app.log                 # Generated application runtime logs
├── requirements.txt            # Python dependencies
├── .env.example                # Config template file
├── .env                        # Local configurations
├── run.py                      # Server bootsrap script
├── start_ngrok.sh              # FastAPI & Ngrok process starter
├── start_tmux.sh               # Detached tmux session manager
├── api_document.md             # API technical specifications
└── README.md                   # Setup guide
```

---

## Requirements

* Python 3.11+
* SQLite 3
* Ngrok (optional, for exposing the API to physical devices)
* Tmux (optional, for background deployments)

---

## Installation & Setup

1. **Clone/Navigate to the Backend Directory:**
   ```bash
   cd backend
   ```

2. **Create a Virtual Environment (Recommended):**
   ```bash
   python -m venv venv
   # On Windows:
   .\venv\Scripts\activate
   # On Linux/macOS:
   source venv/bin/activate
   ```

3. **Install Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Setup Environment Configurations:**
   Copy `.env.example` to `.env` and fill in your Gemini API Key and Ngrok credentials:
   ```bash
   cp .env.example .env
   ```
   Edit `.env`:
   ```env
   GEMINI_API_KEY=AIzaSyYourKeyHere...
   NGROK_AUTHTOKEN=YourNgrokTokenHere...
   DATABASE_URL=sqlite:///nutrition.db
   APP_ENV=development
   ```

---

## Running the Server

### 1. Standard Local Mode
This executes the server locally with auto-reload activated in development mode:
```bash
python run.py
```
* Interactive Docs: [http://localhost:8000/docs](http://localhost:8000/docs)
* Health Status: [http://localhost:8000/health](http://localhost:8000/health)

### 2. Ngrok Public Tunnel Mode
If you are developing a mobile app (Flutter) on a physical phone or external simulator, start both FastAPI and Ngrok to retrieve a public HTTPS URL:
```bash
chmod +x start_ngrok.sh
./start_ngrok.sh
```
This script will:
* Launch FastAPI in the background
* Start Ngrok on port 8000
* Fetch the public URL via Ngrok API and display it:
  ```text
  ==================================================
  Ngrok Tunnel active!
  FastAPI public endpoint: https://xxxx.ngrok-free.app
  FastAPI Swagger Docs:    https://xxxx.ngrok-free.app/docs
  ==================================================
  ```

### 3. Tmux Production/Background Mode
If deploying on a Linux development machine, launch FastAPI and Ngrok in a detached multi-pane window session:
```bash
chmod +x start_tmux.sh
./start_tmux.sh
```
To monitor execution or interact, attach using:
```bash
tmux attach -t nutrition-api
```

---

## API Usage & Curl Examples

### 1. Check health
```bash
curl -X GET http://localhost:8000/health
```

### 2. Lookup barcode
```bash
curl -X POST http://localhost:8000/api/v1/barcode/analyze \
  -H "Content-Type: application/json" \
  -d '{"barcode": "8938505974191"}'
```

### 3. Analyze ingredients (JSON Text list)
```bash
curl -X POST http://localhost:8000/api/v1/ingredients/analyze \
  -H "Content-Type: application/json" \
  -d '{"ingredients": ["chicken breast", "broccoli", "rice"]}'
```

### 4. Analyze food (Image file)
```bash
curl -X POST http://localhost:8000/api/v1/food/analyze \
  -F "image=@/path/to/food_photo.jpg" \
  -F "people_count=2"
```

---

## Troubleshooting

1. **SQLite Database is locked or inaccessible:**
   Verify no other instances of the backend are open, or reset the file:
   ```bash
   rm nutrition.db
   ```
2. **Ngrok API fails with `4040/api/tunnels` error:**
   Wait an extra second for Ngrok client initialization or run `ngrok http 8000` manually in a separate shell window.
3. **Gemini returns invalid JSON format:**
   The backend uses prompt-based JSON enforcement and validates the results on the server using Pydantic. If the model returns malformed JSON or invalid structures, the wrapper catches this, raises a `GEMINI_INVALID_RESPONSE` error, and automatically triggers the safe manual input fallback.

