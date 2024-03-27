# Funktion Pruefe Adminrechte
function ProofAdmin{
    param (
        [string]$SkriptErrorLog='C:\dism\log\skripterror',
        [string]$DatumSkriptError=(Get-Date -UFormat "%d-%m-%Y-%R" | ForEach-Object { $_ -replace ":", "-" }),
        [string]$ScriptName=$MyInvocation.MyCommand.Name
    )
            if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
                Write-Warning "$ScriptName benoetigt Administratorrechte.`n$ScriptName wird mit Administratorrechte neugestartet."
                    $StartProcess = @{
                    FilePath = 'powershell.exe'
                    Verb = 'RunAs'
                    ArgumentList = "-File $PSScriptRoot\$ScriptName"
                }
                $DatumSkriptError = Get-Date -UFormat "%d-%m-%Y-%R" | ForEach-Object { $_ -replace ":", "-" }
                "$ScriptName wurde nicht als Administrator ausgefuehrt." > "$SkriptErrorLog\$DatumSkriptError.runas.log"
                Pause
                Start-Process @StartProcess
                Break 
                
            }
            else {Write-Host 'Als Admin ausgefuehrt!'}
}
ProofAdmin
# Funktion FindeIso
function FindIso{
    param (
        [string]$IsoPath = 'C:\dism\iso\',
        [string]$MntName = 'mnt',
        [string]$MntDirectoryLetter = 'C:\dism\',
        [string]$WindowsUpdateDirectroy = 'C:\dism\updates',
        [string]$SkriptErrorLog = 'C:\dism\log\skripterror',
        [string]$ScriptName = $MyInvocation.MyCommand.Name
    )
    
    Write-Host "Festgelegte Pfade:`nISO-Verzeichnis - $IsoPath`nUpdate-Verzeichnis - $WindowsUpdateDirectroy`nMount Pfad - $MntDirectoryLetter$MntName`n"
    Write-Host "$ScriptName gestartet."
    $NewFile = Get-ChildItem -Path $IsoPath -Include *.iso -Name
    if ((get-childitem $IsoPath).count -eq 0) {
        Write-Host "Es wurde keine .ISO Datei in $IsoPath gefunden."
        Write-Warning "Zum neustarten bitte 'N' oder nur 'Enter' eingeben."
                    $ChoiceAbbruch = Read-host "Skript abbrechen (Standard: Nein)? (J/N)"
                    if ([string]::IsNullOrWhiteSpace($ChoiceAbbruch)) {
                        $ChoiceAbbruch = 'n'
                    }
                    if (($ChoiceAbbruch.ToLower())-eq 'j') {
                        Break
                    }

    }
    if (-not(get-childitem $IsoPath).count -eq 0) {
        
        $AllFiles = Get-ChildItem -Path $IsoPath -Name 
        $FileExtension = [System.IO.Path]::GetExtension($AllFiles).ToLower()
        if (-not ($FileExtension -eq ".iso")) {
            #Clear-Host
            Write-Warning "$AllFiles ist keine ISO-Datei."
            $DatumSkriptError = Get-Date -UFormat "%d-%m-%Y-%R" | ForEach-Object { $_ -replace ":", "-" }
            "$AllFiles ist keine ISO-Datei." >> "$SkriptErrorLog\$DatumSkriptError.wrongfile.log"
            Break
        }
            #Clear-Host
            Write-Host "Neue ISO-Datei erkannt: $NewFile.`nVorgang wird gestartet."
            if (-not (Test-Path "$MntDirectoryLetter$MntName")) {
                $ParameterFuerNewItem = @{
                    Path = "$MntDirectoryLetter"
                    ItemType = 'Directory'
                    Name = "$MntName"
                }
                New-Item @ParameterFuerNewItem
                Write-Host "$MntDirectoryLetter$MntName wurde erstellt."
            }
    }
}
#FindIso($IsoPath=Read-Host 'ISO-Verzeichnis:')
FindIso($ScriptName='Test.ps1')