
#!/bin/bash

set -xe

cd "$(dirname "$0")/.." 
echo "Changed to project root directory: $(pwd)"


echo "Removing existing virtual environment."
rm -rf env


echo "Cleaning up .pyc files."
find . -name "*.pyc" -exec rm -f {} \;


echo "Creating virtual environment."
python3 -m venv env


echo "Using Python from: $(which python3)"
echo "Python version: $(python3 --version)"


echo "Activating virtual environment."
source env/bin/activate  


python3 -m pip install --upgrade pip


echo "Environment activated. Using Python from: $(which python3)"
echo "Current Python version: $(python3 --version)"


pip install -r app/requirements.txt -v


echo "Deactivating virtual environment."
if [ -n "$VIRTUAL_ENV" ]; then
    deactivate
    echo "Virtual environment deactivated."
else
    echo "Virtual environment was not activated."
fi


echo "Virtual environment deactivated."
