try {
	if (Test-Path 'C:\Program Files (x86)\ossec-agent\') {    
			# Konfigurationsdatei des Agenten Ueberwachen
			if (-not(get-content 'C:\Program Files (x86)\ossec-agent\ossec.conf' | select-string 'restrict="ossec.conf"')) {
				$FileName = "C:\Program Files (x86)\ossec-agent\ossec.conf"
				$Patern = '<!-- Default files to be monitored. -->' 
				$FileOriginal = Get-Content $FileName
				$FileModified = @()
				Foreach ($Line in $FileOriginal) {    
					$FileModified += $Line
					if ($Line -match $patern) {
						$FileModified += '    <directories check_all="yes" report_changes="yes" realtime="yes" restrict="ossec.conf">C:\Program Files (x86)\ossec-agent</directories>'
						$FileModified += '    <directories check_all="yes" report_changes="yes" realtime="yes" restrict="agent.conf">C:\Program Files (x86)\ossec-agent\shared</directories>'

					}
				}
				Set-Content $fileName $FileModified
				Restart-Service -Name Wazuh
			}
			# Einbindung von Windows-Defender Ereignisse
			if (-not(get-content 'C:\Program Files (x86)\ossec-agent\ossec.conf' | select-string "<location>Microsoft-Windows-Windows Defender/Operational</location>")) {
				$FileName = "C:\Program Files (x86)\ossec-agent\ossec.conf"
				$Patern = "<!-- Log analysis -->" 
				$FileOriginal = Get-Content $FileName
				$FileModified = @()
				Foreach ($Line in $FileOriginal) {    
					$FileModified += $Line
					if ($Line -match $patern) {
						$FileModified += ''
						$FileModified += '  <localfile>'
						$FileModified += '   <location>Microsoft-Windows-Windows Defender/Operational</location>'
						$FileModified += '   <log_format>eventchannel</log_format>'
						$FileModified += '  </localfile>'
						$FileModified += ''
					}
				}
				Set-Content $fileName $FileModified
				Restart-Service -Name Wazuh
			}
			if (-not(get-content 'C:\Program Files (x86)\ossec-agent\ossec.conf' | select-string "<location>Microsoft-Windows-Sysmon/Operational</location>")) {
				$FileName = "C:\Program Files (x86)\ossec-agent\ossec.conf"
				$Patern = "<!-- Log analysis -->" 
				$FileOriginal = Get-Content $FileName
				$FileModified = @()
				Foreach ($Line in $FileOriginal) {    
					$FileModified += $Line
					if ($Line -match $patern) {
						$FileModified += ''
						$FileModified += '  <localfile>'
						$FileModified += '   <location>Microsoft-Windows-Sysmon/Operational</location>'
						$FileModified += '   <log_format>eventchannel</log_format>'
						$FileModified += '  </localfile>'
						$FileModified += ''
					}
				}
				Set-Content $fileName $FileModified
				Restart-Service -Name Wazuh
			}
			# Einbindung von Windows-Firewall Ereignisse
			if (-not(get-content 'C:\Program Files (x86)\ossec-agent\ossec.conf' | select-string "<location>Microsoft-Windows-Windows Firewall With Advanced Security/Firewall</location>")) {
				$FileName = "C:\Program Files (x86)\ossec-agent\ossec.conf"
				$Patern = "<!-- Log analysis -->" 
				$FileOriginal = Get-Content $FileName
				$FileModified = @()
				Foreach ($Line in $FileOriginal) {    
					$FileModified += $Line
					if ($Line -match $patern) {
						$FileModified += ''
						$FileModified += '  <localfile>'
						$FileModified += '   <location>Microsoft-Windows-Windows Firewall With Advanced Security/Firewall</location>'
						$FileModified += '   <log_format>eventchannel</log_format>'
						$FileModified += '   <query>Event/System[EventID \>= 2003 and EventID \<= 2006]</query>'
						$FileModified += '  </localfile>'
						$FileModified += ''
					}
				}
				Set-Content $fileName $FileModified
				Restart-Service -Name Wazuh
			}
	}
} catch {"Fehler: $_" >> C:\ErrorLogAgentConf.log}
