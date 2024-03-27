
$RName = 'TN-CA01$'
certutil -view -restrict "Disposition=20, RequesterName=DC02\$Rname"  | ForEach-Object {
    if ($_ -match "Seriennummer:\s+""(.+)""") {
        $serialNumber = $matches[1]
        certutil -revoke $serialNumber 0
    }
    
}
