
$File = 'C:\Users\mh\Desktop\ossec.conf'
$HostName = $ENV:COMPUTERNAME
#Write-Host $HostName
$ListeITA98 = 'PC0510'
#ForEach ($content in $ListeITA98) {
    if ($HostName -in $ListeITA98) {
        $NeuerWert = 'ITA-01'
        $Load = Get-Content 'C:\Users\mh\Desktop\ossec.conf' | select-string -Raw "<groups>"
        $old = $Load
        $new = "      <groups>$NeuerWert</groups>"
        (Get-Content -path $File -Raw) -replace [regex]::Escape($old),$new | Set-Content $File
    } else {Write-Warning "$HostName nicht in Liste."}
#}
