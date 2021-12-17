#!/usr/bin/env bash
docker run -v $(pwd):/opt/build/clustering --rm clustering:latest /opt/build/build_script.sh
