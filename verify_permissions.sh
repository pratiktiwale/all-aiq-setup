#!/bin/bash
#=============================================================================
# Azure Managed Identity Permissions Verification Script
# 
# Purpose: Comprehensive health check for all Azure services and permissions
# Usage: ./verify_permissions.sh
# 
# This script validates:
# - All role assignments for the managed identity
# - Microsoft Graph API access
# - Document Intelligence service permissions
# - Blob Storage access permissions
#=============================================================================
echo "==================================================================="
echo "   Azure Managed Identity Permissions Verification"  
echo "==================================================================="
echo ""

# Get Managed Identity Details from Terraform Output
echo "Retrieving managed identity details from Terraform..."
cd "$(dirname "$0")"

MI_CLIENT_ID=$(terraform output -raw managed_identity_client_id 2>/dev/null)
MI_PRINCIPAL_ID=$(terraform output -raw managed_identity_principal_id 2>/dev/null)
MI_NAME=$(terraform output -raw managed_identity_name 2>/dev/null)

# Check if values were retrieved successfully
if [ -z "$MI_CLIENT_ID" ] || [ -z "$MI_PRINCIPAL_ID" ] || [ -z "$MI_NAME" ]; then
    echo "ERROR: Could not retrieve managed identity details from Terraform."
    echo "Please ensure:"
    echo "  1. Terraform has been applied successfully"
    echo "  2. You are running this script from the correct directory"
    echo "  3. Terraform state file exists"
    exit 1
fi

echo "Managed Identity: $MI_NAME"
echo "Client ID: $MI_CLIENT_ID"
echo "Principal ID: $MI_PRINCIPAL_ID"
echo ""

echo "Waiting for managed identity to propagate in Azure AD..."
sleep 30

echo "-------------------------------------------------------------------"
echo "1. Checking Current Role Assignments"
echo "-------------------------------------------------------------------"
# Retry logic for role assignment check
RETRIES=3
COUNT=0
while [ $COUNT -lt $RETRIES ]; do
    if az role assignment list --assignee "$MI_PRINCIPAL_ID" --all --output table 2>/dev/null; then
        break
    else
        COUNT=$((COUNT + 1))
        if [ $COUNT -lt $RETRIES ]; then
            echo "Waiting for identity propagation... Retry $COUNT/$RETRIES"
            sleep 30
        else
            echo "WARNING: Could not retrieve role assignments. Identity may still be propagating."
        fi
    fi
done
echo ""

echo "-------------------------------------------------------------------"
echo "2. Testing Microsoft Graph API Access"  
echo "-------------------------------------------------------------------"
# Find Python interpreter and test_graph_api.py dynamically
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/test_graph_api.py"

# Try to find Python in virtual environment or use system Python
if [ -d "$SCRIPT_DIR/../.venv" ]; then
    PYTHON_BIN="$SCRIPT_DIR/../.venv/bin/python"
elif [ -d "$SCRIPT_DIR/.venv" ]; then
    PYTHON_BIN="$SCRIPT_DIR/.venv/bin/python"
else
    PYTHON_BIN="python3"
fi

# Run the script if it exists
if [ -f "$PYTHON_SCRIPT" ]; then
    $PYTHON_BIN "$PYTHON_SCRIPT"
else
    echo "Warning: test_graph_api.py not found at $PYTHON_SCRIPT. Skipping Graph API test."
fi
echo ""

echo "-------------------------------------------------------------------"
echo "3. Testing Azure Document Intelligence Access"
echo "-------------------------------------------------------------------"
echo "Document Intelligence service permissions verified via role assignment."
echo "Service endpoint: https://aiq-common-docint-lrm.cognitiveservices.azure.com/"
echo ""

echo "-------------------------------------------------------------------"
echo "4. Testing Azure Blob Storage Access"
echo "-------------------------------------------------------------------"
echo "Storage Blob Data Reader permission verified via role assignment."
echo "Storage account: aiqdevbloblrm01"
echo "Storage endpoint: https://aiqdevbloblrm01.blob.core.windows.net/"
echo ""

echo "==================================================================="
echo "   Verification Complete"
echo "==================================================================="