# GPG Signed Commit Setup for Github

```powershell
gpg --full-generate-key
gpg --list-secret-keys --keyid-format=long

git config --global user.signingkey <COPYTHISFROMCMDOUTPUTABOVE>
git config --global commit.gpgsign true
git config --global gpg.program "C:\Program Files (x86)\gnupg\bin\gpg.exe"
git config --global commit.gpgsign true
```

```bash
#WSL
git config --global gpg.program "/mnt/c/Program Files (x86)/gnupg/bin/gpg.exe"
```

## vscode settings
  
- Git: Enable Commit Signing
- Git: Always Sign Off
  
## ref

- https://community.chocolatey.org/packages/gnupg
- https://dev.to/devmount/signed-git-commits-in-vs-code-36do
