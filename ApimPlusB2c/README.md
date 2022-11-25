# Configuring Azure APIM with B2C

## Pre-requisties

Expedite the boring bits by deploying a full APIM and sample API stack from this [repository](https://github.com/Gordonby/AzureBicepServerlessAppStack).

```bash
RG="serverlessApim"
az group create -g $RG -l westeurope
az deployment group create -g $RG -u https://raw.githubusercontent.com/Gordonby/AzureBicepServerlessAppStack/main/bicep/application/icecreamratings.json
```

### Check the deployed assets

![image](https://user-images.githubusercontent.com/17914476/203985049-c1e873d8-eefa-441d-bb97-34cad4582853.png)

### Test an API

![image](https://user-images.githubusercontent.com/17914476/203985274-20df7985-1035-4656-bfaa-8ad1c8ac68ec.png)
