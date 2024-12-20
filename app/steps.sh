
#!/bin/bash

mkdir -p env_app
cd env_app

python3 -m venv env  
source env/bin/activate  

python3 -m pip install --upgrade pip && pip install -r ../requirements.txt -v


if [ -n "$VIRTUAL_ENV" ]; then
    deactivate
    echo "Virtual environment deactivated."
else
    echo "Virtual environment was not activated."
fi
