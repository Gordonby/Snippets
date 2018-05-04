﻿#Grab the most recent favourites backup file

function GetEdgeFavouritesAsValidHtml()
{
    $userProfilePath = [Environment]::GetFolderPath('UserProfile')
    $ieBackupPath = "$userProfilePath\MicrosoftEdgeBackups\backups"

    #Get the backup file location
    $backupFolder = Get-ChildItem -Directory -Path $ieBackupPath | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $backupFilePath = Get-ChildItem -File -Path "$ieBackupPath\$backupFolder" | Select-Object -First 1

    #Grab the content of the file and cleanse to make xHtml compliant
    $htmlContent = $backupFilePath | Get-Content

    $anchorTags = ($htmlContent -match "<a.*?>(.*)?</a>")

    $cleanAnchors = @()
    $anchorTags | % {
        $anchorTag = $_.Replace("<DT>", "").Replace("&","&amp;")
        $anchorTagX = ([xml]$anchorTag).FirstChild
        $dataUri = $anchorTagX.Attributes["ICON"].'#text'
        $href = $anchorTagX.Attributes["HREF"].'#text'
        $modifiedLo =  $anchorTagX.Attributes["MODIFIED_LO"].'#text'
        $modifiedHi =  $anchorTagX.Attributes["MODIFIED_HI"].'#text'
        $isDeleted = $anchorTagX.Attributes["IS_DELETED"].'#text'

        $a = new-object -TypeName PSObject
        $a | Add-Member -MemberType NoteProperty -Name DataUri -Value $dataUri
        $a | Add-Member -MemberType NoteProperty -Name BookMarkName -Value $anchorTagX.InnerText
        $a | Add-Member -MemberType NoteProperty -Name Href -Value $href
        $a | Add-Member -MemberType NoteProperty -Name IsDeleted -Value $isDeleted
        $a | Add-Member -MemberType NoteProperty -Name ModifiedLo -Value $modifiedLo
        $a | Add-Member -MemberType NoteProperty -Name ModifiedHi -Value $modifiedHi
        
        $cleanAnchors += $a
    }
  
    #Sort the tags by modified attribute
    $sortedAnchors = $cleanAnchors | Where-Object IsDeleted -EQ 0 | Sort-Object ModifiedHi -Descending
    #$sortedAnchors | Select-Object BookMarkName, ModifiedLo, ModifiedHi | ft

    $anchorHtml = ""
    $sortedAnchors | % {
        $anchor = $_
        $dataUri = $anchor.DataUri
        $anchorText = $anchor.BookMarkName
        $href = $anchor.Href

        $anchorHtml += "<a href=`"$href`" target=`"_blank`">"
        $anchorHtml += "<img width=`"16`" height=`"16`" src=`"$dataUri`" />"
        $anchorHtml += "$anchorText</a>"
    }

    $baseHtml = Invoke-WebRequest "https://cdn.rawgit.com/Gordonby/Snippets/master/EdgeBookmarkPage/scaffold.html" -Headers @{"Cache-Control"="no-cache"}
    
    $xHtmlIeBookmarks = $baseHtml.Content.Replace("<div id=`"EdgeBookMarks`"></div>",$anchorHtml)

    return $xHtmlIeBookmarks
}

$EdgeFavourites = GetEdgeFavouritesAsValidHtml
$myDocsPath = [Environment]::GetFolderPath('MyDocuments')

$EdgeFavourites | Out-File "$myDocsPath\homepage.html"