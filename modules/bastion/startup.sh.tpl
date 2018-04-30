#!/bin/bash
set -e

echo "Installing Redis CLI and Postgres client..."
sudo apt-get update
sudo apt-get install --assume-yes redis-tools postgresql-client-common postgresql-client-9.5
