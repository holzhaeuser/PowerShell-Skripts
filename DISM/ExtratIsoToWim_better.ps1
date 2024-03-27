param (
    [string]$IsoPath = 'C:\dism\iso\',
    [string]$MntName = 'mnt',
    [string]$MntDirectoryLetter = 'C:\dism\',
    [string]$DestinationImagePath = 'C:\dism\result\',
    [string]$DestinationImageName = 'install.wim',
    [string]$WindowsUpdateDirectroy = 'C:\dism\updates',
    [string]$AddPckLogPath = 'C:\dism\log\addpck',
    [string]$RepairWinLogPath = 'C:\dism\log\repairwin',
    [string]$MountImageLogPath = 'C:\dism\log\mountimage',
    [string]$DisMountImageLogPath = 'C:\dism\log\dismountimage',
    [string]$SkriptErrorLog = 'C:\dism\log\skripterror',
    [string]$TranscriptPath = 'C:\dism\log\transcript'
)
$ScriptName = $MyInvocation.MyCommand.Name

while ($true) {
            $TranscriptDatum = Get-Date -UFormat "%d-%m-%Y-%R" | ForEach-Object { $_ -replace ":", "-" }
            $ParameterFuerStartTranscript = @{
                Path = "$TranscriptPath\transcript$($TranscriptDatum).txt"
                NoClobber = $False
            }
            Start-Transcript @ParameterFuerStartTranscript
    try {
            if (-not(Test-Path $TranscriptPath)) {
                New-Item -Path $TranscriptPath -ItemType Directory
            }
            
            #Start-Transcript @ParameterFuerStartTranscript
            $Backup = $ErrorActionPreference
            $ErrorActionPreference = 'Stop'
            $ZeitStartSkript = Get-Date -UFormat "%R Uhr" # Start Zeit
            
            
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
                
            } else { 
                Write-Host "Festgelegte Pfade:`nISO-Verzeichnis - $IsoPath`nUpdate-Verzeichnis - $WindowsUpdateDirectroy`nMount Pfad - $MntDirectoryLetter$MntName`nZiel-Verzeichnis - $DestinationImagePath`n"
                Write-Host "$ScriptName gestartet."
                $NewFile = Get-ChildItem -Path $IsoPath -Include *.iso -Name
                if ((get-childitem $IsoPath).count -eq 0) {
                    Write-Host "Es wurde keine .ISO Datei in $IsoPath gefunden."
                    Write-Warning "Zum neustarten bitte 'J' oder nur 'Enter' eingeben."
                                $ChoiceAbbruch = Read-host "Skript neustarten (Standard: Ja)? (J/N)"
                                if ([string]::IsNullOrWhiteSpace($ChoiceAbbruch)) {
                                    $ChoiceIso = 'j'
                                }
                                if (($ChoiceAbbruch.ToLower())-eq 'n') {
                                    Break
                                }

                }
                if (-not(get-childitem $IsoPath).count -eq 0) {
                    $AllFiles = Get-ChildItem -Path $IsoPath -Name 
                    $FileExtension = [System.IO.Path]::GetExtension($AllFiles).ToLower()
                    if (-not ($FileExtension -eq ".iso")) {
                        Clear-Host
                        Write-Warning "$AllFiles ist keine ISO-Datei."
                        $DatumSkriptError = Get-Date -UFormat "%d-%m-%Y-%R" | ForEach-Object { $_ -replace ":", "-" }
                        "$AllFiles ist keine ISO-Datei." >> "$SkriptErrorLog\$DatumSkriptError.wrongfile.log"
                        Break
                    }
                        Clear-Host
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

                        # Mounten der ISO-Datei
                        $ParameterFuerMountDiskImage = @{
                            ImagePath = "$IsoPath$NewFile"
                            PassThru = $True
                        }
                        $mountedDisk = Mount-DiskImage @ParameterFuerMountDiskImage
                        $driveLetter = ($mountedDisk | Get-Volume).DriveLetter
                        Write-Host "$IsoPath$NewFile wurde gemountet."
                        # Pfad zum Verzeichnis "source" innerhalb des gemounteten Laufwerks
                        $sourcePath = "${driveLetter}:\sources"

                        # Extrahieren der "install.wim" Datei
                        $installWimPath = Join-Path $sourcePath "install.wim"

                        # Extrahieren der "install.wim" Datei
                        $ParameterFuerExportWindowsImage = @{
                            SourceImagePath = "$installWimPath"
                            SourceIndex = '4'
                            CompressionType = 'max'
                            DestinationImagePath = "$DestinationImagePath$DestinationImageName"
                        }
                        Remove-Item -Path $DestinationImagePath$DestinationImageName -ErrorAction SilentlyContinue	
                        Export-WindowsImage @ParameterFuerExportWindowsImage
                        
                        # ISO-Datei wieder entladen (unmount)
                        $ParameterFuerDismountDiskImage = @{
                            ImagePath = "$IsoPath$NewFile"
                        }
                        Dismount-DiskImage @ParameterFuerDismountDiskImage
                        Clear-Host
                        if ((get-childitem $WindowsUpdateDirectroy).count -eq 0){
                                Write-Host "Es wurden keine Updates unter $WindowsUpdateDirectroy gefunden.`n$DestinationImageName wurde nur in das Verzeichnis $DestinationImagePath kopiert."
                                Remove-Item -Path $MntDirectoryLetter$MntName
                                $ChoiceIso = Read-Host "Moechten Sie die ISO-Datei $NewFile loeschen (Standard: Nein)? (J/N)"
                                if ([string]::IsNullOrWhiteSpace($ChoiceIso)){
                                    $ChoiceIso = 'n'
                                }
                                if ($ChoiceIso.ToLower() -eq 'j') {
                                    Remove-Item -Path $IsoPath$NewFile
                                }
                                Write-Warning "Zum neustarten bitte 'N' oder nur 'Enter' eingeben."
                                $ChoiceAbbruch = Read-host "Skript abbrechen (Standard: Nein)? (J/N)"
                                if ([string]::IsNullOrWhiteSpace($ChoiceAbbruch)) {
                                    $ChoiceIso = 'n'
                                }
                                if (($ChoiceAbbruch.ToLower())-eq 'j') {
                                    Break
                                }

                        }
                        $GetItem = Get-ChildItem -Path "$WindowsUpdateDirectroy\*" -Include *.msu, *.cab -Name
                        if (-not(Get-Childitem $WindowsUpdateDirectroy).count -eq 0){
                            if (-not($GetItem)){
                                $GetWrongItem = Get-ChildItem -Path "$WindowsUpdateDirectroy\*" -Name
                                Write-Warning "$GetWrongItem ist keine .cab- oder .msu-Datei.`n"
                                continue
                            }
                        }
                        if (-not(get-childitem $WindowsUpdateDirectroy).count -eq 0){	
                            if (($GetItem)) {
                                                Write-Host "Anzahl an erkannten Updates:"$GetItem.Count"`nStarte den Vorgang 'Add-WindowsPackage'."
                                                #foreach ($update in $GetItem){Write-Host $update}
                                                # Mounten der install.wim Datei
                                                $DatumMount = Get-Date -UFormat "%d-%m-%Y-%R" | ForEach-Object { $_ -replace ":", "-" } # Ausgabe Tag-Monat-Jahr-Uhrzeit
                                                $ParameterFuerMountWindowsImage = @{
                                                    ImagePath = "$DestinationImagePath$DestinationImageName"
                                                    Path = "$MntDirectoryLetter$MntName"
                                                    Index = '1'
                                                    LogLevel = '2'
                                                    LogPath = "$MountImageLogPath\$DatumMount.log"
                                                    
                                                }
                                                Mount-WindowsImage @ParameterFuerMountWindowsImage
                                try {
                                        $DatumAddWinPck = Get-Date -UFormat "%d-%m-%Y-%R" | ForEach-Object { $_ -replace ":", "-" } # Ausgabe Tag-Monat-Jahr-Uhrzeit
                                        $Backup2 = $ErrorActionPreference
                                        $ErrorActionPreference = 'Stop'
                                        $GetItemUpdate = Get-ChildItem -Path $WindowsUpdateDirectroy -Include *.msu, *.cab -Name
                                        foreach ($update in $GetItemUpdate){
                                            $ParameterFuerAddWindowsPackage = @{
                                                Path = "$MntDirectoryLetter$MntName"
                                                PackagePath = "$WindowsUpdateDirectroy\$update"
                                                LogLevel = '2'
                                                LogPath = "$AddPckLogPath\$DatumAddWinPck.log"
                                                IgnoreCheck = $False    # Bei $True: Fügt alle Pakete in einem Ordner zu einem gemounteten Windows-Image hinzu, 
                                                                        # ohne zu prüfen, ob sie auf das Image anwendbar sind.
                                                PreventPending = $False # Bei $True: fügt eine .msu-Datei zu einem eingehängten Windows-Image hinzu, sofern keine Aktionen für das Paket oder das Image anstehen.
                                            }
                                                Write-Host "Installiere $update."
                                                Add-WindowsPackage @ParameterFuerAddWindowsPackage 
                                                #Write-Host "$update Installiert."
                                        }

                                        # Mount Verzeichnis bzw. Windows Edition aufraeumen nach einbindung Windows-Update Pakete
                                        $DatumRepairWinImg = Get-Date -UFormat "%d-%m-%Y-%R" | ForEach-Object { $_ -replace ":", "-" } # Ausgabe Tag-Monat-Jahr-Uhrzeit
                                        $ParameterFuerRepairWindowsImage = @{
                                            Path = "$MntDirectoryLetter$MntName"
                                            StartComponentCleanup = $True
                                            ResetBase = $True
                                            LogLevel = '2' # Errors and warnings
                                            LogPath = "$RepairWinLogPath\$DatumRepairWinImg.log"
                                        } 
                                        Repair-WindowsImage @ParameterFuerRepairWindowsImage
                                    }
                                catch {
                                    if (-not(Test-Path $SkriptErrorLog)) {
                                        New-Item -Path $SkriptErrorLog -ItemType Directory
                                    }
                                    $DatumSkriptError = Get-Date -UFormat "%d-%m-%Y-%R" | ForEach-Object { $_ -replace ":", "-" } # Ausgabe Tag-Monat-Jahr-Uhrzeit
                                    "Fehler: $_" >> "$SkriptErrorLog\$DatumSkriptError.log"
                                }
                                finally {
                                            $ParameterFuerDismountDiskImage = @{
                                                ImagePath = "$IsoPath$NewFile"
                                            }
                                            Dismount-DiskImage @ParameterFuerDismountDiskImage
                                            $DatumDismountImage = Get-Date -UFormat "%d-%m-%Y-%R" | ForEach-Object { $_ -replace ":", "-" } # Ausgabe Tag-Monat-Jahr-Uhrzeit
                                            $ParameterFuerDismountWindowsImage = @{
                                                Path = "$MntDirectoryLetter$MntName"
                                                Save = $True
                                                LogLevel = '2'
                                                LogPath = "$DisMountImageLogPath\$DatumDismountImage.log"
                                                
                                            }
                                            $ErrorActionPreference = $Backup2
                                            Dismount-WindowsImage @ParameterFuerDismountWindowsImage
                                            Remove-Item -Path $MntDirectoryLetter$MntName
                                        }
                                                Write-Host "$DestinationImageName Updates verarbeitet:"$GetItem.Count $GetItem
                                                $ChoiceIso = Read-Host "Moechten Sie die ISO-Datei $NewFile loeschen (Standard: Nein)? (J/N)"
                                                if ([string]::IsNullOrWhiteSpace($ChoiceIso)){
                                                    $ChoiceIso = 'n'
                                                }
                                                if ($ChoiceIso.ToLower() -eq 'j') {
                                                    Remove-Item -Path $IsoPath$NewFile
                                                }
                                                $ChoiceUpdate = Read-Host "Moechten Sie die Update-Dateien loeschen? (J/N)"
                                                if ($ChoiceUpdate.ToLower() -eq 'j') {
                                                    Remove-Item -Path "$WindowsUpdateDirectroy\*"
                                                }
                                                Write-Warning "Zum neustarten bitte 'N' oder nur 'Enter' eingeben."
                                                $ChoiceAbbruch = Read-host "Skript abbrechen (Standard: Nein)? (J/N)"
                                                if ([string]::IsNullOrWhiteSpace($ChoiceAbbruch)) {
                                                    $ChoiceIso = 'n'
                                                }
                                                if (($ChoiceAbbruch.ToLower())-eq 'j') {
                                                    Break
                                                }
                                                continue
                                
                                            }
                        }
                            else {
                                continue
                            }
                            } 
                
                }
            }
            catch {
                if (-not(Test-Path $SkriptErrorLog)) {
                    New-Item -Path $SkriptErrorLog -ItemType Directory
                }
                $DatumSkriptError = Get-Date -UFormat "%d-%m-%Y-%R" | ForEach-Object { $_ -replace ":", "-" } # Ausgabe Tag-Monat-Jahr-Uhrzeit
                "$DatumSkriptError Fehler: $_" >> "$SkriptErrorLog\$DatumSkriptError.skripterr.log"
            }
            finally {
                $ErrorActionPreference = $Backup
                $ZeitEndeSkript = Get-Date -UFormat "%R Uhr"
                Write-Host "$ScriptName wurde beendet.`nStart: $ZeitStartSkript`nEnde: $ZeitEndeSkript"
                
            }
        Stop-Transcript
        }
