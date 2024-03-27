if (Get-Package -Name Suricata*) {
    $MesseEve = (Get-Childitem 'C:\Program Files\Suricata\log\eve.json' | Measure-Object -Property Length -sum).sum /1MB
    if ($MesseEve -gt '1') {
        # Loesche Eve.Json ab 1MB
       	Stop-Service Suricata
        Remove-Item -Path 'C:\Program Files\Suricata\log\eve.json' -Force 
        Start-Service Suricata
    } else {}
    $MesseStats = (Get-Childitem 'C:\Program Files\Suricata\log\stats.log' | Measure-Object -Property Length -sum).sum /1MB
    if ($MesseStats -gt '1') {
        # Loesche stats.log ab 1MB
       	Stop-Service Suricata
        Remove-Item -Path 'C:\Program Files\Suricata\log\stats.log' -Force 
        Start-Service Suricata
    } else {}
    $MesseFast = (Get-Childitem 'C:\Program Files\Suricata\log\fast.log' | Measure-Object -Property Length -sum).sum /1MB
    if ($MesseFast -gt '1') {
        # Loesche fast.log ab 1MB
       	Stop-Service Suricata
        Remove-Item -Path 'C:\Program Files\Suricata\log\fast.log' -Force 
        Start-Service Suricata
    } else {}
    $MesseSuricata = (Get-Childitem 'C:\Program Files\Suricata\log\suricata.log' | Measure-Object -Property Length -sum).sum /1MB
    if ($MesseSuricata -gt '1') {
        # Loesche fast.log ab 1MB
       	Stop-Service Suricata
        Remove-Item -Path 'C:\Program Files\Suricata\log\suricata.log' -Force 
        Start-Service Suricata
    } else {}
} 