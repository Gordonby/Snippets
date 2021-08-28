#go download your microsoft learn data
$learnusername="airgordon"

$downloadUrl="https://docs.microsoft.com/en-us/users/$learnusername/settings"
start-process $downloadUrl

#grab the file from downloads
$defaultDownloadDir = "$HOME\Downloads"
$latestJsonFile = Get-ChildItem $defaultDownloadDir -Attributes !Directory *.json | 
                    Sort-Object -Descending -Property LastWriteTime | 
                    select-object -First 1

#parse the file
$jsonLearnHistory = Get-Content $latestJsonFile
$learnHistory = $jsonLearnHistory | ConvertFrom-Json

#spit out the certification test results
$results = $learnHistory.Certifications.privacySnapshots | 
    Select-Object createdAt, certificationUid, 
        @{N='Passed';E={$_.snapshotScore.passed}},
        @{N='PassPercent';E={$_.snapshotScore.passingPercent}},
        @{N='CorrectPercent';E={$_.snapshotScore.correctPercent}}

Write-Output "Recertifications of MS Exams through the Microsoft.com/learn process"
$results | Where-Object Passed -eq $true | Format-Table