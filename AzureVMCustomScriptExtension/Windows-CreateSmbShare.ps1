$dirName="SmbShare"
$dirPath = "c:\$dirName"

New-Item $dirPath -type directory

New-SMBShare -Name $dirName -Path $dirPath

New-SmbShare -Name 'anon' -path 'c:\anon' -FullAccess 'ANONYMOUS LOGON','Everyone'

$Password = "zeP4ssW0RD%%" | ConvertTo-SecureString -AsPlainText -Force
New-LocalUser "user1" -Password $Password -FullName "aks smb test" -Description "Account to demo smb share"
