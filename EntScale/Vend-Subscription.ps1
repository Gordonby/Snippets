cd C:\Users\gobyers\Downloads

#Input Params
$AzOpsEnvironment="PDEV"
$TargetMG="PDEV-Sandboxes"
$SubscriptionAlias="Msft-Gord-Test1"

#Base vars
$repoBasePath="c:\"


#Acquire Arm template
$armTemplateJson = Get-Content "CreateEmptySubscription (4).json" -Raw
$armTemplate = $armTemplateJson | ConvertFrom-Json

#Customise the template
#This could be done in a parameters file in the same way
#However i prefer the reduced repo footprint from just working in 1 file. Your preference may be different
$armTemplate.parameters.targetManagementGroup.defaultValue = $TargetMG
$armTemplate.parameters.subscriptionAliasName.defaultValue = $SubscriptionAlias

#Find the correct repo path to represent the management group scope
$AzOpsEnvironment = $AzOpsEnvironment.ToLower()

switch ( $AzOpsEnvironment )
{
    "canary" { $repoBasePath+= "azops-canary\$AzOpsEnvironment ($AzOpsEnvironment)" }
    "pdev" { $repoBasePath+= "azops-dev\$AzOpsEnvironment ($AzOpsEnvironment)" }
}

if(Test-Path $repoBasePath) {
    #Base directory does exist
} else {
    Write-Error "$repoBasePath does not exist in the file system.  Check and confirm paths"
}


Write-Output "Searching for $TargetMG in $repoBasePath"

Get-ChildItem $repoBasePath $TargetMG.ToLower() -Recurse -Directory

#Save the file to the repo path at the correct scope

#Git Add

#Git Commit

#Git PR raise








