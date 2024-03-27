try {

	if (-not(Test-Path "C:\Program Files\Npcap")) {
			$ParameterFuerCopyItemNpcap = @{
				Path = '\\dc01\Freigabe\Programme\Suricata\npcap-1.79'
				Destination = 'C:\Users\Public\Documents\TEMP\npcap-1.79'
				Force = $True
				Recurse = $True
			}
			Copy-Item @ParameterFuerCopyItemNpcap
			$ParameterFuerInstallNpcap = @{
				Wait = $True
				FilePath = "C:\Users\Public\Documents\TEMP\npcap-1.79\npcap-1.79.msi"
			}
			Start-Process @ParameterFuerInstallNpcap
			Remove-Item -Path "C:\Users\Public\Documents\TEMP" -Force
	}     
} catch {"Fehler: $_" >> C:\ErrorLog_InstallNpcap.Log}
finally {exit}