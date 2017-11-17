#Save-Module -Name ACMESharp -Path "C:\Program Files\WindowsPowerShell\Modules\" -RequiredVersion 0.8.1 
import-module ACMESharp

$email="gobyers@microsoft.com"
$domain = "apim2.gordonbyers.me.uk"
$alias = "apim2gordonbyersme"
$certfolder="C:\Users\gobyers\OneDrive\Certs\$alias"

New-Item -ItemType Directory -Force -Path $certfolder
$certname = $alias + "$(get-date -format yyyy-MM-dd--HH-mm)"
$certfile =  "$certfolder\$certname"

# Change to the Vault folder
set-location "C:\Users\gobyers\OneDrive\Certs\ACMESharp\sysVault"

if (!(Get-ACMEVault))
{
    Initialize-ACMEVault
}

New-ACMERegistration -Contacts "mailto:$email" -AcceptTos
New-ACMEIdentifier -Dns $domain -Alias $alias
Complete-ACMEChallenge $alias -ChallengeType dns-01 -Handler manual

#Stop.  Now add a TXT record for your alias to point to the Uri
#Looks something like this
#  * RR Type:  [TXT]
#  * RR Name:  [_acme-challenge.mydomain.com]
#  * RR Value: [amskldamsdklasmlkdmaslkdjakle23eqwoei9edksada]

Submit-ACMEChallenge $alias -ChallengeType dns-01

(Update-ACMEIdentifier $alias -ChallengeType dns-01).Challenges | Where-Object {$_.Type -eq "dns-01"}

#Single cert
New-ACMECertificate ${alias} -Generate -Alias $certname
Submit-ACMECertificate $certname

#Multicert (Subject Alternative Name)
#New-ACMECertificate dns1 -Generate -AlternativeIdentifierRefs dns2,dns3,dns4 -Alias multiNameCert
#Submit-ACMECertificate multiNameCert

update-AcmeCertificate $certname

Get-ACMECertificate $certname -ExportPkcs12 "$certfile.pfx"
Get-ACMECertificate $certname -ExportPkcs12 "$certfile.pw.pfx" -CertificatePassword 'g1Bb3Ri$h'
Get-ACMECertificate $certname -ExportKeyPEM "$certfile.key.pem"
Get-ACMECertificate $certname -ExportCsrPEM "$certfile.csr.pem"

#Now create CER
Get-PfxCertificate -FilePath "$certfile.pfx" | 
Export-Certificate -FilePath "$certfile.CER" -Type CERT


