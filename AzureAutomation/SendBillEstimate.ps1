workflow Send-BillEstimate
{
    param (
        [Parameter(Mandatory=$true)]
        [string] 
        $enrollmentNo = "",

        [Parameter(Mandatory=$true)]
        [string] 
        $accesskey = "",

        [Parameter(Mandatory=$true)]
        [string] 
        $mailfrom="",

        [Parameter(Mandatory=$true)]
        [string]
        $mailto="",

        [Parameter(Mandatory=$true)]
        [string]
        $smtpServer = "",
        
        [Parameter(Mandatory=$true)]
        [PSCredential] 
        $smtpServerCreds       
    )
    
    $baseurl = "https://ea.azure.com/rest/"
    $authHeaders = @{"authorization"="bearer $accesskey";"api-version"="1.0"}

    Write-Verbose "Getting billing summary"
    $url= $baseurl + $enrollmentNo + "/usage-reports"
    Write-Verbose $url
    $sResponse = InlineScript {Invoke-WebRequest $using:url -Headers $using:authHeaders -UseBasicParsing}
    Write-Verbose $sResponse.StatusCode
    $sContent = $sResponse.Content | ConvertFrom-Json 

    $month=$sContent.AvailableMonths[-1].Month
    $url= $baseurl + $enrollmentNo + "/usage-report?month=$month&type=detail"
    Write-Verbose $url
    $mResponse = InlineScript {Invoke-WebRequest $using:url -Headers $using:authHeaders -UseBasicParsing}
    Write-Verbose $mResponse.StatusCode

    Write-Verbose "Split the response up into an array from a string"
    $mContent = ($mResponse.Content -split '[\r\n]')
    
    Write-Verbose "Convert from CSV to object"
    $monthBill = $mContent | Where-Object -FilterScript { [regex]::matches($_,",").count -gt 28} | ConvertFrom-Csv
    
    Write-Verbose "Get the last day of data available"
    $filterDay =$monthBill[-1].Date #
    $aday = $monthBill | Where-Object -FilterScript {$_.date -eq $filterDay}
    
    Write-Verbose "Calculate day cost"
    $adayCost = [math]::round($($aday | Select-Object -ExpandProperty ExtendedCost | Measure-Object -Sum).sum,2)
    
    Write-Output "Day Cost for $filterDay : $adayCost"
    
    if([int]$adayCost -gt 0) {
        Write-Verbose "Sending email"
    
        $body = "<HTML><HEAD><META http-equiv=""Content-Type"" content=""text/html; charset=iso-8859-1"" /><TITLE></TITLE></HEAD>"
        $body += "<BODY bgcolor=""#FFFFFF"" style=""font-size: Small; font-family: TAHOMA; color: #000000""><P>"
        $body += "If every day were like today, your annual Azure bill would be...<br />"
        $body += "<b>" + ($adayCost*365) + "</b><br>"
        $body += "Based on usage for " + ([datetime]$filterDay).tostring("dd MMM yyyy") + " ($adayCost)"
        
        Send-MailMessage -SmtpServer $smtpServer -Port 587 -Credential $smtpServerCreds -BodyAsHtml -From $mailfrom -UseSsl -To $mailto -Subject 'Azure Billing Notification' -Body $body

        Write-Output "Sent email"
    }  
}
