#Get price sheet and usage details for the current period.
#https://docs.microsoft.com/en-us/azure/billing/billing-enterprise-api


function Get-AzureBillPricesheet
{
    param (
        [string] $enrollmentNo,
        [string] $accesskey
    )

    $authHeaders = @{"authorization"="bearer $accesskey"}
    $pricesheetUrl = "https://consumption.azure.com/v1/enrollments/$enrollmentNo/pricesheet"

    $psResponse = Invoke-WebRequest $pricesheetUrl -Headers $authHeaders
    if ($psResponse.StatusCode -eq 200) {
        #Write down to local disk to maintain a temp. seperate reference
        $psResponse.Content | Out-File "C:\temp\azure-price-sheet-$enrollmentNo.json"

        #Convert into proper PSObject
        $pricesheet = $psResponse.Content | ConvertFrom-Json

        return $pricesheet
    }
}

function Get-AzureBillUsage
{
    param (
        [string] $enrollmentNo,
        [string] $accesskey
    )

    $authHeaders = @{"authorization"="bearer $accesskey"}
    $usageUrl = "https://consumption.azure.com/v1/enrollments/$enrollmentNo/usagedetails"

    $usageDetails = @()
    while ($usageUrl -ne $null) #Looping as there are only 1000 lines of usage data returned per request
	{
		$uResponse = Invoke-WebRequest $usageUrl -Headers $authHeaders -ErrorAction Stop
		if ($uResponse.StatusCode -eq 200) {
			# Keep a copy of the content data portion (warning: this may get quite large)
			$usageDetails += ($uResponse.Content | ConvertFrom-Json).Data

			# Extract next pagination link
			$usageUrl = ($uResponse.Content | ConvertFrom-Json).nextLink
		}
	}

    return $usageDetails
}


$enrollmentNo = ""
$accesskey = ""

$pricesheet = Get-AzureBillPricesheet $enrollmentNo $accesskey
$usage = Get-AzureBillUsage $enrollmentNo $accesskey

$usage.count
$usage | ConvertTo-Json | Out-File "C:\temp\azure-usage-$enrollmentNo.json"
$usage | Export-Csv "C:\temp\azure-usage-$enrollmentNo.csv"
