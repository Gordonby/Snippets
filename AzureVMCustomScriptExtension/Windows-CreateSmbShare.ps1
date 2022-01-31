$dirName ="SmbShare2"
$dirPath = "c:\$dirName"
$username = "user3"

Write-Output "Creating user account"
$Password = "zeP4ssW0RD%%" | ConvertTo-SecureString -AsPlainText -Force
New-LocalUser $username -Password $Password -FullName "aks smb test" -Description "Account to demo smb share"

Write-Output "Create SMB share"
New-Item $dirPath -type directory
New-SMBShare -Name $dirName -Path $dirPath

Write-Output "Grant $username permission to write to $dirName"
Grant-SmbShareAccess -Name $dirName -AccountName $username -AccessRight Full -force


#Anonymous share creation
New-SmbShare -Name 'anon' -path 'c:\anon' -FullAccess 'ANONYMOUS LOGON','Everyone'
