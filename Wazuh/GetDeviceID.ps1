$HoleNICs = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { ($_.DNSDomainSuffixSearchOrder -like "drheuer.net") -and ($_.DNSDomain -like "drheuer.net") }
$DevNPFID =  "\Device\NPF_$($HoleNICs.SettingID)"
$GetSCDetails = Get-WmiObject -class win32_service | Where-Object { ($_.Name -like "Suricata")}
if ($GetSCDetails.PathName -like "*$DevNPFID*") {
	Write-Host "True"
} elseif (-not($GetSCDetails.PathName -like "*$DevNPFID*")) {
	Write-Host "False"
    Start-Process 'C:\Program Files\Suricata\suricata.exe' -ArgumentList "-i $DevNPFID -vvv --service-change-params"
    Start-Service -Name Suricata
} 
#C:\Program Files\Suricata\suricata.exe -i \Device\NPF_{E61B62FD-4F4D-412A-893F-85A0041FD79B} -vvv
