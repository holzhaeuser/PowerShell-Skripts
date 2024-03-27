$azureArcFeature = Get-WindowsFeature -Name AzureArcSetup

if ($azureArcFeature -ne $null -and $azureArcFeature.Installed -and $azureArcFeature.InstallState -eq 'Installed') {
    Remove-WindowsFeature -Name AzureArcSetup -Confirm:$false
} elseif ($azureArcFeature.InstallState -eq 'Available') {
} else {
}
