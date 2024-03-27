$azureArcFeature = Get-WindowsFeature -Name AzureArcSetup
if ($azureArcFeature -ne $null) {
    Write-Host "AzureArc-Funktion gefunden."
} else {
    Write-Host "AzureArc-Funktion nicht aktiviert."
}