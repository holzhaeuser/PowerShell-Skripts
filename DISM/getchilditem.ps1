$GetItem = Get-ChildItem -Name -Path D:\dism\updates\* -Include *.msu, *.cab 
    if (($GetItem)) {
        Write-Host "Updates gefunden:" ($GetItem).Count
        
    }
    else {
        Write-host "Keine Updates gefunden"
    }
