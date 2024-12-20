
#!/bin/bash

set -xe

cd "$(dirname "$0")/.." 
echo "Changed to project root directory: $(pwd)"


mkdir -p env


if [ ! -d "env/bin" ]; then
    python3 -m venv env
else
    echo "Virtual environment already exists."    
fi


echo "Using Python from: $(which python3)"
echo "Python version: $(python3 --version)"


echo "Activating virtual environment."
source env/bin/activate  


python3 -m pip install --upgrade pip


echo "Environment activated. Using Python from: $(which python3)"
echo "Current Python version: $(python3 --version)"



if [ -f "app/requirements.txt" ]; then
    echo "Found requirements.txt, installing dependencies."
    pip install --cache-dir=/var/lib/jenkins/.cache/pip -r app/requirements.txt -v
else
    echo "requirements.txt not found."
    exit 1
fi


echo "Deactivating virtual environment."
deactivate

echo "Virtual environment deactivated."
