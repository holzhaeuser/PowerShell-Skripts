$certificates = [System.Collections.Generic.List[object]]::new()
$certificateObj = $null
$CNT = 0

#'Laufzeit = {0}ms' -f (Measure-Command -Expression { 
    foreach ($line in (certutil -view -restrict "Disposition=20")) {
	
        if ($line -match "Seriennummer:\s+""(.+)""") {
            $CNT = $CNT +1
            $serialNumber = $matches[1]
            
        }
        elseif ($line -match "Ausgestellt: Anforderungs-ID:\s+0x([0-9a-fA-F]+)\s*\((\d+)\)") {
            $requestidHex = $matches[1]
            $requestidDec = $matches[2]
        }
        elseif ($line -match 'Zertifikatvorlage: \"(.+)\" (.+)') {
            $TempID = $matches[1]
            $TempName = $matches[2]
        }
        elseif ($line -match "Anfangsdatum des Zertifikats:\s+(.+)") {
            if ($certificateObj) {
                $certificates.Add($certificateObj)
            }
            $startDate = Get-Date $matches[1]
            $certificateObj = [PSCustomObject]@{
				Nummer = $CNT
                ID_Dez = $requestidDec
                ID_Hex = "0x$requestidHex"
                Vorlagenname = $TempName
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
            $certificates.Add($certificateObj)
        }

        # Zum Testen:
        #$certificates = $certificates | Sort-Object -Property Anfangsdatum_des_Zertifikats -Descending
        #$certificates

        $deleteBeforeDate = (Get-Date).Addminutes(-30)
        #$certificatesToDelete = $certificates | Where-Object { $_.Anfangsdatum_des_Zertifikats -lt $deleteBeforeDate }
        $certificatesToDelete2 = $certificates | Where-Object { $_.Antragstellername -match "^*TN-" }
        $certificatesToDelete2
        foreach ($cert in $certificatesToDelete2) {
        		if (($cert.Vorlagenname -eq $cert.Vorlagenname) -and ($cert.Anfangsdatum_des_Zertifikats -lt $deleteBeforeDate )) {
					$CNT = $CNT-1
                    Write-Host "$CNT ist gleich"
					certutil -deleteRow $cert.ID_Dez
                }
                #
        	}
#}).TotalMilliseconds
