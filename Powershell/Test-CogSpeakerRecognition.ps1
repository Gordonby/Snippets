#Gordon.byers@microsoft.com
#Powershell script is provided as-is and without any warranty of any kind

#Sample uses 2 WAV files to provide sample of users voice, then additionally another WAV file to test the verification
#If you use Windows Voice Recorder to record in m4a, make sure to convert to mono WAV and 16000Hz using http://audio.online-convert.com/convert-to-wav


$apikey = "your-api-key" #Enter your Azure speech recognition cognitive service access key 
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

    #Provide an additional enrollment audio sample
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
    
    #Extract location to poll for progress
    $operation = $profileMatch.Headers["Operation-Location"]
    Write-Host $operation

    #Check identification progress
    $uri = $operation
    $isitdoneyet= Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    Write-Host $isitdoneyet

    #Write output of identification test
    if ($isitdoneyet.status -eq "succeeded")
    {
        Write-host $isitdoneyet.processingResult
    }

}
