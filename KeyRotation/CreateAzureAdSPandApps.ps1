####################
# Login and Verify #
####################

#It's best to check that we're operating in the right tenant.
#Set these to represent your tenantId and expected default subscriptionId
$tenantId = ""
$subId=""

Connect-AzAccount -Tenant $tenantId 
$currentContext=Get-AzContext
If ($tenantId -eq $currentContext.Tenant -and $subId -eq $currentContext.Subscription) {
    #All good.
    echo "Tenant/Subscription is as expected"
}
else {
    Write-Error "Operating in unexpected tenant"
}

#-------
#Setup
#-------
$sampleSp1 = New-AzADServicePrincipal -Role Reader -DisplayName SampleSp1
$sampleSp2 = New-AzADServicePrincipal -Role Reader -DisplayName SampleSp2

$graphRotate = New-AzADApplication -DisplayName "CredRotatorMsGraphAPI" -IdentifierUris "http://CredRotatorMsGraphAPI"
$aadRotate = New-AzADApplication -DisplayName "CredRotatorAADGraphAPI" -IdentifierUris "http://CredRotatorAADGraphAPI"



#------
#Basic Self Rotation (MSGraph test)
#------
Write-Output "Login as SP with Microsoft Graph Permissions"
$appId=""
$currentsecret=""
$credential = New-Object PSCredential -ArgumentList $appId, (ConvertTo-SecureString -String $currentsecret -AsPlainText -Force)
Connect-AzAccount -TenantId $tenantId -ServicePrincipal -Credential $credential
$ctx=Get-AzContext
$ctx.TokenCache
#Connect-AzureAD -TenantId $tenantId -Credential $credential

Write-Output "Generate new Secret for self"
$newsecret = New-Guid | ConvertTo-SecureString -AsPlainText -Force
New-AzADAppCredential -ApplicationId $appId -EndDate (Get-Date).AddMonths(1) -Password $newsecret

Get-AzureADMSApplication
New-AzureADMSApplicationPassword
New-AzureADMSApplicationPassword -ObjectId $appId -PasswordCredential @{ displayname = "mypassword" }


#------
#Basic Self Rotation (MSGraph test)
#------
Write-Output "Login as SP with Microsoft Graph Permissions"
$appId=""
$currentsecret=""
$credential = New-Object PSCredential -ArgumentList $appId, (ConvertTo-SecureString -String $currentsecret -AsPlainText -Force)
Connect-AzureAD

#Connect-AzureAD -TenantId $tenantId -Credential $credential

Write-Output "Generate new Secret for self"
$newsecret = New-Guid | ConvertTo-SecureString -AsPlainText -Force
New-AzADAppCredential -ApplicationId $appId -EndDate (Get-Date).AddMonths(1) -Password $newsecret

Get-AzureADMSApplication
New-AzureADMSApplicationPassword
New-AzureADMSApplicationPassword -ObjectId $appId -PasswordCredential @{ displayname = "mypassword" }


#------
#Basic Self Rotation (Legacy AAD Graph test)
#------
Write-Output "Login as SP with AAD Graph Permissions"
$appId=""
$currentsecret=""
$credential = New-Object PSCredential -ArgumentList $appId, (ConvertTo-SecureString -String $currentsecret -AsPlainText -Force)
Connect-AzAccount -TenantId $tenantId -ServicePrincipal -Credential $credential

Write-Output "Generate new Secret for self"
$newsecret = New-Guid | ConvertTo-SecureString -AsPlainText -Force
New-AzADAppCredential -ApplicationId $appId -EndDate (Get-Date).AddMonths(1) -Password $newsecret

#
# Add SP Owner
#
$sp = Get-AzADServicePrincipal -DisplayName "SampleSp1"
$Owner = Get-AzADServicePrincipal -DisplayName "CredRotatorAADGraphAPI"
$OwnerMsg = Get-AzADServicePrincipal -DisplayName "CredRotatorMsGraphAPI"

Connect-AzureAD -TenantId $tenantId
Add-AzureADServicePrincipalOwner -ObjectId $sp.id -RefObjectId $Owner.Id
Add-AzureADServicePrincipalOwner -ObjectId $sp.id -RefObjectId $OwnerMsg.Id

Get-AzureADServicePrincipalOwner -ObjectId $sp.id


#=================
# Try couple-owner
#=================
#Create Service Principals
$credRotateA = New-AzADServicePrincipal -DisplayName credRotateA -SkipAssignment
$credRotateB = New-AzADServicePrincipal -DisplayName credRotateB -SkipAssignment

#TODO: Go assign the API permissions Application.ReadWrite.OwnedBy in https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps

#Add cross-ownership
Connect-AzureAD -TenantId $tenantId
Add-AzureADServicePrincipalOwner -ObjectId $credRotateA.id -RefObjectId $credRotateB.id
Add-AzureADServicePrincipalOwner -ObjectId $credRotateB.id -RefObjectId $credRotateA.id

Get-AzureADServicePrincipalOwnedObject -ObjectId $credRotateA.id

$credRotateAcredential=New-Object PSCredential -ArgumentList $credRotateA.ApplicationId, $credRotateA.Secret
$credRotateBcredential=New-Object PSCredential -ArgumentList $credRotateB.ApplicationId, $credRotateB.Secret

[System.Net.NetworkCredential]::new("", $credRotateA.Secret).Password

Connect-AzAccount -TenantId $tenantId -ServicePrincipal -Credential $credRotateAcredential
$newsecret = New-Guid | ConvertTo-SecureString -AsPlainText -Force
$newAppCredential = New-AzADAppCredential -ApplicationId $credRotateB.ApplicationId -EndDate (Get-Date).AddMonths(1) -Password $newsecret

#------
#Basic SP Rotation (Legacy AAD Graph test)
#------
Write-Output "Login as SP with AAD Graph Permissions"
$appId=""
$currentsecret=""
$credential = New-Object PSCredential -ArgumentList $appId, (ConvertTo-SecureString -String $currentsecret -AsPlainText -Force)
Connect-AzAccount -TenantId $tenantId -ServicePrincipal -Credential $credential

Write-Output "Find SP"
$sp = Get-AzADServicePrincipal -DisplayName "SampleSp1"
$appId = $sp.ApplicationId
$newsecret = New-Guid | ConvertTo-SecureString -AsPlainText -Force
$newAppCredential = New-AzADAppCredential -ApplicationId $appId -EndDate (Get-Date).AddMonths(1) -Password $newsecret

Get-AzADAppCredential -ApplicationId $appId | % {
    if ($_.KeyId -eq $newAppCredential.KeyId) {
        #This is the newly generated credential.
    } else {
        Write-Output "Removing credential with key $($_.KeyId) for $appId"
        Remove-AzADAppCredential -ApplicationId $appId -KeyId $_.KeyId -Force
    }
}

#-------
#Forgotton password, reset all
#-------


[System.Net.NetworkCredential]::new("", $sampleSp1.Secret).Password
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $sampleSp1.ApplicationId, $sampleSp1.Secret
Connect-AzAccount -TenantId $tenantId -ServicePrincipal -Credential $credential -WarningAction SilentlyContinue
Get-AzContext | fl
Connect-AzAccount -ServicePrincipal -




#
# Cleanup
#

$sps = Get-AzADServicePrincipal -DisplayNameBeginsWith 'AzOps'
$sps | % {
    Write-Output "Remove-AzADServicePrincipal -ObjectId $($_.Id) -force `#$($_.DisplayName)"  
}

$appregs = Get-AzADApplication -DisplayNameStartWith 'AzOps'
$appregs | % {
    #Write-Output "Remove-AzADAppCredential -ObjectId $($_.ObjectId) -force;  `#$($_.DisplayName) "  
    Write-Output "Remove-AzADApplication -ObjectId $($_.ObjectId) -force;  `#$($_.DisplayName) "  
}