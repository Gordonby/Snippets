
Using ZAP security scanning

```yaml
WorkloadTests:
    runs-on: ubuntu-latest
    needs: [Deploy,WorkloadAdd]
    environment: azurecirgs
    steps:
      - uses: actions/checkout@v2
      
      - name: Param check
        run: |
          RG='${{ env.RG }}'
          echo "RG is: $RG"
          
          #echo "SIMWORKLOADIP name is ${{ needs.Deploy.outputs.AKSNAME}}"
          echo "SIMWORKLOADIP name is ${{ needs.WorkloadAdd.outputs.SIMWORKLOADIP}}"
          echo "AKS name is ${{ needs.Deploy.outputs.AKSNAME}}"
          
      
      - name: ZAP Scan
        uses: zaproxy/action-full-scan@v0.3.0
        with:
          target: 'http://${{ needs.WorkloadAdd.outputs.SIMWORKLOADIP}}'
          allow_issue_writing: false

      - name: Check for High Priority Zap Alerts
        shell: pwsh
        run: |
          Write-Output "Check for Zap Json file"
          Test-Path report_json.json
          
          $zap = get-content report_json.json | ConvertFrom-Json
          Write-Output $zap
          
          $highAlerts = $zap.site.alerts | Where-Object {$_.riskcode -eq 3}
          $mediumAlerts = $zap.site.alerts | Where-Object {$_.riskcode -eq 2}

          #Define to suit your business.
          #I'm going high, so my CI tests pass, but usually you'd set this to 0
          $HighThreshold = 5
          $MediumThreshold = 10

          #raise error if high alerts are over threshold
          if ($highAlerts.count -gt $HighThreshold) {
              Write-Output "High Alerts Found"
              $highAlerts | Where-Object { Write-Output $_.alert }
              throw "High Alerts Found"
          }

          #raise error if medium alerts are over threshold
          if ($mediumAlerts.count -gt $MediumThreshold) {
            Write-Output "Medium Alerts Found"
            $highAlerts | Where-Object { Write-Output $_.alert }
            throw "Medium Alerts Found"
          }

```

PowerShell for working with AKV

```yaml

    
      - name: Azure Login
        uses: Azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
          enable-AzPSSession: true
          environment: azurecloud
          allow-no-subscriptions: false

      - name: Install KeyVault Pwsh module
        shell: pwsh
        run: |
          Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
          Install-Module -Name Az.KeyVault -Force
          
      - name: Add KV access policy for certificates for this CI action user
        shell: pwsh
        run: |
          $CiSpId='${{ secrets.AZURE_CREDENTIALS_OBJID }}'
          $AKVNAME='${{ needs.Deploy.outputs.AKVNAME}}'
          
          Set-AzKeyVaultAccessPolicy -VaultName $AKVNAME -ObjectId $CiSpId -PermissionsToCertificates all -PermissionsToSecrets get,list
          
      - name: Create self signed cert in Key Vault
        env:
          CERTNAME: "openjdk-demo-service-pwsh"
        shell: pwsh
        run: |
            $RG='${{ env.RG }}'
            $AKVNAME='${{ needs.Deploy.outputs.AKVNAME}}'
            $CERTNAME='${{ env.CERTNAME }}'

            Write-Output "Creating Certificate $CERTNAME in $AKVNAME"
            $policy = New-AzKeyVaultCertificatePolicy -CertificateTransparency $null -IssuerName 'Self' -KeySize 2048 -KeyType RSA -RenewAtNumberOfDaysBeforeExpiry 28 -SecretContentType "application/x-pkcs12" -SubjectName "CN=$CERTNAME" -ValidityInMonths 2
            $CertRequest = Add-AzKeyVaultCertificate -VaultName $AKVNAME -Name $CERTNAME -CertificatePolicy $policy
            
            Write-Output $CertRequest.Id

      - name: Test retrieving self signed certificate from AKV
        env:
          CERTNAME: "openjdk-demo-service-pwsh"
        shell: pwsh
        run: |
            $RG='${{ env.RG }}'
            $AKVNAME='${{ needs.Deploy.outputs.AKVNAME}}'
            $CERTNAME='${{ env.CERTNAME }}'
            
            start-sleep -Seconds 90

            Write-Output "Getting Certificate $CERTNAME from $AKVNAME"
            $cert = Get-AzKeyVaultCertificate -VaultName $AKVNAME -Name $CERTNAME
            $secret = Get-AzKeyVaultSecret -VaultName $AKVNAME -Name $cert.Name -AsPlainText
            $secretByte = [Convert]::FromBase64String($secret)
            
     - name: Create a self signed cert in Key Vault for a FE sample app
        env:
          CERTNAME: "aspnetapp"
        shell: pwsh
        run: |
            $RG='${{ env.RG }}'
            $AKVNAME='${{ needs.Deploy.outputs.AKVNAME}}'
            $CERTNAME='${{ env.CERTNAME }}'
            Write-Output "Creating Certificate $CERTNAME in $AKVNAME"
            $policy = New-AzKeyVaultCertificatePolicy -CertificateTransparency $null -IssuerName 'Self' -KeySize 2048 -KeyType RSA -RenewAtNumberOfDaysBeforeExpiry 28 -SecretContentType "application/x-pkcs12" -SubjectName "CN=$CERTNAME" -ValidityInMonths 2
            $CertRequest = Add-AzKeyVaultCertificate -VaultName $AKVNAME -Name $CERTNAME -CertificatePolicy $policy
            
            Write-Output $CertRequest.Id
            
      - name: Create Cert reference in AppGW for FE Sample App
        env:
          CERTNAME: "aspnetapp"
          APPGWSSELCERTNAME: "mykvsslcert"
        run: |
          AGNAME='${{ needs.Deploy.outputs.AGNAME}}'
          RG='${{ env.RG }}'
          KVNAME='${{ needs.Deploy.outputs.AKVNAME}}'
          CERTNAME='${{ env.CERTNAME }}'
          APPGWSSELCERTNAME='${{ env.APPGWSSELCERTNAME }}'
          
          echo "Waiting for cert"
          sleep 1m
                    
          versionedSecretId=$(az keyvault certificate show -n $CERTNAME --vault-name $KVNAME --query "sid" -o tsv)
          echo $versionedSecretId
          
          unversionedSecretId=$(echo $versionedSecretId | cut -d'/' -f-5) # remove the version from the url
          echo $unversionedSecretId
          
          ## Create Cert reference in AppGW
          az network application-gateway ssl-cert create \
            -n $APPGWSSELCERTNAME \
            --gateway-name  $AGNAME \
            --resource-group $RG  \
            --key-vault-secret-id $unversionedSecretId 
```
