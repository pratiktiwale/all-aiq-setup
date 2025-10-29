# AIQ Infrastructure Setup (IaaC)

Infrastructure-as-Code setup for the AIQ application using Terraform.

## Quick Start
```bash
# Deploy infrastructure
terraform init
terraform plan
terraform apply

# Verify deployment
./verify_permissions.sh
```

## Testing & Validation
- `verify_permissions.sh` - Comprehensive infrastructure health check
- `test_graph_api.py` - Microsoft Graph API access validation

## Architecture
Complete Azure AI infrastructure including:
- Managed Identity with RBAC permissions
- Azure AI Search with vectorizer integration
- Document Intelligence service
- Blob Storage with proper access controls
- Key Vault for secrets management
- Function Apps and Web Apps
- Azure OpenAI and AI Foundry services
