function GetNeuerWert {
    param (
        [string]$IPAdd
    )
    if ($IPAdd -match "172\.21\.*") {
        return 'ITA-1'
    }
    if ($IPAdd -match "172\.22\.*") {
        return 'ITA-2'
    }
    if ($IPAdd -match "172\.23\.*") {
        return 'ITA-3'
    }  
    if ($IPAdd -match "172\.24\.*") {
        return 'ITA-4'
    }  
    if ($IPAdd -match "172\.25\.*") {
        return 'ITA-5'
    }  
    if ($IPAdd -match "172\.26\.*") {
        return 'ITA-6'
    }  
    if ($IPAdd -match "172\.27\.*") {
        return 'ITA-7'
    }  
    if ($IPAdd -match "172.28\.*") {
        return 'ITA-8'
    }
 
}
$GetNic = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { ($_.DNSDomainSuffixSearchOrder -like "drheuer.net") -and ($_.DNSDomain -like "drheuer.net") }
$File = 'C:\Program Files (x86)\ossec-agent\ossec.conf'
# Aendere Gruppennamen bei einem Mismatch:
if (-not((get-content 'C:\Program Files (x86)\ossec-agent\ossec.conf' | select-string "<groups>ITA-.+</groups>") -match "$(GetNeuerWert -IPAdd $GetNic.IPAddress)")) {
    Stop-Service -Name Wazuh
    New-Item 'C:\Program Files (x86)\ossec-agent\client.keys' -ItemType File -Force
    $NeuerWert = GetNeuerWert -IPAdd $GetNic.IPAddress
    $Load = Get-Content $File | select-string "<groups>ITA-.+</groups>"
    $old = $Load
    $new = "      <groups>$NeuerWert</groups>"
    (Get-Content -Path $File -Raw ) -replace [regex]::Escape($old),$new | Set-Content $File
    Start-Service -Name Wazuh
}
# Sollte der Gruppen Parameter fehlerhaft sein, greift dies
if ((get-content 'C:\Program Files (x86)\ossec-agent\ossec.conf' | select-string "<groups></groups>")) {
    Stop-Service -Name Wazuh
    New-Item 'C:\Program Files (x86)\ossec-agent\client.keys' -ItemType File -Force
    $NeuerWert = GetNeuerWert -IPAdd $GetNic.IPAddress
    $Load = Get-Content $File | select-string "<groups></groups>"
    $old = $Load
    $new = "      <groups>$NeuerWert</groups>"
    (Get-Content -Path $File -Raw ) -replace [regex]::Escape($old),$new | Set-Content $File
    Start-Service -Name Wazuh
}