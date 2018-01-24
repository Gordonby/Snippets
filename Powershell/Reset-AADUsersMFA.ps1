#Gordon.byers@microsoft.com
#Powershell script is provided as-is and without any warranty of any kind

function Reset-AADUserMFA() {
    param (	
        [Parameter(Mandatory=$true)]
        [string] $DirAdminUsername ,
        [Parameter(Mandatory=$true)]
        [string] $DirAdminPassword ,
        [Parameter(Mandatory=$true)]
        [string] $UPNToReset
    )
    
    Write-Host "Checking for AD Powershell module"
    #You'll need to follow the guide here https://technet.microsoft.com/library/jj151815.aspx#bkmk_installmodule
    $poshAdFound = get-item $env:SystemRoot\System32\WindowsPowerShell\v1.0\Modules\MSOnline\Microsoft.Online.Administration.Automation.PSModule.dll -ErrorAction SilentlyContinue
    if ($poshAdFound -eq $null) { Write-Host "AD Powershell module not found, install it from here. https://technet.microsoft.com/library/jj151815.aspx#bkmk_installmodule" exit}

    Write-Host "Connecting to AD directory"
    $securePwString = $DirAdminPassword | ConvertTo-SecureString -AsPlainText -Force
    $AdminUserPassword = $null
    $Credential = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $DirAdminUsername, $securePwString
    Connect-MsolService -credential $Credential

    Write-Host "Getting Msol User"
    $msolUser = Get-MsolUser -UserPrincipalName $UPNToReset
    $mfaRequirements = $msolUser.StrongAuthenticationRequirements

    Write-Host "Clearing user Mfa Requirements"
    Set-MsolUser -UserPrincipalName $UPNToReset -StrongAuthenticationRequirements @()

    Write-Host "Re-enable Mfa Requirements"
    Set-MsolUser -UserPrincipalName $UPNToReset -StrongAuthenticationRequirements $mfaRequirements
}    

Reset-AADUserMFA -DirAdminUsername "nonmfaadmin@youraddirectory.onmicrosoft.com" -DirAdminPassword "youradminpassword" -UPNToReset "auser@youraddirectory.onmicrosoft.com"