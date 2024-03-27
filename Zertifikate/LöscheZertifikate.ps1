$certificates = @()
$certificateObj = $null


'Laufzeit = {0}sek' -f (Measure-Command -Expression { 
foreach ($line in (certutil -view -restrict "Disposition=20")) {
	
    if ($line -match "Seriennummer:\s+""(.+)""") {
		$CNT = $CNT +1
        $serialNumber = $matches[1]
		
    }
	elseif ($line -match "Ausgestellt: Anforderungs-ID:\s+0x([0-9a-fA-F]+)\s*\((\d+)\)") {
        $requestidHex = $matches[1]
        $requestidDec = $matches[2]
    }
    elseif ($line -match "Anfangsdatum des Zertifikats:\s+(.+)") {
        if ($certificateObj) {
            $certificates += $certificateObj
        }
        $startDate = Get-Date $matches[1]
        $certificateObj = [PSCustomObject]@{
			IDDez = $requestidDec
			IDHex = "0x$requestidHex"
            Seriennummer = $serialNumber
            Anfangsdatum_des_Zertifikats = $startDate
            Antragstellername = $requester
        }
    }
    elseif ($line -match "Antragstellername:\s+""(.+)""") {
        $requester = $matches[1]
    }
} 


if ($certificateObj) {
    $certificates += $certificateObj
}

# Zum Testen:
#$certificates = $certificates | Sort-Object -Property Anfangsdatum_des_Zertifikats -Descending
#$certificates


$deleteBeforeDate = (Get-Date).AddHours(-0)
$certificatesToDelete = $certificates | Where-Object { $_.Anfangsdatum_des_Zertifikats -lt $deleteBeforeDate }
$certificatesToDelete2 = $certificatesToDelete | Where-Object { $_.Antragstellername -match "^*TN-" }
#$certificatesToDelete2
foreach ($cert in $certificatesToDelete2) {
   certutil -deleteRow $cert.IDDez
}
}).TotalSeconds
