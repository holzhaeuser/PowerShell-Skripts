#$DateBefore = New-Object -TypeName 'System.Collections.ArrayList'
#$DateBefore.Add("13:31:17")
#$DateBefore.Add("13:33:42")
#$GetCerts = Get-ChildItem cert:LocalMachine\My
#$GetCerts2 = $GetCerts.NotBefore | Where-Object {$_ -CMatch $DateBefore}
#$GetCerts3 = $GetCerts | Where-Object {$_.NotBefore -CMatch $DateBefore} | Select-Object Thumbprint
#Write-Host "$GetCerts2, TP: $GetCerts3"
#foreach ($datum in $datebefore) {
#    Get-ChildItem cert:LocalMachine\My | Where-Object {$_.NotBefore -CMatch $datum} | Remove-Item
#} 
#certutil -view -restrict "Disposition=20, RequesterName=DC02\$Rname, NotBefore<=07.03.2024 13:31" -out "Serialnumber" | findstr Seriennummer


$RName = 'TN-CA01$'
certutil -view -restrict "Disposition=20, RequesterName=DC02\$Rname"  | ForEach-Object {
    if ($_ -match "Seriennummer:\s+""(.+)""") {
        $serialNumber = $matches[1]
    }
    elseif($_  -match "Anfangsdatum des Zertifikats:\s+(.+)"){
        $notbefore = $matches[1]
    }
        Write-Host "$serialNumber $notbefore"
        #Write-Output $serialNumber | Out-File -Append serial_numbers.txt
    
    
} # Import & Export CSV

foreach ($sn in (get-content -Path .\serial_numbers.txt)) {
certutil -revoke $sn 0}