$dirName="SmbShare"
$dirPath = "c:\$dirName"

New-Item $dirPath -type directory

New-SMBShare -Name $dirName -Path $dirPath

$Password = "zeP4ssW0RD%%" | ConvertTo-SecureString -AsPlainText -Force
PS C:\Users\admingeneric> New-LocalUser "user1" -Password $Password -FullName "aks smb test" -Description "Account to demo smb share"
