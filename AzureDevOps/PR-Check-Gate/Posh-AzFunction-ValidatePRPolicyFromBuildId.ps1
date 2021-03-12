using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Set constants
#Define any PolicyTypes that we want to exclude from our policy checks
$exclusionsTypes =@("Build")

# Hydrate params from body of the request.
$buildId = $Request.Body.buildId
$projectId = $Request.Body.ProjectId
$ADOPROJ = $Request.Body.Project
$uri = $Request.Body.URI

# Write some of the parameters to the logs
Write-Verbose "Received BuildId: $buildId"
Write-Verbose "Received Uri: $uri"
Write-Verbose "Received project: $ADOPROJ"
Write-Verbose "Received projectId: $projectId"

#Basic validation of passed parameters
if($buildId -eq $NULL) { Write-Error "buildId not provided"; Return }
if($projectId -eq $NULL) { Write-Error "ProjectId not provided"; Return }
if($ADOPROJ -eq $NULL) { Write-Error "Project not provided"; Return }
if($uri -eq $NULL) { Write-Error "URI not provided"; Return }

#Use the Azure
if (-not $Request.Body.AuthToken) {
    try{
        Write-Verbose "Setting PAT token from AppSettings"
        $patenv=ls env:APPSETTING_ADO_PAT
        $pat =  $patenv.Value
    } catch {
        $failure = $_.Exception.Message
        Write-Error "[ERROR] Failed to GET PAT token from AppSettings or Request Body. $failure"
        Return
    }
} else {
    Write-Verbose "Setting token from Request Body Parameter"
    $pat = $Request.Body.AuthToken
}
if($pat.Length -lt 1) { Write-Error "WARNING: PAT Token is empty"; Return}

#Base64 encode the PAT token, ready for a HTTP request header
$base64AuthInfo= [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))

#Figure out the Orgname from URI. TODO. Write a Regex for this.
$ADOORG=$uri.replace("https://","").replace(".visualstudio.com/","")

$BuildURL="https://dev.azure.com/$ADOORG/$ADOPROJ/_apis/build/builds/$($BUILDID)?api-version=6.0"

Write-Verbose "Calling $BuildURL"
$buildresponse=Invoke-RestMethod -Uri $BuildURL -Headers @{Authorization = "Basic {0}" -f $base64AuthInfo} -Method Get
$PR=$buildresponse.triggerInfo.'pr.number'
$PROJID=$buildresponse.project.id

Write-Host "Resolved PR: $PR from BuildId $BUILDID"

if($PR.Length -lt 1) { Write-Error "WARNING: Failed to Retrieve Valid Pull Request ID from Build $buildId"; Return}

Write-Verbose "Checking PR Policy"
$ARTIFACTID="vstfs:///CodeReview/CodeReviewId/$PROJID/$PR"
$PRURL="https://dev.azure.com/$ADOORG/$ADOPROJ/_apis/policy/evaluations?artifactId=$ARTIFACTID&api-version=6.1-preview.1"
$prresponse=Invoke-RestMethod -Uri $PRURL -Headers @{Authorization = "Basic {0}" -f $base64AuthInfo} -Method Get

$BlockingPolicies=@()
$prresponse.value | % {
    #$policyCheck= $response.value[0]
    $policyCheck = $_

    Write-Verbose "$($policyCheck.configuration.isEnabled) $($policyCheck.configuration.isBlocking) $($policyCheck.configuration.type.displayName) $($policyCheck.status)"

    if($policyCheck.configuration.isEnabled -and $policyCheck.configuration.isBlocking -and $policyCheck.configuration.type.displayName -notin $exclusionsTypes) {
        #We'll now step through any potential blocking policies.

        if ($policyCheck.status -ne "approved") {
            #Add policies that are currently blocking us to the output array
            $BlockingPolicies += $policyCheck.configuration.type.displayName
            Write-Output "$($policyCheck.configuration.type.displayName) is blocking PR.  state= $($policyCheck.status)"
        }
    }
}

Write-Verbose $BlockingPolicies.count
if($BlockingPolicies.count -eq 0) {$prStatus = "Satisfied"} else {$prStatus = "Waiting"}

$returnObj = New-Object PSObject -Property ([Ordered]@{prstatus=$prStatus; BlockingPolicies=$BlockingPolicies })
Write-Verbose $returnObj

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $returnObj
})
