$azureArcFeature = Get-WindowsFeature -Name AzureArcSetup

if ($azureArcFeature -ne $null -and $azureArcFeature.Installed -and $azureArcFeature.InstallState -eq 'Installed') {
    # Wenn das Feature gefunden und aktiviert ist, entferne es
    Remove-WindowsFeature -Name AzureArcSetup -Confirm:$false
} elseif ($azureArcFeature.InstallState -eq 'Available') {
    # Wenn das Feature gefunden, aber nicht aktiviert ist, ist es bereits im gewUenschten Zustand
} else {
    # Wenn das Feature nicht gefunden wurde, unternehme keine Aktion
}
