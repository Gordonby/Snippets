#Gordon.byers@microsoft.com
#Powershell script is provided as-is and without any warranty of any kind

$moveLonelyStorageAccounts=$false

Connect-AzAccount
Select-AzSubscription -Subscription "YourAzureDevSubscription"

$ManagedDisks = Get-AzDisk | Where-Object { $_.ManagedBy -eq $Null }
$ManagedDisks | % {
    Write-Output "Deleting unattached Managed Disk with Name: $($_.Name)"
    $_ | Remove-AzDisk -ErrorAction Continue -Force
}

$nics = Get-AzNetworkInterface | Where-Object {$_.VirtualMachine -eq $null}
$nics | % {
    Write-Output "Deleting unattached Nic: $($_.Name)"
    $_ | Remove-AzNetworkInterface -Force
}

$lbs = Get-AzLoadBalancer 
$lbs | % {
    $config = $_ | Get-AzLoadBalancerBackendAddressPoolConfig
    if($config.BackendIpConfigurations.Count -eq 0) {
        Write-Output "Removing Load Balancer $($_.Name)"
        $_ | Remove-AzLoadBalancer -Force
    }
}

$pips = Get-AzPublicIpAddress | ? {$_.IpConfiguration -eq $null }
$pips | % {
    Write-Output "Deleting public ip : $($_.Name)"
    $_ | Remove-AzPublicIpAddress -Force
}

$nsgs = Get-AzNetworkSecurityGroup | ? {$_.NetworkInterfaces.Count -eq 0}
$nsgs | % {
    Write-Output "Deleting network security group : $($_.Name)"
    $_ | Remove-AzNetworkSecurityGroup -Force
}

$asps = Get-AzAppServicePlan | ? {$_.NumberOfSites -eq 0}
$asps | % {
    Write-Output "Deleting app service plan : $($_.Name)"
    $_ | Remove-AzAppServicePlan -Force
}

$vnets = Get-AzVirtualNetwork
$vnets | % {
    $vnet = $_
    $configs = $_ | Get-AzVirtualNetworkSubnetConfig

    $configs | % {
        if ($_.IpConfigurations.Count -eq 0) {
            Write-Output "Removing unused subnet $($_.Name) from $($vnet.Name)"
            Remove-AzVirtualNetworkSubnetConfig -Name $_.Name -VirtualNetwork $vnet | Set-AzVirtualNetwork | out-null
        }
    }
}

$vnetsNoSubnets = Get-AzVirtualNetwork | ? {$_.Subnets.Count -eq 0}
$vnetsNoSubnets | % {
    Write-Output "Removing vnet $($_.Name)"
    $_ | Remove-AzVirtualNetwork -Force
}

if($moveLonelyStorageAccounts -eq $true)
{
    $storageResourceGroup = Get-AzResourceGroup "MiscStorageAccounts"
    if ($storageResourceGroup -eq $null) {
        $storageResourceGroup = New-AzResourceGroup "MiscStorageAccounts" -Location "UKSouth"
    }

    $rgs= Get-AzResourceGroup
    $rgs | % {
        $resources = Get-AzResource -ResourceGroupName $_.ResourceGroupName

        if ($resources.count -eq 1) {
            $resourceName = $resources.Name
            $resourceType = $resources.ResourceType
            $resouceId = $resources.ResourceId
            Write-Output "Service $resourceType ($resourceName) found all alone, awwww (how unusual)"

            switch ($resourceType) {
               "Microsoft.Storage/storageAccounts" {
                    Write-Output "Moving storage account $resourceName to $($storageResourceGroup.ResourceGroupName)"
                    Move-AzResource -DestinationResourceGroupName $storageResourceGroup.ResourceGroupName -ResourceId $resouceId -Force
                
                    break
               }
               default {
                    break
               }
            }
        }
    }
}

#Finally, do another loop round for empty resource groups without tags.
$rgs= Get-AzResourceGroup
$rgs | ? {$_.Tags.count -eq 0} | % {
    $resources = Get-AzResource -ResourceGroupName $_.ResourceGroupName

    if ($resources.count -eq 0) {
        #Get rid of empty resource groups.
        $_ | Remove-AzResourceGroup -Force | out-null
        Write-Output "$($_.ResourceGroupName) blown away"
    }
}
