
#!/bin/bash

set -e

echo "Changing to script directory..."
cd "$(dirname "$0")" 
echo "Current directory: $(pwd)"

echo "Creating virtual environment..."
mkdir -p env


if [ ! -d "env/bin" ]; then
    python3 -m venv env
else
    echo "Virtual environment already exists."    
fi


echo "Activating virtual environment..."
source env/bin/activate  

echo "Current directory: $(pwd)"

if [ -f "../app/requirements.txt" ]; then
    echo "Found requirements.txt, installing dependencies..."
    pip install --cache-dir=/var/lib/jenkins/.cache/pip -r ../app/requirements.txt -v
else
    echo "requirements.txt not found!"
    exit 1
fi


echo "Upgrading pip..."
python -m pip install --upgrade pip

deactivate
