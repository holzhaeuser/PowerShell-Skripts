$GetInstalled = Get-Package | Select-Object Name
$GetWazuh = Get-ChildItem -Path "\\dc01\freigabe\programme\*"  -Name -Include wazuh*
if ($GetInstalled | Where-Object {$_.Name -eq 'Wazuh Agent'} ) {
		if (Test-Path -Path 'C:\Users\Public\Documents\TEMP\') {
			Remove-Item -Path 'C:\Users\Public\Documents\TEMP\' -ErrorAction SilentlyContinue -Force
	}
} else {

	$ParameterFuerNewItem = @{
		ItemType = 'Directory'
		Path = 'C:\Users\Public\Documents\TEMP'
		ErrorAction = 'SilentlyContinue'
	}
	New-Item @ParameterFuerNewItem
	$ParameterFuerCopyItem = @{
		Path = "\\dc01\Freigabe\Programme\$GetWazuh"
		Destination = 'C:\Users\Public\Documents\TEMP\'
		Force = $True
	}
	Copy-Item @ParameterFuerCopyItem
	$ParameterFuerStartProcess = @{
		Wait = $True
		FilePath = "C:\Users\Public\Documents\TEMP\$GetWazuh"
		ArgumentList = "/q WAZUH_MANAGER=wazuh-manager WAZUH_AGENT_GROUP=Windows WAZUH_AGENT_NAME=$env:computername WAZUH_REGISTRATION_SERVER=wazuh-manager"
	}
	Start-Process @ParameterFuerStartProcess
	Start-Service -Name Wazuh

}
