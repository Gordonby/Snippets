#Test script, hardcoded vars

$pat = "xw23hqxy3zdn2erfdhmicgav66jhzfv7qagqw2h7wzhyl7dblnfq"
$base64AuthInfo= [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$ADOORG="gdoggmsft"
$ADOPROJ="EntScaleTwoOh"
$BUILDID="242"

$BuildURL="https://dev.azure.com/$ADOORG/$ADOPROJ/_apis/build/builds/$($BUILDID)?api-version=6.0"

$buildresponse=Invoke-RestMethod -Uri $BuildURL -Headers @{Authorization = "Basic {0}" -f $base64AuthInfo} -Method Get
$PR=$buildresponse.triggerInfo.'pr.number'
$PROJID=$buildresponse.project.id

$ARTIFACTID="vstfs:///CodeReview/CodeReviewId/$PROJID/$PR"

$PRURL="https://dev.azure.com/$ADOORG/$ADOPROJ/_apis/policy/evaluations?artifactId=$ARTIFACTID&api-version=6.1-preview.1"
$prresponse=Invoke-RestMethod -Uri $PRURL -Headers @{Authorization = "Basic {0}" -f $base64AuthInfo} -Method Get

$exclusionsTypes =@("Build")

$BlockingPolicies=@()
$prresponse.value | % {
    #$policyCheck= $response.value[0]
    $policyCheck = $_

    Write-Output "$($policyCheck.configuration.isEnabled) $($policyCheck.configuration.isBlocking) $($policyCheck.configuration.type.displayName) $($policyCheck.status)"

    if($policyCheck.configuration.isEnabled -and $policyCheck.configuration.isBlocking -and $policyCheck.configuration.type.displayName -notin $exclusionsTypes) {
        $BlockingPolicies += $policyCheck.configuration.type.displayName
        Write-Output "$($policyCheck.configuration.type.displayName) is blocking us.  state= $($policyCheck.status)"
    }
}

if($BlockingPolicies.length -eq 0) {$prStatus = "Satisfied"} else {$prStatus = "Waiting"}

$returnObj = New-Object PSObject -Property ([Ordered]@{prstatus="NotCool"; BlockingPolicies=$BlockingPolicies })
Write-Output $returnObj