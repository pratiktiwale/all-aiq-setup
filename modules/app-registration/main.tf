# modules/app-registration/main.tf
#----------------------------------------------------------------------------------------------------------------
# 1. Locals for Naming Convention
#----------------------------------------------------------------------------------------------------------------

locals {
  # Construct the base name: aiq-{env}-{service-type}-{resource-use}-{project_unique_id}-{number}
  base_name = format(
    "aiq-%s-%s",
    var.service_type,
    var.project_unique_id,
  )
  
  # App registration display name
  app_registration_name = local.base_name
  
  # Dynamic redirect URIs - combine defaults with provided app service URLs
  spa_redirect_uris = concat(
    var.spa_redirect_uris,
    var.backend_web_app_url != "" ? ["${var.backend_web_app_url}/docs/oauth2-redirect"] : [],
    var.frontend_web_app_url != "" ? ["${var.frontend_web_app_url}/platform/home"] : []
  )
}

#----------------------------------------------------------------------------------------------------------------
# 2. Azure AD Application Registration (Step 1.1)
#----------------------------------------------------------------------------------------------------------------

resource "azuread_application" "main" {
  display_name            = local.app_registration_name
  description            = var.description
  sign_in_audience       = "AzureADMyOrg"  # Single tenant as per manual process
  prevent_duplicate_names = true

  # Step 1.2: Configure Authentication Platform - Single-page application (SPA)
  single_page_application {
    redirect_uris = local.spa_redirect_uris
  }

  # Step 1.4: Configure API Permissions - Microsoft Graph Delegated Permissions
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    # Delegated Permissions (Pending Admin Consent)
    resource_access {
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0" # email
      type = "Scope"
    }
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e" # openid
      type = "Scope"
    }
    resource_access {
      id   = "14dad69e-099b-42c9-810b-d002981feec1" # profile
      type = "Scope"
    }
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
    resource_access {
      id   = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182" # offline_access
      type = "Scope"
    }

    # Application Permissions (Granted - Active)
    resource_access {
      id   = "5b567255-7703-4780-807c-7be8301ae99b" # Group.Read.All
      type = "Role"
    }
    resource_access {
      id   = "332a536c-c7ef-4017-ab91-336970924f0d" # Sites.Read.All
      type = "Role"
    }
    resource_access {
      id   = "883ea226-0bf2-4a8f-9f9d-92c9162a727d" # Sites.Selected
      type = "Role"
    }
    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
      type = "Role"
    }
    resource_access {
      id   = "75359482-378d-4052-8f01-80520e7db3cd" # Files.Read.All
      type = "Role"
    }
    resource_access {
      id   = "678536fe-1083-478a-9c59-b99265e6b0d3" # Sites.FullControl.All
      type = "Role"
    }
  }

  # Step 1.5: Expose an API - Add app scope
  api {
    # Set Application ID URI to api://{client-id} (default)
    mapped_claims_enabled          = false
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Allows the application to read files on behalf of the user."
      admin_consent_display_name = "Read user files"
      enabled                    = true
      id                         = var.app_scope_id
      type                       = "User"
      user_consent_description   = "Allows the application to read your files."
      user_consent_display_name  = "app"
      value                      = "app"
    }
  }
}

#----------------------------------------------------------------------------------------------------------------
# 3. Service Principal for the Application (Enterprise App)
#----------------------------------------------------------------------------------------------------------------

resource "azuread_service_principal" "main" {
  client_id = azuread_application.main.client_id
}

#----------------------------------------------------------------------------------------------------------------
# 4. Application Password (Client Secret) - Step 1.3
#----------------------------------------------------------------------------------------------------------------

resource "azuread_application_password" "main" {
  application_id = azuread_application.main.id
  display_name   = "${local.app_registration_name}-secret"
  end_date       = var.client_secret_end_date
}