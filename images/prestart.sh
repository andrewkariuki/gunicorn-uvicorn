#! /usr/bin/env sh

echo "Waiting for database to start..."
sleep 20

echo "Running database migrations..."
alembic upgrade head
