#!/bin/bash
# Setup script for Voice Notes App
# Usage: ./setup_project.sh [repo_url] [target_dir]
set -e
REPO_URL="$1"
TARGET_DIR="$2"
if [ -z "$REPO_URL" ]; then
  echo "Usage: $0 <repository-url> [target-dir]" >&2
  exit 1
fi
if [ -z "$TARGET_DIR" ]; then
  TARGET_DIR="$(basename "$REPO_URL" .git)"
fi

echo "Cloning repository from $REPO_URL to $TARGET_DIR"
git clone "$REPO_URL" "$TARGET_DIR"
cd "$TARGET_DIR"

echo "Installing Node dependencies..."
npm install

if [ ! -f .env ]; then
  cat <<'EENV' > .env
VITE_API_KEY=replace-with-your-google-api-key
EENV
fi

echo "Setting up Python backend..."
cd backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
if [ ! -f .env ]; then
  cat <<'BENV' > .env
GOOGLE_API_KEY=replace-with-your-google-api-key
BENV
fi
deactivate

cat <<'EOF_MSG'
Setup complete.
Edit the following files and insert your API key values:
  - .env (frontend)
  - backend/.env (backend)

To start the backend server:
  source backend/venv/bin/activate
  uvicorn backend.main:app --reload --port 8000

In another terminal, start the frontend:
  npm run dev
EOF_MSG
