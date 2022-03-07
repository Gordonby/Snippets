# CARML ACR

The CARML bicep modules can be added to your enterprises Azure Container Registry to facilitate ease of authoring.

## Pre-requisites

Seed your ACR with the CARML modules;

```powershell
#create acr
$acrname="carml"
$rg="innerloop"
az acr create -n $acrname -g $rg --sku standard

#download release
$repoApiUrl="https://api.github.com/repos/Azure/ResourceModules/releases/latest"
$zipPath="carml-$moduleVersion.zip"
$latestRelease=Invoke-RestMethod -Uri $repoApiUrl
$moduleVersion=$latestRelease.tag_name
Invoke-WebRequest -Uri $latestRelease.zipball_url -MaximumRedirection 5 -OutFile $zipPath

#unzip release and cd
Expand-Archive -Path $zipPath -DestinationPath .\carmlReleases\$moduleVersion
cd .\carmlReleases\$moduleVersion\Azure-ResourceModules-cfcb9d5

#Add publish function to runspace
. .\utilities\pipelines\resourcePublish\Publish-ModuleToPrivateBicepRegistry.ps1

#Add files to ACR
$bicepFilesToPublish = Get-ChildItem -Path .\arm\ -Filter deploy.bicep -Recurse
write-output "$($bicepFilesToPublish.count) bicep files to publish to ACR $acrname in $rg"

$bicepFilesToPublish | ForEach-Object {
    Write-Output "Processing $($_.VersionInfo.FileName)"
    Publish-ModuleToPrivateBicepRegistry -TemplateFilePath $_.VersionInfo.FileName -ModuleVersion $moduleversion -BicepRegistryName $acrname -BicepRegistryRgName $rg
}
```

## Author a new file to call the ACR

NB: This only works when your default Azure credential has RBAC access to the ACR. This is because the bicep files are downloaded to a local cache.
See this for more information: [https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-config-modules#credentials-for-publishingrestoring-modules](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-config-modules#credentials-for-publishingrestoring-modules)

```bicep
module gridVnet 'br:Carml.azurecr.io/bicep/modules/microsoft.network.virtualnetworks:v0.4.0' = {
}
```
