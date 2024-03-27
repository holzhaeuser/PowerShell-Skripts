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
#$GetNic = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { ($_.DNSDomainSuffixSearchOrder -like "drheuer.net") -and ($_.DNSDomain -like "drheuer.net") }
GetNeuerWert 172.22.0.170

