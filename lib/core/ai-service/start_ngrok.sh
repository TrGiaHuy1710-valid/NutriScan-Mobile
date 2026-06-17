#!/bin/bash

# Load environment variables if .env exists
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | xargs)
fi

echo "Starting FastAPI in background..."
python run.py > fastapi.log 2>&1 &
FASTAPI_PID=$!

echo "Starting ngrok tunnel on port 8000..."
if [ -n "$NGROK_AUTHTOKEN" ] && [ "$NGROK_AUTHTOKEN" != "your_ngrok_authtoken_here" ]; then
  ngrok config add-authtoken "$NGROK_AUTHTOKEN"
fi

ngrok http 8000 > ngrok.log 2>&1 &
NGROK_PID=$!

# Wait for ngrok to initialize
echo "Waiting for ngrok to fetch public URL..."
sleep 3

# Fetch the public URL from the local ngrok client API
PUBLIC_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'https://[^"]*ngrok-free.app' | head -n 1)

if [ -n "$PUBLIC_URL" ]; then
  echo "=================================================="
  echo "Ngrok Tunnel active!"
  echo "FastAPI public endpoint: $PUBLIC_URL"
  echo "FastAPI Swagger Docs:    $PUBLIC_URL/docs"
  echo "=================================================="
else
  echo "Failed to retrieve ngrok public URL. Please check ngrok.log"
fi

# Maintain scripts running and trap exit
cleanup() {
  echo "Shutting down FastAPI (PID: $FASTAPI_PID) and Ngrok (PID: $NGROK_PID)..."
  kill $FASTAPI_PID $NGROK_PID 2>/dev/null
  exit 0
}

trap cleanup SIGINT SIGTERM

wait
