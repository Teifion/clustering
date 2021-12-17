#!/usr/bin/env bash
# This is called from bin/deploy, you should not need to call it manually

docker build --build-arg env=prod -t clustering:latest .

# Use this line instead to rebuild completely 
# docker build --no-cache --build-arg env=prod -t clustering:latest .
