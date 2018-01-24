#Gordon.byers@microsoft.com
#Powershell script is provided as-is and without any warranty of any kind

param (
    $statuscakeUsername="GordonbMsft",
    $stauscakeApiKey="Gd2plF9ffJ5xTzv7LFWH"
)

#Get list of urls that are currently being tested.
$definedUrlTestNames = Get-StatusCakeTests $statuscakeUsername $stauscakeApiKey | Select-Object WebsiteName | % {$_.WebsiteName}

#Use in the event you want to reset Status Cake.
#$definedUrlTestIds =Get-StatusCakeTests $statuscakeUsername $stauscakeApiKey | Select-Object TestID | % {$_.TestId}
#Delete-StatusCakeTests $statuscakeUsername $stauscakeApiKey 2325596 $definedUrlTestIds

#Get detailed test information - if needed
#Get-StatusCakeDetailedTest $statuscakeUsername $stauscakeApiKey


#Login to Azure
Login-AzureRmAccount 

#Grab a list of all the web apps
$allwebapps = Get-AzureRmWebApp 
$webAppNames = $allwebapps | Select-Object Name | % {$_.Name}

#Filter down to just the unmonitored webapps
$webAppsNamesToAdd = Compare-Object $webAppNames $definedUrlTestNames -PassThru
Write-Output "Azure has $($allwebapps.Count) web apps defined.  $($webAppsNamesToAdd.count) of them do not have a Url test set up in Statuscake."

$webAppsToAdd = $allwebapps | Where-Object {$webAppsNamesToAdd -contains $_.Name } | Select-Object Name, ResourceGroup, Hostnames

$webAppsToAdd | % {

    $hostnames = $_.hostnames.split(",")
    $hostname = if($hostnames -isnot [system.array]) {$hostnames} else {$hostnames[0]}

    Write-Output "Setting up url test for $($_.Name) on hostname $($hostname)"
            
    Add-StatusCakeTestUrl $statuscakeUsername $stauscakeApiKey $_.Name $hostname
}

function Delete-StatusCakeTests() {
    param (
        [string] $statuscakeUsername,
        [string] $stauscakeApiKey,
        $testIds
    )

    $baseurl = "https://www.statuscake.com/API"
    $testurl = "$baseurl/Tests"
    $authHeaders = @{"Username"="$statuscakeUsername";"API"="$stauscakeApiKey"}

    $testIds | % {
        $url = $testurl +"/Details/?TestID=$_"
        Write-Output $url
        $tResponse = Invoke-WebRequest $url -Headers $authHeaders -Method Delete
    }
    return $tResponse
}

function Get-StatusCakeTests() {
    param (
        [string] $statuscakeUsername,
        [string] $stauscakeApiKey
    )

    $baseurl = "https://www.statuscake.com/API"
    $testurl = "$baseurl/Tests"
    $authHeaders = @{"Username"="$statuscakeUsername";"API"="$stauscakeApiKey"}

    $tResponse = Invoke-WebRequest $testurl  -Headers $authHeaders
    $definedUrlTests = $tResponse.Content | ConvertFrom-Json

    return $definedUrlTests
}

function Get-StatusCakeDetailedTest() {
    param (
        [string] $statuscakeUsername,
        [string] $stauscakeApiKey,
        $testId
    )

    $baseurl = "https://www.statuscake.com/API"
    $testurl = "$baseurl/Tests"
    $authHeaders = @{"Username"="$statuscakeUsername";"API"="$stauscakeApiKey"}

    $tResponse = Invoke-WebRequest "$testurl/Details/?TestID=$testId"  -Headers $authHeaders
    $testData = $tResponse.Content | ConvertFrom-Json

    return $testData
}

function Add-StatusCakeTestUrl() {
    param (
        [string] $statuscakeUsername,
        [string] $stauscakeApiKey,
        [string] $websiteName,
        [string] $websiteUrl
    )

    $baseurl = "https://www.statuscake.com/API"
    $testurl = "$baseurl/Tests/"
    $authHeaders = @{"Username"="$statuscakeUsername";"API"="$stauscakeApiKey"}

    $testParams = @{WebsiteName="$websiteName"  ;
                    WebsiteURL=$websiteUrl;
                    WebsiteHost="Microsoft Azure";
                    CheckRate="300";
                    TestType="HTTP";
                    ContactGroup="0";
                    Confirmation=3;
                    }
    $tResponse = Invoke-WebRequest "$testurl/Update" -Headers $authHeaders -Method Put -Body $testParams
    $tResult = $tResponse.content | ConvertFrom-Json

    return $tRestult
}
