$GetInstalled = Get-Package | Select-Object Name
$GetIp = Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -eq 'Ethernet'}
$GetIpAddress = $GetIp.IpAddress
$GetStartUp = Get-Service | Select-Object -property name,starttype
try {
if ($GetInstalled | Where-Object {$_.Name -eq 'Wazuh Agent'} ) {	
	if ($GetInstalled | Where-Object {$_.Name -eq 'Suricata IDS/IPS 7.0.2-1-64bit'} ) {
		if (-not(get-content 'C:\Program Files (x86)\ossec-agent\shared\agent.conf' | select-string "<location>C:/Program Files/Suricata/log/eve.json</location>")) {				
			$FileName = "C:\Program Files (x86)\ossec-agent\shared\agent.conf"
			$Patern = "<!-- Shared agent configuration here -->" # the 2 lines will be added just after this pattern 
			$FileOriginal = Get-Content $FileName
			<# create empty Array and use it as a modified file... #>
			
			$FileModified = @() 
			
			Foreach ($Line in $FileOriginal) {    
				$FileModified += $Line
				if ($Line -match $patern) {
					#Add Lines after the selected pattern 
					$FileModified += ''
					$FileModified += '  <localfile>'
					$FileModified += '   <log_format>json</log_format>'
					$FileModified += '   <location>C:/Program Files/Suricata/log/eve.json</location>'
					$FileModified += '  </localfile>'
					$FileModified += ''
				} 
			}
			Set-Content $fileName $FileModified
			Restart-Service -Name Wazuh
		}
		if (-not(Get-Content 'C:\Program Files (x86)\ossec-agent\ossec.conf' | select-string "<location>C:/Program Files/Suricata/log/eve.json</location>")) {
			$FileName = "C:\Program Files (x86)\ossec-agent\ossec.conf"
			$Patern = "<!-- Log analysis -->" # the 2 lines will be added just after this pattern 
			$FileOriginal = Get-Content $FileName

			<# create empty Array and use it as a modified file... #>

			$FileModified = @() 

			Foreach ($Line in $FileOriginal) {    
				$FileModified += $Line
				if ($Line -match $patern) {
					#<localfile>
					 #<log_format>json</log_format>
					 #<location>C:/Program Files/Suricata/log/eve.json</location>
					#</localfile>
					#Add Lines after the selected pattern 
					$FileModified += ''
					$FileModified += '  <localfile>'
					$FileModified += '   <log_format>json</log_format>'
					$FileModified += '   <location>C:/Program Files/Suricata/log/eve.json</location>'
					$FileModified += '  </localfile>'
					$FileModified += ''
				} 
			}
			Set-Content $fileName $FileModified
			Restart-Service -Name Wazuh
		}
	}
}
} catch {
	"Fehler: $_" >> ErrorLogAgentConf.log
} 
try {
	if ($GetInstalled | Where-Object {$_.Name -eq 'Suricata IDS/IPS 7.0.2-1-64bit'}) {
		if (-not(Test-Path "C:\Program Files\Npcap")) {	
			if (-not(Test-Path "C:\Program Files (x86)\WinPcap")) {
				$ParameterFuerNewItem = @{
					ItemType = 'Directory'
					Path = 'C:\Users\Public\Documents\TEMP'
					ErrorAction = 'SilentlyContinue'
				}
				New-Item @ParameterFuerNewItem	
				$ParameterFuerCopyItemWinPcap = @{
						Path = '\\dc01\Freigabe\Programme\Suricata\InstallWinPcap.bat'
						Destination = 'C:\Users\Public\Documents\TEMP'
						Force = $True
				}
				Copy-Item @ParameterFuerCopyItemWinPcap
				$ParameterFuerInstallWinScap = @{
					Wait = $True
					FilePath = "C:\Users\Public\Documents\TEMP\InstallWinPcap.bat"
				}
				Start-Process @ParameterFuerInstallWinScap
				$ParameterFuerCopyItemNpcap = @{
					Path = '\\dc01\Freigabe\Programme\Suricata\npcap-1.78'
					Destination = 'C:\Users\Public\Documents\TEMP'
					Force = $True
					Recurse = $True
				}
				Copy-Item @ParameterFuerCopyItemNpcap
				$ParameterFuerInstallNpcap = @{
					Wait = $True
					FilePath = "C:\Users\Public\Documents\TEMP\npcap-1.78\npcap-1.78.msi"
				}
				Start-Process @ParameterFuerInstallNpcap
			}
		}		
	}

} 
catch {
		"Fehler: $_" >> C:\ErrorLogInstall.Log
	}
	try {
			if (Test-Path "C:\Program Files\Npcap") {
				if (Test-Path "C:\Program Files (x86)\WinPcap") {
					if (-not($GetStartUp.Name -eq "Suricata")) {
						Start-Process 'C:\Program Files\Suricata\suricata.exe' -NoNewWindow -Wait -ArgumentList "-c suricata.yaml -i $GetIpAddress -knone -vvv --service-install"
						Copy-Item -Path '\\dc01\Freigabe\Programme\Suricata\Rules Suricata\emerging.rules\rules\' -Destination 'C:\Program Files\Suricata\rules\' -Recurse -ErrorAction SilentlyContinue
					}
					if ($GetStartUp.Name -eq "Suricata" -and  $GetStartUp.StartType -eq "Manual") {
						Set-Service -Name 'Suricata' -StartupType Automatic
						Start-Service -Name 'Suricata'
					} 
				}
			}
		}
		catch {"Fehler: $_" >> 'C:\Error_InstallService.log'}



