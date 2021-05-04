$ImdsServer = "http://169.254.169.254"
$InstanceEndpoint = $ImdsServer + "/metadata/instance"

$uri = $InstanceEndpoint + "?api-version=2019-03-11"
$result = Invoke-RestMethod -Method GET -Proxy $Null -Uri $uri -Headers @{"Metadata"="True"}

# Make Instance call and print the response
$result = Query-InstanceEndpoint
echo "whats my name again"
$result.compute.name


#$result | ConvertTo-JSON -Depth 99

{
#     "compute":  {
#                     "azEnvironment":  "AzurePublicCloud",
#                     "customData":  "",
#                     "location":  "westeurope",
#                     "name":  "GordDevMachine",
#                     "offer":  "WindowsServer",
#                     "osType":  "Windows",
#                     "placementGroupId":  "",
#                     "plan":  {
#                                  "name":  "",
#                                  "product":  "",
#                                  "publisher":  ""
#                              },
#                     "platformFaultDomain":  "0",
#                     "platformUpdateDomain":  "0",
#                     "provider":  "Microsoft.Compute",
#                     "publicKeys":  [

#                                    ],
#                     "publisher":  "MicrosoftWindowsServer",
#                     "resourceGroupName":  "SurfaceGo",
#                     "resourceId":  "/subscriptions//resourceGroups//providers/Microsoft.Compute/virtualMachines/GordDevMachine",
#                     "sku":  "2016-Datacenter-smalldisk",
#                     "subscriptionId":  "",
#                     "tags":  "",
#                     "version":  "2016.127.20180510",
#                     "vmId":  "",
#                     "vmScaleSetName":  "",
#                     "vmSize":  "Standard_D4s_v3",
#                     "zone":  ""
#                 },
#     "network":  {
#                     "interface":  [
#                                       {
#                                           "ipv4":  {
#                                                        "ipAddress":  [
#                                                                          {
#                                                                              "privateIpAddress":  "172.18.7.4",
#                                                                              "publicIpAddress":  "51.1.1.1"
#                                                                          }
#                                                                      ],
#                                                        "subnet":  [
#                                                                       {
#                                                                           "address":  "172.18.7.0",
#                                                                           "prefix":  "24"
#                                                                       }
#                                                                   ]
#                                                    },
#                                           "ipv6":  {
#                                                        "ipAddress":  [

#                                                                      ]
#                                                    },
#                                           "macAddress":  "000D3A445608"
#                                       }
#                                   ]
#                 }
# }
