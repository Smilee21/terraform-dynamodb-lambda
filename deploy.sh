#!/bin/bash

# Inicializar variables para monitorear el progreso
frontend_status="NOT STARTED"
lambda_deps_status="NOT STARTED"
lambda_compress_status="NOT STARTED"
terraform_init_status="NOT STARTED"
terraform_plan_status="NOT STARTED"

echo "Starting deployment process..."

# 1. Construir el frontend
echo "Building frontend..."
cd frontend
if [ $? -eq 0 ]; then
    npm install && npm run build
    if [ $? -eq 0 ]; then
        frontend_status="SUCCESS"
    else
        frontend_status="FAILED"
        echo "Frontend build failed. Continuing with other steps..."
    fi
    cd ..
else
    frontend_status="FAILED"
    echo "Failed to enter 'frontend' directory. Continuing with other steps..."
fi

# 2. Instalar dependencias de Lambda si requirements.txt no está vacío
echo "Installing Lambda dependencies..."
cd lambda
if [ $? -eq 0 ]; then
    if [ -f "requirements.txt" ] && [ -s "requirements.txt" ]; then
        pip install -r requirements.txt -t ./
        if [ $? -eq 0 ]; then
            lambda_deps_status="SUCCESS"
        else
            lambda_deps_status="FAILED"
            echo "Python dependencies installation failed. Continuing with other steps..."
        fi
    else
        echo "No requirements.txt or file is empty. Skipping dependency installation."
        lambda_deps_status="SKIPPED"
    fi

    # 3. Comprimir los archivos del Lambda
    echo "Compressing Lambda files..."
    zip -r function.zip . -x "*.zip" "__pycache__/*"
    if [ $? -eq 0 ]; then
        lambda_compress_status="SUCCESS"
    else
        lambda_compress_status="FAILED"
        echo "Failed to compress Lambda files. Continuing with other steps..."
    fi
    cd ..
else
    lambda_deps_status="FAILED"
    lambda_compress_status="FAILED"
    echo "Failed to enter 'lambda' directory. Continuing with other steps..."
fi

# 4. Inicializar Terraform
echo "Initializing Terraform..."
terraform init
if [ $? -eq 0 ]; then
    terraform_init_status="SUCCESS"
else
    terraform_init_status="FAILED"
    echo "Terraform initialization failed. Continuing with Terraform plan..."
fi

# 5. Generar plan de Terraform
echo "Creating Terraform plan..."
terraform plan
if [ $? -eq 0 ]; then
    terraform_plan_status="SUCCESS"
else
    terraform_plan_status="FAILED"
    echo "Terraform plan creation failed."
fi

# Resumen del estado del proceso
echo "Deployment process completed!"
echo "===================================="
echo "Frontend Build:          $frontend_status"
echo "Lambda Dependencies:     $lambda_deps_status"
echo "Lambda Compression:      $lambda_compress_status"
echo "Terraform Initialization: $terraform_init_status"
echo "Terraform Plan:          $terraform_plan_status"
echo "===================================="
