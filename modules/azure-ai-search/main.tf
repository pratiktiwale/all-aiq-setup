#--------------------------------------------------------------------------------------------------------------------------------
# local variables and resources for Azure AI Search
#-------------------------------------------------------------------------------------------------------------------------------- 
locals {
  # aiq-{env}-{service_type}-{number} -> remove hyphens and lowercase for storage account naming rules
  base_name = format("aiq-common-%s-%s", 
  
  var.service_type,
  var.project_unique_id)

  azurerm_search_service_name = lower(local.base_name)
}

#--------------------------------------------------------------------------------------------------------------------------------
# Azure AI Search Resources
#--------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_search_service" "this" {
  name                = local.azurerm_search_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  replica_count       = var.replica_count
  partition_count     = var.partition_count

  # Disable API key authentication completely - RBAC only
  local_authentication_enabled = false
  
  identity {
    type = "SystemAssigned"
  }

  # Enable public network access (can be restricted with IP allowlists)
  public_network_access_enabled = true
  allowed_ips                  = var.allowed_ips

  tags = var.tags
}

#--------------------------------------------------------------------------------------------------------------------------------
# RBAC Role Assignments for Managed Identity Access
#--------------------------------------------------------------------------------------------------------------------------------

# Search Service Contributor - for administrative operations
resource "azurerm_role_assignment" "search_service_contributor" {
  scope                = azurerm_search_service.this.id
  role_definition_name = "Search Service Contributor"
  principal_id         = var.managed_identity_principal_id
}

# Search Index Data Contributor - for index data operations
resource "azurerm_role_assignment" "search_index_data_contributor" {
  scope                = azurerm_search_service.this.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = var.managed_identity_principal_id
}

# Search Index Data Reader - for read operations
resource "azurerm_role_assignment" "search_index_data_reader" {
  scope                = azurerm_search_service.this.id
  role_definition_name = "Search Index Data Reader"
  principal_id         = var.managed_identity_principal_id
}

# Create Search Index using REST API via local-exec
resource "null_resource" "search_index" {
  count = var.create_index ? 1 : 0

  # Create the index JSON file
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<-EOF
      cat > /tmp/search_index.json << 'JSON_EOF'
{
  "name": "${var.index_name}",
  "fields": [
    {
      "name": "id",
      "type": "Edm.String",
      "searchable": true,
      "filterable": true,
      "retrievable": true,
      "sortable": true,
      "facetable": true,
      "key": true,
      "synonymMaps": []
    },
    {
      "name": "title",
      "type": "Edm.String",
      "searchable": true,
      "filterable": true,
      "retrievable": true,
      "sortable": true,
      "facetable": true,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "content",
      "type": "Edm.String",
      "searchable": true,
      "filterable": false,
      "retrievable": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "keywords",
      "type": "Collection(Edm.String)",
      "searchable": true,
      "filterable": true,
      "retrievable": true,
      "sortable": false,
      "facetable": true,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "metadata_storage_path",
      "type": "Edm.String",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "metadata_storage_name",
      "type": "Edm.String",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": true,
      "facetable": false,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "lastModified",
      "type": "Edm.DateTimeOffset",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": true,
      "facetable": false,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "acl",
      "type": "Collection(Edm.String)",
      "searchable": false,
      "filterable": true,
      "retrievable": false,
      "sortable": false,
      "facetable": false,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "acl_emails",
      "type": "Collection(Edm.String)",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "acl_display_names",
      "type": "Collection(Edm.String)",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "embeddingVector",
      "type": "Collection(Edm.Single)",
      "searchable": true,
      "filterable": false,
      "retrievable": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "dimensions": ${var.vector_dimensions},
      "vectorSearchProfile": "${var.vector_search_profile_name}",
      "synonymMaps": []
    },
    {
      "name": "siteId",
      "type": "Edm.String",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": true,
      "facetable": false,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "driveId",
      "type": "Edm.String",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "itemId",
      "type": "Edm.String",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "documentSource",
      "type": "Edm.String",
      "searchable": true,
      "filterable": true,
      "retrievable": true,
      "sortable": false,
      "facetable": true,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "documentType",
      "type": "Edm.String",
      "searchable": true,
      "filterable": true,
      "retrievable": true,
      "sortable": true,
      "facetable": true,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "acl_fingerprint",
      "type": "Edm.String",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": false,
      "facetable": false,
      "key": false,
      "synonymMaps": []
    },
    {
      "name": "pageNumber",
      "type": "Edm.Int32",
      "searchable": false,
      "filterable": true,
      "retrievable": true,
      "sortable": true,
      "facetable": true,
      "key": false,
      "synonymMaps": []
    }
  ],
  "corsOptions": {
    "allowedOrigins": ["*"],
    "maxAgeInSeconds": 300
  },
  "semantic": {
    "defaultConfiguration": "default-semantic-config",
    "configurations": [
      {
        "name": "default-semantic-config",
        "prioritizedFields": {
          "titleField": {
            "fieldName": "title"
          },
          "prioritizedContentFields": [
            {"fieldName": "content"}
          ],
          "prioritizedKeywordsFields": [
            {"fieldName": "keywords"}
          ]
        }
      }
    ]
  },
  "vectorSearch": {
    "algorithms": [
      {
        "name": "${var.vector_search_algorithm_name}",
        "kind": "hnsw",
        "hnswParameters": {
          "metric": "${var.hnsw_parameters.metric}",
          "m": ${var.hnsw_parameters.m},
          "efConstruction": ${var.hnsw_parameters.efConstruction},
          "efSearch": ${var.hnsw_parameters.efSearch}
        }
      }
    ],
    "profiles": [
      {
        "name": "${var.vector_search_profile_name}",
        "algorithm": "${var.vector_search_algorithm_name}",
        "vectorizer": "${var.openai_vectorizer_name}"
      }
    ],
    "vectorizers": [
      {
        "name": "${var.openai_vectorizer_name}",
        "kind": "azureOpenAI",
        "azureOpenAIParameters": {
          "resourceUri": "${var.openai_endpoint}",
          "deploymentId": "${var.openai_deployment_name}",
          "modelName": "${var.openai_model_name}"
        }
      }
    ]
  }
}
JSON_EOF
    EOF
  }

  # Create the index using Azure CLI or curl
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<-EOF
      set -e  # Exit on any error
      
      # Function to check if search service is ready
      wait_for_service() {
        local max_attempts=12
        local attempt=1
        
        while [ $attempt -le $max_attempts ]; do
          echo "Attempt $attempt: Checking if search service is ready..."
          
          # Use Azure CLI authentication with Bearer token (RBAC only)
          ACCESS_TOKEN=$(az account get-access-token --resource=https://search.azure.com/ --query accessToken -o tsv 2>/dev/null || echo "")
          
          if [ -n "$ACCESS_TOKEN" ]; then
            STATUS_CODE=$(curl -s -o /dev/null -w "%%{http_code}" \
              "https://${azurerm_search_service.this.name}.search.windows.net/servicestats?api-version=2024-07-01" \
              -H "Authorization: Bearer $ACCESS_TOKEN")
          else
            echo "Failed to get access token, trying again..."
            STATUS_CODE="401"
          fi
          
          if [ "$STATUS_CODE" = "200" ]; then
            echo "Search service is ready!"
            return 0
          fi
          
          echo "Service not ready (HTTP $STATUS_CODE), waiting 30 seconds..."
          sleep 30
          attempt=$((attempt + 1))
        done
        
        echo "ERROR: Search service failed to become ready after $max_attempts attempts"
        exit 1
      }
      
      # Wait for search service to be ready
      wait_for_service
      
      echo "Creating index with the following JSON:"
      cat /tmp/search_index.json
      echo "=========================="
      
      # Validate JSON syntax
      if ! python3 -m json.tool /tmp/search_index.json > /dev/null 2>&1; then
        echo "ERROR: Invalid JSON syntax in index definition"
        exit 1
      fi
      
      # Create index using Azure CLI authentication with Bearer token (RBAC only)
      ACCESS_TOKEN=$(az account get-access-token --resource=https://search.azure.com/ --query accessToken -o tsv)
      
      # First delete the existing index to update with new vectorizer configuration
      DELETE_CODE=$(curl -X DELETE \
        "https://${azurerm_search_service.this.name}.search.windows.net/indexes/${var.index_name}?api-version=2024-07-01" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -w "%%{http_code}" \
        -s)

      echo "Delete HTTP Response Code: $DELETE_CODE"

      if [ "$DELETE_CODE" = "204" ] || [ "$DELETE_CODE" = "404" ]; then
        echo "✅ Existing index deleted or didn't exist"
      else
        echo "⚠️  Delete returned code $DELETE_CODE, continuing anyway"
      fi

      # Now create the index with new configuration
      HTTP_CODE=$(curl -X POST \
        "https://${azurerm_search_service.this.name}.search.windows.net/indexes?api-version=2024-07-01" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -d @/tmp/search_index.json \
        -w "%%{http_code}" \
        -o /tmp/response.json \
        -s)
      
      echo "HTTP Response Code: $HTTP_CODE"
      echo "Response Body:"
      cat /tmp/response.json
      
      # Check if creation was successful
      case "$HTTP_CODE" in
        200|201)
          echo "✅ Index '${var.index_name}' created successfully with vectorizer"
          ;;
        400)
          echo "❌ Bad Request: Invalid index definition"
          cat /tmp/response.json
          exit 1
          ;;
        401)
          echo "❌ Unauthorized: Authentication failed"
          exit 1
          ;;
        409)
          echo "❌ Index still exists - unexpected after deletion"
          cat /tmp/response.json
          exit 1
          ;;
        *)
          echo "❌ Index creation failed with HTTP code: $HTTP_CODE"
          cat /tmp/response.json
          exit 1
          ;;
      esac
      
      # Clean up temporary files
      rm -f /tmp/response.json
    EOF
  }

  # Clean up temporary file
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f /tmp/search_index.json"
  }

  depends_on = [azurerm_search_service.this]

  triggers = {
    search_service_id = azurerm_search_service.this.id
    index_config     = jsonencode({
      name                     = var.index_name
      openai_resource_uri      = var.openai_resource_uri
      openai_deployment_id     = var.openai_deployment_id
    })
  }
}


