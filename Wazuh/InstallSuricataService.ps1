$GetInstalled = Get-Package | Select-Object Name
$HoleNICs = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { ($_.DNSDomainSuffixSearchOrder -like "drheuer.net") -and ($_.DNSDomain -like "drheuer.net") }
$DevNPFID =  "\Device\NPF_$($HoleNICs.SettingID)"

if ($GetInstalled | Where-Object {$_.Name -match 'Suricata*'}) {
    Copy-Item -Path "\\dc01\Freigabe\Programme\Suricata\Rules Suricata\emerging.rules\rules\*" -Destination "C:\Program Files\Suricata\rules"  -Recurse -ErrorAction SilentlyContinue
    if (Test-Path "C:\Program Files\Npcap") {
        try {
            Start-Process 'C:\Program Files\Suricata\suricata.exe' -Wait -NoNewWindow -ArgumentList "-i $DevNPFID -vvv --service-install"
            Start-Service -Name Suricata
            Set-Service -Name Suricata -StartupType Automatic
        } catch {"Fehler: $_" >> C:\ErrorInstallSuricataService.log}
    }
    
}
   


