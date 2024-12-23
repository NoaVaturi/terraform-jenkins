
#!/bin/bash

# Create and activate a virtual environment for testing in Jenkins
mkdir -p app
cd app

if [ ! -d "env" ]; then
    python3 -m venv env
fi

source env/bin/activate  

# Install dependencies from requirements.txt for testing
python3 -m pip install --upgrade pip && pip install --cache-dir=/var/lib/jenkins/.cache/pip -r ../requirements.txt

# Deactivate the virtual environment after the tests are complete
deactivate
