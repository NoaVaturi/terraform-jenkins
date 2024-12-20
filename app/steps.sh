
#!/bin/bash

set -xe

cd "$(dirname "$0")" 
echo "Changed to directory: $(pwd)"


mkdir -p env


if [ ! -d "env/bin" ]; then
    python3 -m venv env
else
    echo "Virtual environment already exists."    
fi


echo "Activating virtual environment."
source env/bin/activate  

echo "Using Python from: $(which python)"
echo "Python version: $(python --version)"

echo "Current directory: $(pwd)"


if [ -f "requirements.txt" ]; then
    echo "Found requirements.txt, installing dependencies."
    pip install --cache-dir=/var/lib/jenkins/.cache/pip -r requirements.txt -v
else
    echo "requirements.txt not found."
    exit 1
fi


echo "Upgrading pip..."
python -m pip install --upgrade pip

deactivate
