$GetInstalled = Get-Package | Select-Object Name
$GetSuricata = Get-ChildItem -Path "\\exa-dc\freigabe\programme\*"  -Name -Include Suricata*
$GetIp = Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -eq 'Ethernet0'}
$GetIpAddress = $GetIp.IpAddress
if ($GetInstalled | Where-Object {$_.Name -match 'Suricata*'} ) {
    if ($GetInstalled | Where-Object {$_.Name -match 'Wazuh*'} ) {
	if (Test-Path -Path 'C:\Users\Public\Documents\TEMP\') {
		Remove-Item -Path 'C:\Users\Public\Documents\TEMP\' -ErrorAction SilentlyContinue -Force Recurse
        
	}}
} else {


if ($GetInstalled | Where-Object {$_.Name -match'Wazuh*'}) {
    if (-not($GetInstalled | Where-Object {$_.Name -match 'Suricata*'} )) {
	    $ParameterFuerNewItem = @{
                    ItemType = 'Directory'
                    Path = 'C:\Users\Public\Documents\TEMP'
                    ErrorAction = 'SilentlyContinue'
                }
        New-Item @ParameterFuerNewItem
	    $ParameterFuerCopyItem = @{
                    Path = "\\EXA-DC\Freigabe\Programme\$GetSuricata"
                    Destination = 'C:\Users\Public\Documents\TEMP'
                }
        Copy-Item @ParameterFuerCopyItem
        Copy-Item -Path "\\EXA-DC\Freigabe\Programme\agent.conf" -Destination "C:\Program Files (x86)\ossec-agent\shared\" -Force
        Restart-Service -Name Wazuh -Force
        Copy-Item -Path "\\EXA-DC\Freigabe\Programme\npcap-0.96.exe" -Destination "C:\Users\Public\Documents\TEMP" -Force
        $ParameterFuerStartProcessFuerNcap = @{
            Wait = $True
            FilePath = 'C:\Users\Public\Documents\TEMP\npcap-0.96.exe'
            ArgumentList = "/S"
        }   
        Start-Process @ParameterFuerStartProcessFuerNcap
        $ParameterFuerStartProcessInstall = @{
                    Wait = $True
                    FilePath = "C:\Users\Public\Documents\TEMP\$GetSuricata"
                    ArgumentList = '/q'
        }   
        Start-Process @ParameterFuerStartProcessInstall
        $ParameterFuerStartProcessFuerServiceInstall = @{
            Wait = $True
            FilePath = 'C:\Program Files\Suricata\suricata.exe'
            ArgumentList = "-c suricata.yaml -i $GetIpAddress ./log -knone -vvv --service-install" #10.0.3.17
}   
        Start-Process @ParameterFuerStartProcessFuerServiceInstall
        Set-Service -Name Suricata -StartUpType Automatic
        Restart-Service -Name Suricata -Force
        
    } 
}
}

