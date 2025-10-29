#!/usr/bin/env python3
"""
Test script for verifying Microsoft Graph API access using Managed Identity.
This script validates that the managed identity can successfully authenticate
and access the Graph API to retrieve user information.

Usage: python test_graph_api.py
"""
from azure.identity import DefaultAzureCredential # type: ignore
import httpx # type: ignore
import os

# For better security, consider using an environment variable.
MI_CLIENT_ID = "7e2cba3a-5392-4cb0-8e69-f8cd92ee9c7f"

try:
    print("Attempting to acquire token for the Graph API...")
    # Authenticate using the managed identity's client ID
    credential = DefaultAzureCredential(managed_identity_client_id=MI_CLIENT_ID)
    
    # Get an access token for Microsoft Graph
    token = credential.get_token("https://graph.microsoft.com/.default")
    print("Token acquired successfully.")
    
    headers = {"Authorization": f"Bearer {token.token}"}
    
    print("Calling the Microsoft Graph API (/users)...")
    resp = httpx.get("https://graph.microsoft.com/v1.0/users", headers=headers)
    
    # Print the result
    print(f"\n--- API Response ---")
    print(f"Status Code: {resp.status_code}")
    print("Response Body (first 500 characters):")
    print(resp.text[:500])
    
    if resp.status_code == 200:
        print("\nSUCCESS: The API call was successful. Permissions are set correctly!")
    else:
        print(f"\nERROR: The API call failed with status {resp.status_code}. Check permissions.")

except Exception as e:
    print(f"\nAn exception occurred: {e}")