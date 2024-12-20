
#!/bin/bash

# Create and activate a virtual environment for testing in Jenkins
mkdir -p env_app
cd env_app

python3 -m venv env  
source env/bin/activate  

# Install dependencies from requirements.txt for testing
python3 -m pip install --upgrade pip && pip install --cache-dir=/var/lib/jenkins/.cache/pip -r a../requirements.txt -v

# Deactivate the virtual environment after the tests are complete
deactivate
