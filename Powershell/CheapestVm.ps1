# For a specifc region, gather pricing data and return the cheapest vms

$page1url="https://prices.azure.com/api/retail/prices?`$skip=0&`$filter=serviceName eq 'Virtual Machines' and priceType eq 'Consumption' and contains(meterName, 'Spot') and armRegionName eq 'uksouth'"
$page1 = $(Invoke-RestMethod -Method get -Uri $page1url)
$page1.Items | select retailPrice, armSkuName, armRegionName


$page1.Items | select retailPrice, armSkuName, armRegionName | Export-csv azvmprice.csv -append

$page
