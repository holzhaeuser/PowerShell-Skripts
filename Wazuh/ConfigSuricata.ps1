$GetInstalled = Get-Package | Select-Object Name
$GetIp = Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -eq 'Ethernet0'}
$GetIpAddress = $GetIp.IpAddress
if ($GetInstalled.Name -eq "Suricata IDS/IPS 7.0.2-1-64bit") {
    	Copy-Item -Path "\\EXA-DC\Freigabe\Programme\agent.conf" -Destination "C:\Program Files (x86)\ossec-agent\shared\" -Force
        Restart-Service -Name Wazuh -Force
    	Start-Process 'C:\Program Files\Suricata\suricata.exe' -ArgumentList "-c suricata.yaml -i $GetIpAddress ./log -knone -vvv --service-install"

} 
if (Get-Service -eq "Suricata") {
	Set-Service -Name Suricata -StartUpType Automatic
    Restart-Service -Name Suricata -Force
    Remove-Item "C:\Users\Public\Desktop\Suricata 7.0.2-64bit IDS-IPS.lnk" -ErrorAction SilentlyContinue
	Remove-Item "C:\Users\$env:USERNAME\Desktop\Suricata 7.0.2-64bit IDS-IPS.lnk" -ErrorAction SilentlyContinue
}