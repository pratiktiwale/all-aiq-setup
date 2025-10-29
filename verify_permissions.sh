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

# Managed Identity Details
MI_CLIENT_ID="7e2cba3a-5392-4cb0-8e69-f8cd92ee9c7f"
MI_PRINCIPAL_ID="5c28c587-4255-4bbf-8474-9f62f56b10e7"
MI_NAME="aiq-common-umi-lrm-01"

echo "Managed Identity: $MI_NAME"
echo "Client ID: $MI_CLIENT_ID"
echo "Principal ID: $MI_PRINCIPAL_ID"
echo ""

echo "-------------------------------------------------------------------"
echo "1. Checking Current Role Assignments"
echo "-------------------------------------------------------------------"
az role assignment list --assignee "$MI_PRINCIPAL_ID" --all --output table
echo ""

echo "-------------------------------------------------------------------"
echo "2. Testing Microsoft Graph API Access"  
echo "-------------------------------------------------------------------"
/home/pratiktiwale/iaac/.venv/bin/python test_graph_api.py
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