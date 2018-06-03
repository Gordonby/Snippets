param (
    [parameter(Mandatory=$true)]
	[String] $vaultName = "gobyers",
    [parameter(Mandatory=$true)]
	[String] $rootdomain = "azdemo.co.uk",
    [parameter(Mandatory=$true)]
	[String] $alias = "westeurope4",
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

#Setting varaibles up with better naming conventions
$domain = $alias + "." + $rootdomain
$vaultcertificateName=$domain.replace(".","")
$acmeCertname = $alias + "$(get-date -format yyyy-MM-dd--HH-mm)"
$pfxFile = Join-Path $pwd "tempcert.pfx"

#Making sure that Azure is managing your DNS
$dnsZone = Get-AzureRmDnsZone | ? {$_.Name -eq $rootdomain}
if($dnsZone -eq $null) {
    Write-Error "Dns Zone $rootdomain not found in Azure.  Is Azure managing your DNS Name Server (managing your DNS)?"
    break;
}

#Let’s Encrypt uses the ACME protocol for verification.
if (!(Get-ACMEVault))
{
    Initialize-ACMEVault
}
New-ACMERegistration -Contacts "mailto:$RegistrationEmail" -AcceptTos
New-ACMEIdentifier -Dns $domain -Alias $alias -ErrorAction SilentlyContinue

#Requesting a validation challenge before we can get a certificate
$acmeChallenge = Complete-ACMEChallenge $alias -ChallengeType dns-01 -Handler manual

#Parsing the challenge output for the right DNS entries to create
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
Start-Sleep -s 5

#Notifying that challenge conditions have been met
Submit-ACMEChallenge $alias -ChallengeType dns-01
(Update-ACMEIdentifier $alias -ChallengeType dns-01).Challenges | Where-Object {$_.Type -eq "dns-01"}

#Requesting a certificate
New-ACMECertificate ${alias} -Generate -Alias $acmeCertname
Submit-ACMECertificate $acmeCertname
Update-AcmeCertificate $acmeCertname

#Making a Pfx certificate
Get-ACMECertificate $acmeCertname -ExportPkcs12 $pfxFile -CertificatePassword 'g1Bb3Ri$h'

#Checking file exists
$pfxFileExists = test-path($pfxFile)

if(!$pfxFileExists) {
    Write-Error "PFX $pfxFile does not exist [$pfxFileExists]"
    break;
}
else  {
    Write-Output "PFX saved to $pfxFile.  File Exists [$pfxFileExists]"

    #Update certificate in key-vault
    #ref: https://blogs.technet.microsoft.com/kv/2016/09/26/get-started-with-azure-key-vault-certificates/
    #ref: https://docs.microsoft.com/en-us/azure/key-vault/key-vault-key-rotation-log-monitoring#key-rotation-using-azure-automation
    $securepfxpwd = ConvertTo-SecureString –String 'g1Bb3Ri$h' –AsPlainText –Force

    $existingCert=Get-AzureKeyVaultSecret -VaultName $vaultName -Name $vaultcertificateName -ErrorAction SilentlyContinue
    if(!$existingCert -eq $null) {
        Write-Host "Certificate last updated : $($existingCert.Updated)"
    }

    Write-Output "Importing Certificate from ($pfxFile)"
    $cert = Import-AzureKeyVaultCertificate -VaultName $vaultName -Name $vaultcertificateName -FilePath $pfxFile -Password $securepfxpwd

    $newCert=Get-AzureKeyVaultSecret -VaultName $vaultName -Name $vaultcertificateName 
    Write-Output "Certificate last updated : $($newCert.Updated)"
}

#Cleanup
