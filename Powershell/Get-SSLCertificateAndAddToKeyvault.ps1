<#
    .DESCRIPTION
        Obtains a certificate from Let's Encrypt and stores it in an Azure KeyVault

    .PARAMETER KeyvaultName
        The name of the Azure Keyvault that you want the certificate to be stored in
    
    .PARAMETER Rootdomain
        The domain (DNS Zone) that you own 
        Eg. azdemo.co.uk 
    
    .PARAMETER Alias
        The subdomain that you're wanting to obtain a certificate for.
        Eg. mywebapp

    .PARAMETER RegistrationEmail
        Used by Let's Encrypt for ownership.  
        Must resolve to a valid address with a valid MX domain.

    .NOTES
        AUTHOR: Gordon Byers
        LASTEDIT: July 9, 2018
#>

param (
    [parameter(Mandatory=$true)]
	[String] $KeyvaultName = "gobyers",
    [parameter(Mandatory=$true)]
	[String] $Rootdomain = "azdemo.co.uk",
    [parameter(Mandatory=$true)]
	[String] $Alias = "*",
    [parameter(Mandatory=$true)]
	[String] $RegistrationEmail="gordon.byers@microsoft.com"
)

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

function CreateRandomPassword() {
    Write-Host "Creating random password"
    $bytes = New-Object Byte[] 32
    $rand = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rand.GetBytes($bytes)
    $rand.Dispose()
    $password = [System.Convert]::ToBase64String($bytes)
    return $password
}

#Setting varaibles up with better naming conventions
$vaultcertificateName=$alias + $Rootdomain.replace(".","")
$acmeCertname = $alias + "$(get-date -format yyyy-MM-dd--HH-mm)"
$pfxFile = Join-Path $pwd "tempcert.pfx"

#Getting an alternative alias ready, for use with AZure Web Apps
$aliases = @($alias, "$alias-az")

#Making sure that Azure is managing your DNS
$dnsZone = Get-AzureRmDnsZone | ? {$_.Name -eq $rootdomain}
if($dnsZone -eq $null) {
    Write-Error "Dns Zone $rootdomain not found in Azure.  Is Azure managing your DNS Name Server (managing your DNS)?"
    break;
}

#Lets Encrypt uses the ACME protocol for verification. import-module ACMESharp
if (!(Get-ACMEVault))
{
    Initialize-ACMEVault
}
New-ACMERegistration -Contacts "mailto:$RegistrationEmail" -AcceptTos

$aliases | % {
    New-ACMEIdentifier -Dns $_ + "." + $rootdomain -Alias $_
}

#Requesting a validation challenge before we can get a certificate
$acmeChallenges = @()
$aliases | % {
    $acmeChallenges += Complete-ACMEChallenge $_ -ChallengeType dns-01 -Handler manual
}

#Parsing the challenge output for the right DNS entries to create
$acmeChallenges | % {
    $acmeChallenge = $_

    $manualChallenge = $acmeChallenge.Challenges | ? {$_.HandlerName -eq "manual"}
    $dnsName = $manualChallenge.Challenge.RecordName.replace(".$rootdomain","")
    $dnsValue = $manualChallenge.Challenge.RecordValue

    #Finding any existing DNS records for the requested domain entry
    $existingDnsRecordset = Get-AzureRmDnsRecordSet -Name $dnsName -RecordType TXT -ZoneName $dnsZone.name -ResourceGroupName $dnsZone.resourcegroupname  -ErrorAction SilentlyContinue

    if($existingDnsRecordset -eq $null) {
        Write-Output "Adding DNS entry $dnsName"
        $Records = @()
        $Records += New-AzureRmDnsRecordConfig -Value $dnsValue
        $RecordSet = New-AzureRmDnsRecordSet -Name $dnsName -RecordType TXT -ResourceGroupName $dnsZone.resourcegroupname -TTL 60 -ZoneName $dnsZone.name -DnsRecords $Records -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "Updating DNS entry $dnsName from $($existingDnsRecordset.Records[0].value) to  $dnsValue"
        $existingDnsRecordset.Records[0].value = $dnsValue
        Set-AzureRmDnsRecordSet -RecordSet $existingDnsRecordset
    }
}

Start-Sleep -s 5

#Notifying that challenge conditions have been met
$aliases | % {
    Submit-ACMEChallenge $_ -ChallengeType dns-01
    (Update-ACMEIdentifier $_ -ChallengeType dns-01).Challenges | Where-Object {$_.Type -eq "dns-01"}
}

#Requesting a certificate
New-ACMECertificate ${alias} -Generate -Alias $acmeCertname -AlternativeIdentifierRefs $($Aliases | ? {$_ -ne $alias}) 
Submit-ACMECertificate $acmeCertname
Update-AcmeCertificate $acmeCertname

#Making a Pfx certificate
$randomPw=CreateRandomPassword
Write-Output "Certificate Password $randomPw" 
Get-ACMECertificate $acmeCertname -ExportPkcs12 $pfxFile -CertificatePassword $randomPw

#Checking file exists
$pfxFileExists = test-path($pfxFile)

if(!$pfxFileExists) {
    Write-Error "PFX $pfxFile does not exist [$pfxFileExists]"
    break;
}
else  {
    Write-Output "PFX saved to $pfxFile.  File Exists [$pfxFileExists]"

    #Update certificate in key-vault
    $securepfxpwd = ConvertTo-SecureString –String $randomPw –AsPlainText –Force

    $existingCert=Get-AzureKeyVaultSecret -VaultName $keyvaultName -Name $vaultcertificateName -ErrorAction SilentlyContinue
    if(!$existingCert -eq $null) {
        Write-Host "Certificate last updated : $($existingCert.Updated)"
    }

    Write-Output "Importing Certificate from ($pfxFile)"
    $cert = Import-AzureKeyVaultCertificate -VaultName $keyvaultName -Name $vaultcertificateName -FilePath $pfxFile -Password $securepfxpwd

    Write-Output "Storing password for cert in Keyvault as secret"
    Set-AzureKeyVaultSecret -VaultName $KeyvaultName -Name "$vaultcertificateName-pw" -SecretValue $securepfxpwd

    $newCert=Get-AzureKeyVaultSecret -VaultName $keyvaultName -Name $vaultcertificateName 
    Write-Output "Certificate last updated : $($newCert.Updated)"
}

#Cleanup
Remove-Item $pfxFile