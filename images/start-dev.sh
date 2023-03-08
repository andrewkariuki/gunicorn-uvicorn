#! /usr/bin/env sh
set -e

DEFAULT_MODULE_NAME=${MODULE_PATH:-main}
MODULE_NAME=${MODULE_NAME:-$DEFAULT_MODULE_NAME}

APP_VARIABLE_NAME="${APP_VARIABLE_NAME:-app}"
export APP_MODULE="${APP_MODULE:-"$MODULE_NAME:$APP_VARIABLE_NAME"}"

HOST=${HOST:-0.0.0.0}
PORT=${PORT:-80}
LOG_LEVEL=${LOG_LEVEL:-info}

# Specify SSL Key and Certificate explicitly.
SSL_KEY_PATH=${SSL_KEY_PATH:-./ssl/selfsigned.key}
SSL_CERT_PATH=${SSL_CERT_PATH:-./ssl/selfsigned.crt}

# If there's a prestart.sh to be run,
# It is run before starting the application.
PRE_START_PATH=${PRE_START_PATH:-./prestart.sh}

echo "Checking for script in $PRE_START_PATH"
if [ -f "$PRE_START_PATH" ]; then
    echo "Running script $PRE_START_PATH"
    . "$PRE_START_PATH"
else
    echo "There is no script $PRE_START_PATH"
fi

# First check for explicity SSL file then,
# Start the application with uvicorn with live reload.
if [ -f "$SSL_KEY_PATH" ] && [ -f "$SSL_CERT_PATH" ]; then
    exec uvicorn --reload --host "$HOST" --port "$PORT" --log-level "$LOG_LEVEL" --ssl-keyfile "$SSL_KEY_PATH" --ssl-certfile "$SSL_CERT_PATH" "$APP_MODULE"
else
    exec uvicorn --reload --host "$HOST" --port "$PORT" --log-level "$LOG_LEVEL" "$APP_MODULE"
fi
