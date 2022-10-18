
workflow Destory-ResourceGroupByTagValue
{
	Param
    (   
        [Parameter(Mandatory=$true)]
        [String]
        $tagName = "Environment",
        [Parameter(Mandatory=$true)]
        [String]
        $tagValue = "BlowMeUpAtMidnight"
    )
	

    #Connect
    $SPAppID = Get-AutomationVariable -Name 'SPCertAppID'
    $SPTenant = Get-AutomationVariable -Name 'SPCertTenant'
    $Certificate = Get-AutomationCertificate -Name "AutomatronC"
    $CertThumbprint = ($Certificate.Thumbprint).ToString()    

    Login-AzureRmAccount -ServicePrincipal -TenantId $SPTenant -CertificateThumbprint $CertThumbprint -ApplicationId $SPAppID 
    Select-AzureRmSubscription -SubscriptionId '' -TenantId $SPTenant
    
	#Shutdown machines
    #Shutdown machines
    $taggedResources = Find-AzureRmResource -TagName $tagName -TagValue $tagValue 

    $targetVms = $taggedResources | ?{$_.ResourceType -eq "Microsoft.Compute/virtualMachines"} | select resourcegroupname, name | Get-AzureRmVM -status

    ForEach ($vm in $targetVms)
    {
        Write-Output $vm.Name
       
        $currentpowerstatus = $vm |select -ExpandProperty Statuses | Where-Object{ $_.Code -match "PowerState" } | select Code, DisplayStatus
        Write-Output $currentpowerstatus

        if($Shutdown -and $currentpowerstatus -eq "PowerState/running"){
		    Write-Output "Stopping $($vm.Name)";		
		    Stop-AzureRmVm -Name $_.Name -ResourceGroupName $_.ResourceGroupName -Force;
	    }
	    elseif($Shutdown -and $currentpowerstatus -eq "PowerState/running"){
		    Write-Output "Starting $($vm.Name)";		
		    Start-AzureRmVm -Name $_.Name -ResourceGroupName $_.ResourceGroupName;
	    }
        else {
            Write-Output "VM $($vm.Name) is already in desired state : $currentpowerstatus";
        }
    }
}
