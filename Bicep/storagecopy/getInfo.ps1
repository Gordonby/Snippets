$ErrorActionPreference = 'SilentlyContinue'

if ($null -eq $Env:waitSeconds) {$Env:waitSeconds=5}
write-output "Sleeping for $Env:waitSeconds"; 
start-sleep -Seconds $Env:waitSeconds

write-output "Installed Modules"
Get-Module | Format-Table

cat /etc/os-release

# write-output "AZCopy version"
# try {
#     azcopy --version
# }
# catch {
#     write-output "AZCopy not found"
# }

# write-output "Azure CLI version"
# try {
#     az --version
#     write-output
# }
# catch {
#     write-output "Azure CLI not found"
# }


