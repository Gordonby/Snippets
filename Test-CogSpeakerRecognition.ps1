#Convert stereo WAV to mono WAV and 16000Hz : http://audio.online-convert.com/convert-to-wav
$apikey = "your-api-key"
$headers = @{"Ocp-Apim-Subscription-Key"="$apikey"} 

#Create a new profile
$uri = "https://westus.api.cognitive.microsoft.com/spid/v1.0/identificationProfiles"
$newProfile= Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -ContentType 'application/json' -Body "{""locale"":""en-us"",}"
$profileId=$newProfile.identificationProfileId
Write-Host $profileId

#Create an enrolment
$uri = "https://westus.api.cognitive.microsoft.com/spid/v1.0/identificationProfiles/$profileId/enroll?shortAudio=1"
$soundFile = "EatNaturalm3.wav"
$enrol= Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -InFile $soundFile -ContentType 'multipart/form-data'

#Get profile status
$uri = "https://westus.api.cognitive.microsoft.com/spid/v1.0/identificationProfiles/$profileId"
$profile= Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
Write-Host "Status:" $profile.enrollmentStatus #Enrolling

if ($profile.enrollmentStatus -eq "Enrolling")
{
    Write-Host "Supply at least 30s audio to complete enrollent"

    #Create an enrolment
    $uri = "https://westus.api.cognitive.microsoft.com/spid/v1.0/identificationProfiles/$profileId/enroll?shortAudio=1"
    $soundFile = "Breadsallm.wav"
    $enrol= Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -InFile $soundFile -ContentType 'multipart/form-data'

}

#Get profile status
$uri = "https://westus.api.cognitive.microsoft.com/spid/v1.0/identificationProfiles/$profileId"
$profile= Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
Write-Host "Status:" $profile.enrollmentStatus #Enrolling

if ($profile.enrollmentStatus -eq "Enrolled")
{
    #Test identification
    $uri = "https://westus.api.cognitive.microsoft.com/spid/v1.0/identify?identificationProfileIds=$($profileId)&shortAudio=true"
    $soundFile = "testing123.wav"
    $profileMatch= Invoke-WebRequest $uri -Headers $headers -Method Post -InFile $soundFile -ContentType 'multipart/form-data'
    $operation = $profileMatch.Headers["Operation-Location"]
    Write-Host $operation

    $uri = $operation
    $isitdoneyet= Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    Write-Host $isitdoneyet

    if ($isitdoneyet.status -eq "succeeded")
    {
        Write-host $isitdoneyet.processingResult
    }

}
