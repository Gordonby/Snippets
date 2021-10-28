
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
```
