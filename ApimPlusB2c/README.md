# Configuring Azure APIM with B2C

## Pre-requisties

Expedite the boring bits by deploying a full APIM and sample API stack from this [repository](https://github.com/Gordonby/AzureBicepServerlessAppStack).

```bash
RG="serverlessApim"
az group create -g $RG -l westeurope
az deployment group create -g $RG -u https://raw.githubusercontent.com/Gordonby/AzureBicepServerlessAppStack/main/bicep/application/icecreamratings.json
```

### Check the deployed assets

