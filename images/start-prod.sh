#! /usr/bin/env sh
set -e

DEFAULT_MODULE_NAME=${MODULE_PATH:-main}
MODULE_NAME=${MODULE_NAME:-$DEFAULT_MODULE_NAME}

APP_VARIABLE_NAME=${VARIABLE_NAME:-app}
export APP_MODULE="${APP_MODULE:-"$MODULE_NAME:$APP_VARIABLE_NAME"}"

DEFAULT_GUNICORN_CONFIG=${DEFAULT_GUNICORN_CONFiG:-./gunicorn_conf.py}
export GUNICORN_CONFIG="${GUNICORN_CONFIG:-$DEFAULT_GUNICORN_CONFIG}"
export WORKER_CLASS="${WORKER_CLASS:-"uvicorn.workers.UvicornWorker"}"

# Specify SSL Key and Certificate explicitly
SSL_KEY_PATH=${SSL_KEY_PATH:-./ssl/selfsigned.key}
SSL_CERT_PATH=${SSL_CERT_PATH:-./ssl/selfsigned.crt}

# If there's a prestart.sh to be run,
# It is run before starting the application.
PRE_START_PATH=${PRE_START_PATH:-./prestart.sh}

echo "Checking for $PRE_START_PATH script"
if [ -f "$PRE_START_PATH" ]; then
    echo "Running $PRE_START_PATH script"
    . "$PRE_START_PATH"
else
    echo "There is no $PRE_START_PATH script"
fi

# First check for explicity SSL file then,
# Start the application with gunicorn.
if [ -f "$SSL_KEY_PATH" ] && [ -f "$SSL_CERT_PATH" ]; then
    exec gunicorn -k "$WORKER_CLASS" -c "$GUNICORN_CONFIG" --keyfile "$SSL_KEY_PATH" --certfile "$SSL_CERT_PATH" "$APP_MODULE"
else
    exec gunicorn -k "$WORKER_CLASS" -c "$GUNICORN_CONFIG" "$APP_MODULE"
fi
