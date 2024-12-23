
#!/bin/bash

# Create and activate a virtual environment for testing in Jenkins
mkdir -p app
cd app

if [ -d "env" ]; then
    echo "Removing existing virtual environment..."
    rm -rf env
fi

python3 -m venv env
echo "Virtual environment created in: $(pwd)/env"

ls -la env/bin/

source env/bin/activate  

echo "Using Python: $(which python)"
echo "Python Version: $(python --version)"

# Install dependencies from requirements.txt for testing
python3 -m pip install --upgrade pip && pip install --cache-dir=/var/lib/jenkins/.cache/pip -r ../requirements.txt

# Deactivate the virtual environment after the tests are complete
deactivate
