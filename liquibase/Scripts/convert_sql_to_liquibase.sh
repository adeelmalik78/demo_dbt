#!/bin/bash

# Convert raw SQL scripts to Liquibase formatted SQL
# Processes only .sql files in target/run/liquibase/models directory (no subdirectories)

set -e  # Exit on error

# Configuration
TARGET_DIR="../target/run/liquibase/models"
AUTHOR="amalik"
TIMESTAMP=$(date +%Y%m%d)

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Converting raw SQL files to Liquibase format..."
echo "Target directory: $TARGET_DIR"
echo "Author: $AUTHOR"
echo "Timestamp: $TIMESTAMP"
echo ""

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Target directory '$TARGET_DIR' does not exist${NC}"
    exit 1
fi

# Count files to process
sql_files=($(find "$TARGET_DIR" -maxdepth 1 -name "*.sql" -not -name "*.bak"))
file_count=${#sql_files[@]}

if [ $file_count -eq 0 ]; then
    echo -e "${YELLOW}No .sql files found in $TARGET_DIR${NC}"
    exit 0
fi

echo "Found $file_count SQL file(s) to convert:"
for file in "${sql_files[@]}"; do
    echo "  - $(basename "$file")"
done
echo ""

# Process each SQL file
converted_count=0
for sql_file in "${sql_files[@]}"; do
    filename=$(basename "$sql_file")
    filename_without_ext="${filename%.sql}"
    
    echo -e "${YELLOW}Processing: $filename${NC}"
    
    # Check if file is already Liquibase formatted
    if head -n 1 "$sql_file" | grep -q "^--liquibase formatted sql"; then
        echo "  Already Liquibase formatted - skipping"
        echo ""
        continue
    fi
    
    # Create backup
    backup_file="${sql_file}.bak"
    if [ ! -f "$backup_file" ]; then
        cp "$sql_file" "$backup_file"
        echo "  Created backup: $(basename "$backup_file")"
    else
        echo "  Backup already exists: $(basename "$backup_file")"
    fi
    
    # Create temporary file for new content
    temp_file=$(mktemp)
    
    # Write Liquibase header
    cat > "$temp_file" << EOF
--liquibase formatted sql

--changeset ${AUTHOR}:${TIMESTAMP}_${filename_without_ext} runOnChange="true"
EOF
    
    # Append original SQL content
    cat "$sql_file" >> "$temp_file"
    
    # Add rollback comment (generic for DDL operations)
    echo "" >> "$temp_file"
    echo "--rollback DROP TABLE IF EXISTS ${filename_without_ext};" >> "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$sql_file"
    
    echo -e "  ${GREEN}Converted successfully${NC}"
    echo ""
    
    ((converted_count++))
done

echo -e "${GREEN}Conversion complete!${NC}"
echo "Files processed: $file_count"
echo "Files converted: $converted_count"
echo "Files skipped: $((file_count - converted_count))"

if [ $converted_count -gt 0 ]; then
    echo ""
    echo "Backup files created with .bak extension"
    echo "Review the converted files before using them in Liquibase"
fi