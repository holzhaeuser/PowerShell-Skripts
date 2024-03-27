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