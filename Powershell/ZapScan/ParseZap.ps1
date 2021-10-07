          Write-Output "Check for Zap Json file"
          Test-Path report_json.json
          
          $zap = get-content report_json.json | ConvertFrom-Json
          Write-Output $zap

          $highAlerts = $zap.site.alerts | Where-Object {$_.riskcode -eq 3}
          $mediumAlerts = $zap.site.alerts | Where-Object {$_.riskcode -eq 2}

          #Define to suit your business.
          #I'm going high, so my CI tests pass, but usually you'd set this to 0
          $HighThreshold = 5
          $MediumThreshold = 10

          #raise error if high alerts are over threshold
          if ($highAlerts.count -gt $HighThreshold) {
              Write-Output "High Alerts Found"
              $highAlerts | Where-Object { Write-Output $_.alert }
              throw "High Alerts Found"
          }

          #raise error if medium alerts are over threshold
          if ($mediumAlerts.count -gt $MediumThreshold) {
            Write-Output "Medium Alerts Found"
            $highAlerts | Where-Object { Write-Output $_.alert }
            throw "Medium Alerts Found"
        }