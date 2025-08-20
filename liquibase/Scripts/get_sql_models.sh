#!/bin/bash

# Get SQL model names from models directory as space-separated string
cd "../models"
find . -name "*.sql" -type f | sed 's|^\./||' | sed 's|\.sql$||' | tr '\n' ' ' | sed 's/ $//'