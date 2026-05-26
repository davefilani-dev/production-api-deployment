#!/bin/bash

PROJECT_NAME="production-api-deployment"

echo "Creating project structure..."

mkdir -p $PROJECT_NAME/app/routes
mkdir -p $PROJECT_NAME/deployment/nginx
mkdir -p $PROJECT_NAME/deployment/systemd
mkdir -p $PROJECT_NAME/tests
mkdir -p $PROJECT_NAME/scripts

touch $PROJECT_NAME/app/main.py
touch $PROJECT_NAME/app/__init__.py
touch $PROJECT_NAME/app/routes/api.py
touch $PROJECT_NAME/app/routes/__init__.py
touch $PROJECT_NAME/tests/__init__.py

touch $PROJECT_NAME/requirements.txt
touch $PROJECT_NAME/README.md
touch $PROJECT_NAME/.gitignore
touch $PROJECT_NAME/.env.example

touch $PROJECT_NAME/deployment/nginx/personal-api.conf
touch $PROJECT_NAME/deployment/systemd/personal-api.service

touch $PROJECT_NAME/tests/test_api.py

echo "Initializing Git repository.."

cd $PROJECT_NAME || exit

git init

echo "Creating Python virtual environment..."

python3 -m venv venv

echo "Activating virtual environment.."

source venv/bin/activate

echo "Installing dependencies..."

pip install fastapi uvicorn pytest httpx

pip freeze > requirements.txt

echo "Creating initial .gitignore..."

cat <<EOF >.gitignore

venv/
_pycache_/
*.pyc
.env
EOF

echo "Project setup complete."




