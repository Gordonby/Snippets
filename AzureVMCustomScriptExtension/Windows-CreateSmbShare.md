# Creating a SMB Share on Windows, with PowerShell

### Creation script

```powershell
$dirName ="SmbShare4"
$dirPath = "c:\$dirName"
$username = "user4"

Write-Output "Creating user account"
$Password = "zeP4ssW0RD%%" | ConvertTo-SecureString -AsPlainText -Force
New-LocalUser $username -Password $Password -FullName "aks smb test" -Description "Account to demo smb share"

Write-Output "Create SMB share"
New-Item $dirPath -type directory
New-SMBShare -Name $dirName -Path $dirPath

Write-Output "Grant $username permission to write to $dirName"
Grant-SmbShareAccess -Name $dirName -AccountName $username -AccessRight Full -force


#Anonymous share creation
$anonShareName="anon"
$anonDirPath="c:\$anonShareName"
New-Item $anonDirPath -type directory
New-SmbShare -Name $anonShareName -path $anonDirPath -FullAccess 'ANONYMOUS LOGON','Everyone'
```

### Output 

```text
Name      ScopeName AccountName    AccessControlType AccessRight
----      --------- -----------    ----------------- -----------
SmbShare4 *         Everyone       Allow             Read
SmbShare4 *         winjump2\user4 Allow             Full
```
