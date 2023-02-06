# Azure API Request Payload Captures

## Devbox definition

```json
{
  "properties": {
    "imageReference": {
      "id": "/subscriptions/REDACTED/resourceGroups/REDACTED/providers/Microsoft.DevCenter/devcenters/REDACTED/galleries/default/images/microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2"
    },
    "sku": {
      "name": "general_a_8c32gb_v1"
    },
    "osStorageType": "ssd_256gb"
  },
  "location": "westeurope"
}

{
  "properties": {
    "imageReference": {
      "id": "/subscriptions/REDACTED/resourceGroups/REDACTED/providers/Microsoft.DevCenter/devcenters/REDACTED/galleries/default/images/microsoftwindowsdesktop_windows-ent-cpc_win11-22h2-ent-cpc-os"
    },
    "sku": {
      "name": "general_a_4c16gb_v1"
    },
    "osStorageType": "ssd_1024gb"
  },
  "location": "westeurope"
}
```

ADE project environment type mapping
```json
{
  "content": {
    "properties": {
      "deploymentTargetId": "/subscriptions/REDACTED",
      "status": "Enabled",
      "creatorRoleAssignment": {
        "roles": {
          "8e3af657-a8ff-443c-a75c-2fe8c4bcb635": {}
        }
      }
    },
    "identity": {
      "type": "SystemAssigned"
    },
    "tags": {}
  },
  "httpMethod": "PUT",
  "name": "Some-Random-GUID?",
  "requestHeaderDetails": {
    "commandName": "Microsoft_Azure_DevCenter.CreateProjectEnvironmentType"
  },
  "url": "https://management.azure.com/subscriptions/REDACTED/resourceGroups/REDACTED/providers/Microsoft.DevCenter/projects/developers/environmentTypes/Dev/?api-version=2022-11-11-preview"
}
```
