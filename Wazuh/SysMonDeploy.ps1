try {
    if (-not(Get-Service "Sysmon64")) {
        Start-Process -FilePath "\\dc01\Freigabe\Programme\Sysmon\Sysmon64.exe" -ArgumentList "-accepteula -i \\dc01\Freigabe\Programme\Sysmon\dns.xml" -NoNewWindow
    }
    } catch {"Fehler: $_" > 'C:\Fehler.log' }