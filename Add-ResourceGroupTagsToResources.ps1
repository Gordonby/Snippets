#Gordon.byers@microsoft.com
#Powershell script is provided as-is and without any warranty of any kind

function Add-ResourceGroupTagsToResources() 
{
    #V1.0 2016-06-29
    param (
        [Parameter(Mandatory=$true)]
        [string] $resourceGroupName
    )
    
    $taggedResourceGroups = $null

    $resourceGroup =  Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue

    if($resourceGroup -eq $null) {
        Write-Error "Resource Group : $resourceGroupName not found in subscription"
        return;
    }

    $taggedResourceGroups = $resourceGroup | where-object {$_.Tags.count -gt 0} 

    if ($taggedResourceGroups -eq $null)
    {
        Write-Warning "$resourceGroupName found - no tags defined to add to resources"
    }
    else {
        Write-Host "Finding Resources to tag for resourcegroup : $($resourceGroup.ResourceGroupName)"
        $rgTagsTable = $resourceGroup.TagsTable
        $rgTagCount = $resourceGroup.Tags.count
        $rgTagKeys = @()
        $resourceGroup.Tags | %{$rgTagKeys += $_["Name"]}

        $resoucesToTag = Get-AzureRmResource -ResourceGroupName $resourceGroup.ResourceGroupName -ResourceName " "

        ForEach($resource in $resoucesToTag) 
        { 
            If($resource.Tags.Count -eq 0) 
            {
                Write-Host "Resource $($resource.Name)  has no tags, adding full set of $rgTagCount tags"
                Set-AzureRmResource -ResourceId $resource.ResourceId -Tag $resourceGroup.Tags -Force
            }
            else {
                Write-Verbose "Resource $($resource.Name) ($($resource.ResourceType)) has existing tags found"
                
                $resourceTagKeys = @()
                ForEach($tag in $resource.tags)
                {
                    $resourceTagKeys += $tag["Name"]
                }

                $extraTags = Compare-Object -ReferenceObject $rgTagKeys -DifferenceObject $resourceTagKeys

                if($extraTags -eq $null)
                {
                    Write-Host "Resource $($resource.Name) ($($resource.ResourceType)) tags are up to date"
                }
                else {
                    Write-Verbose "Merging tags for $($resource.Name) ($($resource.ResourceType))"

                    $tagKeysToAdd = $($extraTags | Where-Object { $_.SideIndicator -eq "<="})

                    if ($tagKeysToAdd -eq $null) {
                        $resourceSpecificTags = $($extraTags | Select-Object -ExpandProperty InputObject) -join ', '
                        Write-Host "Resource $($resource.Name) ($($resource.ResourceType)) has extra tags from its Resource Group ($resourceSpecificTags). inherited tags are up to date"
                    }
                    else {
                        $tagsToUpdate = $resource.tags 

                        ForEach ($tagKeyToAdd in $tagKeysToAdd) {
                            Write-Verbose "For $($resource.Name) ($($resource.ResourceType)) tag $($tagKeyToAdd.InputObject) is missing."
                            $value = $($rg.Tags | Where-Object {$_["Name"] -eq $tagKeyToAdd.InputObject})["Value"]
                   
                            $tagsToUpdate += @{Name=$tagKeyToAdd.InputObject;Value=$value} 
                        }

                        Write-Host "Resource $($resource.Name) ($($resource.ResourceType)) : updating extra tags"
                        Set-AzureRmResource -ResourceId $resource.ResourceId -Tag $tagsToUpdate -Force
                    }
                }

            }

        }
    }
}

Login-AzureRmAccount

$allResourceGroups = Get-AzureRmResourceGroup

ForEach ($resourceGroup in $allResourceGroups) {
    Add-ResourceGroupTagsToResources -resourceGroupName $resourceGroup.ResourceGroupName
}
