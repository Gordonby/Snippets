$dirName="SmbShare"
$dirPath = "c:\$dirName"

New-Item $dirPath -type directory

New-SMBShare -Name $dirName -Path $dirPath
