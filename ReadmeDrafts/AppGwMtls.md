Generate a certificate
```bash
domain='mtls.azdemo.co.uk'
sudo certbot certonly --manual --preferred-challenges dns -d $domain
```

Add TXT challenge to DNS Zone
```azurecli

```

Generate the pfx
```bash
sudo openssl pkcs12 -inkey /etc/letsencrypt/live/$domain/privkey.pem -in /etc/letsencrypt/live/$domain/cert.pem -export -out /etc/letsencrypt/live/$domain/pkcs12.pfx
```

Download the root CA
```bash
curl -O https://letsencrypt.org/certs/isrgrootx1.pem
```

Combine the public key with the LetsEncrypt root CA, ready for AppGw.
```bash
cat cert.pem isrgrootx1.pem > bundle2.pem
```

Create listener using PFX
```azurecli

```

Add SSL Profile
```azurecli

```
