#! /bin/bash

# Variables
BUCKET_NAME="assignment-bucket-09"
PROJECT_DIR="/home/projects/assignment_files"
PROJECT_PARENT_DIR="/home/projects"
PROJECT_SRC="https://github.com/3rdsenin/assignment_files.git"
BUCKET_iNDEX="https://assignment-bucket-09.s3.eu-west-1.amazonaws.com/index.html"

deploy_app() {
  echo "Deploying to S3"
  aws s3 cp "$PROJECT_DIR" "s3://$BUCKET_NAME" --recursive --exclude "$PROJECT_DIR/.git/*"
  echo "Deploying to EC2"
  sudo cp -r * /var/www/html/
  echo "Application available at $BUCKET_iNDEX OR http://$(curl icanhazip.com)"
}

if [ -d "$PROJECT_DIR" ]; then
  echo "Folder exists, Pulling new changes..."
  cd "$PROJECT_DIR"
  sudo git pull origin main
  deploy_app
else
  sudo mkdir -p "$PROJECT_PARENT_DIR"
  echo "Folder created"
  cd "$PROJECT_PARENT_DIR"
  sudo git clone "$PROJECT_SRC"
  cd "$PROJECT_DIR"
  deploy_app
fi
