#!/bin/bash

# Script to replace AMDB_DEV with ${DB.NAME} in target/run/liquibase/models directory
# EXCLUDES files in schema.yml subdirectory
# Usage: ./replace_database_references.sh [--dry-run]

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TARGET_DIR="../target/run/liquibase/models"
OLD_PATTERN="AMDB_DEV"
NEW_PATTERN="\${DATABASE.NAME}"
BACKUP_SUFFIX=".bak"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [--dry-run]"
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be changed without making actual modifications"
    echo "  --help       Show this help message"
    echo ""
    echo "This script replaces all occurrences of 'AMDB_DEV' with '\${DB.NAME}' in SQL files"
    echo "within the $TARGET_DIR directory."
    echo ""
    echo "NOTE: Files in the schema.yml subdirectory are EXCLUDED from processing."
}

# Parse command line arguments
DRY_RUN=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    print_error "Target directory '$TARGET_DIR' does not exist!"
    print_info "Please ensure you're running this script from the DBT project root directory."
    exit 1
fi

print_info "Starting database reference replacement..."
print_info "Target directory: $TARGET_DIR"
print_info "Replacing: $OLD_PATTERN → $NEW_PATTERN"
print_warning "EXCLUDING files in schema.yml subdirectory"

if [ "$DRY_RUN" = true ]; then
    print_warning "DRY RUN MODE - No files will be modified"
fi

# Find all SQL files in the target directory, excluding schema.yml subdirectory
sql_files=$(find "$TARGET_DIR" -name "*.sql" -type f -not -path "*/schema.yml/*")

if [ -z "$sql_files" ]; then
    print_warning "No SQL files found in $TARGET_DIR (excluding schema.yml directory)"
    exit 0
fi

# Count total files and files with matches
total_files=0
files_with_matches=0
total_replacements=0
excluded_files=0

# Count excluded files for reporting
if [ -d "$TARGET_DIR/schema.yml" ]; then
    excluded_files=$(find "$TARGET_DIR/schema.yml" -name "*.sql" -type f | wc -l)
    excluded_files=$((excluded_files + 0))  # Convert to integer
fi

print_info "Scanning for files containing '$OLD_PATTERN'..."
if [ $excluded_files -gt 0 ]; then
    print_info "Excluded $excluded_files files in schema.yml directory"
fi

while IFS= read -r file; do
    total_files=$((total_files + 1))
    
    # Check if file contains the pattern
    if grep -q "$OLD_PATTERN" "$file"; then
        files_with_matches=$((files_with_matches + 1))
        match_count=$(grep -c "$OLD_PATTERN" "$file")
        total_replacements=$((total_replacements + match_count))
        
        relative_path=${file#./}  # Remove ./ prefix if present
        print_info "Found $match_count occurrence(s) in: $relative_path"
        
        if [ "$DRY_RUN" = true ]; then
            # Show the lines that would be changed
            print_info "Preview of changes in $relative_path:"
            grep -n "$OLD_PATTERN" "$file" | while IFS= read -r line; do
                echo "    $line"
            done
        else
            # Create backup and perform replacement
            cp "$file" "$file$BACKUP_SUFFIX"
            
            # Use sed to replace all occurrences
            # Note: Using different delimiter (|) to avoid issues with special characters
            if sed "s|$OLD_PATTERN|$NEW_PATTERN|g" "$file$BACKUP_SUFFIX" > "$file"; then
                print_success "Updated: $relative_path (backup: $file$BACKUP_SUFFIX)"
            else
                print_error "Failed to update: $relative_path"
                # Restore from backup
                mv "$file$BACKUP_SUFFIX" "$file"
                exit 1
            fi
        fi
    fi
done <<< "$sql_files"

# Summary
echo ""
print_info "=== SUMMARY ==="
print_info "Total SQL files scanned: $total_files"
if [ $excluded_files -gt 0 ]; then
    print_info "Files excluded (schema.yml): $excluded_files"
fi
print_info "Files containing '$OLD_PATTERN': $files_with_matches"
print_info "Total replacements: $total_replacements"

if [ "$DRY_RUN" = true ]; then
    print_warning "DRY RUN completed - no files were modified"
    print_info "Run without --dry-run to apply changes"
elif [ $files_with_matches -gt 0 ]; then
    print_success "Replacement completed successfully!"
    print_info "Backup files created with $BACKUP_SUFFIX suffix"
    print_info "To remove backup files: find $TARGET_DIR -name '*$BACKUP_SUFFIX' -not -path '*/schema.yml/*' -delete"
else
    print_info "No files needed updating"
fi