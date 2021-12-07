Connect-AzAccount

Select-AzSubscription -SubscriptionName '*********'

$RG='***********'
$AKVNAME='***********'
$CERTNAME='aksbicepci'

Write-Output "Creating Certificate $CERTNAME in $AKVNAME"

$policy = New-AzKeyVaultCertificatePolicy -CertificateTransparency $null -IssuerName 'Self' -KeySize 2048 -KeyType RSA -RenewAtNumberOfDaysBeforeExpiry 28 -SecretContentType "application/x-pkcs12" -SubjectName "CN=$CERTNAME" -ValidityInMonths 2
$CertRequest = Add-AzKeyVaultCertificate -VaultName $AKVNAME -Name $CERTNAME -CertificatePolicy $policy
Start-Sleep -Seconds 60
Get-AzKeyVaultCertificate -VaultName $AKVNAME -Name $CERTNAME




$cert = Get-AzKeyVaultCertificate -VaultName $AKVNAME -Name $CERTNAME
$secret = Get-AzKeyVaultSecret -VaultName $AKVNAME -Name $cert.Name -AsPlainText
$secretByte = [Convert]::FromBase64String($secret)

# Write to a file
$certOutPath = "C:\Temp\cert\$CERTNAME.pfx"
[System.IO.File]::WriteAllBytes($certOutPath, $secretByte)

$parsedCert = Get-PfxData -FilePath $certOutPath
$parsedCert.EndEntityCertificates | Select-Object -Property *
