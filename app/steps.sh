
#!/bin/bash

# Change to the directory where the script is located
cd "$(dirname "$0")" 

mkdir -p env

if [ ! -d "env/bin" ]; then
    python3 -m venv env
else
    echo "Virtual environment already exists."    
fi

source env/bin/activate  

echo "Current directory: $(pwd)"

if [ -f "../app/requirements.txt" ]; then
    echo "Found requirements.txt, installing dependencies..."
    pip install --cache-dir=/var/lib/jenkins/.cache/pip -r ../app/requirements.txt -v
else
    echo "requirements.txt not found!"
    exit 1
fi

python -m pip install --upgrade pip

# Deactivate the virtual environment after the tests are complete
deactivate
