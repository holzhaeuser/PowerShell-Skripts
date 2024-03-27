$GetInstalled = Get-Package | Select-Object Name
$GetWazuh = Get-ChildItem -Path "\\exa-dc\freigabe\programme\*"  -Name -Include wazuh*
$GetSuricata = Get-ChildItem -Path "\\exa-dc\freigabe\programme\*"  -Name -Include Suricata*
$GetIp = Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -eq 'Ethernet0'}
$GetIpAddress = $GetIp.IpAddress
if ($GetInstalled | Where-Object {$_.Name -eq 'Wazuh Agent'} ) {
	if (Test-Path "C:\Program Files\Suricata") {
		if (-not(Test-Path -Path 'C:\Users\Public\Documents\TEMP\')) {
			Exit
		}
	}
}
if ($GetInstalled | Where-Object {$_.Name -eq 'Wazuh Agent'} ) {	# Greift nur wenn Wazuh und Suricata installiert sind
	if (Test-Path "C:\Program Files\Suricata") {					# Test-Path, da Suricata im Silent Modus installiert wird
		$ParameterFuerCopyItemAgentConf = @{			# Vorgefertigte Konfigurationsdatei für 'Shared-Agents' im Wazuh-Agent
            	Path = '\\EXA-DC\Freigabe\Programme\agent.conf'
            	Destination = 'C:\Program Files (x86)\ossec-agent\shared\'
				Force = $True
        }
        Copy-Item @ParameterFuerCopyItemAgentConf
		$ParameterFuerCopyItemWazuhConf = @{			# Vorgefertigte Konfigurationsdatei für 'Shared-Agents' im Wazuh-Agent
            	Path = '\\EXA-DC\Freigabe\Programme\ossec.conf'
            	Destination = 'C:\Program Files (x86)\ossec-agent\'
				Force = $True
        }
        Copy-Item @ParameterFuerCopyItemWazuhConf
		$WriteConfig = Get-Content 'C:\Program Files (x86)\ossec-agent\ossec.conf' | Foreach-Object {$_.Replace("<agent_name></agent_name>","<agent_name>$GetIpAddress</agent_name>")} 
		$WriteConfig | Set-Content 'C:\Program Files (x86)\ossec-agent\ossec.conf' -Force	
        	Restart-Service -Name Wazuh -Force
		if (Test-Path -Path 'C:\Users\Public\Documents\TEMP\') {
			Remove-Item -Path 'C:\Users\Public\Documents\TEMP\' -ErrorAction SilentlyContinue -Force -Recurse
		}
		}
    }	

if (-not($GetInstalled | Where-Object {$_.Name -eq 'Wazuh Agent'})) {	# Sollte Wazuh nicht installiert sein greift dies

	$ParameterFuerNewItem = @{
		ItemType = 'Directory'
		Path = 'C:\Users\Public\Documents\TEMP'
		ErrorAction = 'SilentlyContinue'
	}
	New-Item @ParameterFuerNewItem
	$ParameterFuerCopyItem = @{
		Path = "\\EXA-DC\Freigabe\Programme\$GetWazuh"
		Destination = 'C:\Users\Public\Documents\TEMP\'
		Force = $True
	}
	Copy-Item @ParameterFuerCopyItem
	$ParameterFuerStartProcess = @{
		Wait = $True
		FilePath = "C:\Users\Public\Documents\TEMP\$GetWazuh"
		ArgumentList = "/q WAZUH_MANAGER=wazuh-manager WAZUH_AGENT_GROUP=WindowsServer,Suricata WAZUH_AGENT_NAME=$env:computername WAZUH_REGISTRATION_SERVER=wazuh-manager"
	}
	Start-Process @ParameterFuerStartProcess
	Start-Service -Name Wazuh

    if (-not(Test-Path "C:\Program Files\Suricata")) {	# Nach der Wazuh Installation wird geprueft ob Suricata installiert ist, Test-Path weil 'Siehe oben'
        $ParameterFuerCopyItem = @{
            Path = "\\EXA-DC\Freigabe\Programme\$GetSuricata"
            Destination = 'C:\Users\Public\Documents\TEMP'
        }
        Copy-Item @ParameterFuerCopyItem
		$ParameterFuerCopyItemAgentConf = @{			# Vorgefertigte Konfigurationsdatei für 'Shared-Agents' im Wazuh-Agent
            	Path = '\\EXA-DC\Freigabe\Programme\agent.conf'
            	Destination = 'C:\Program Files (x86)\ossec-agent\shared\'
				Force = $True
        }
        Copy-Item @ParameterFuerCopyItemAgentConf	
        Restart-Service -Name Wazuh -Force
        $ParameterFuerCopyItemWinPcap = @{
            	Path = '\\exa-dc\Freigabe\Skript\InstallWinPcap.bat'
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
			Path = '\\exa-dc\Freigabe\Programme\npcap-1.78'
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
        $ParameterFuerStartProcessInstall = @{
            Wait = $True
            FilePath = "C:\Users\Public\Documents\TEMP\$GetSuricata"
            ArgumentList = '/q'
        }   
        Start-Process @ParameterFuerStartProcessInstall
		
        }
    }

