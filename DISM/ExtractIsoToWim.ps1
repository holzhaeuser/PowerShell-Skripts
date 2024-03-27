param (
    [string]$IsoPath = 'C:\dism\iso\',
    [string]$MntName = 'mnt',
    [string]$MntDirectoryLetter = 'C:\dism\',
    [string]$DestinationImagePath = 'C:\dism\komp\',
    [string]$DestinationImageName = 'install.wim',
    [string]$WindowsUpdateDirectroy = 'C:\dism\updates',
    [string]$AddPckLogPath = 'C:\dism\log\addpck',
    [string]$RepairWinLogPath = 'C:\dism\log\repairwin',
    [string]$MountImageLogPath = 'C:\dism\log\mountimage',
    [string]$DisMountImageLogPath = 'C:\dism\log\dismountimage'
)
$FileSystemWatcher = New-Object System.IO.FileSystemWatcher $IsoPath
$ScriptName = $MyInvocation.MyCommand.Name

while ($true) {
    
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
	    Write-Warning "$ScriptName benoetigt Administratorrechte.`n$ScriptName wird mit Administratorrechte neugestartet."
            $StartProcess = @{
            FilePath = 'powershell.exe'
            Verb = 'RunAs'
            ArgumentList = "-File $PSScriptRoot\$ScriptName"
        }
		Pause
		Start-Process @StartProcess
		Break 
        
    } else { 
	    Write-Host "Festgelegte Pfade:`nISO-Verzeichnis - $IsoPath`nUpdate-Verzeichnis - $WindowsUpdateDirectroy`nMount Pfad - $MntDirectoryLetter$MntName`n"
        
	    Write-Host "$ScriptName gestartet.`nUeberwache $IsoPath"
        $result = $FileSystemWatcher.WaitForChanged("All")
        $WatcherChangeType = $result.ChangeType
        $NewFile = $result.Name
        $FileExtension = [System.IO.Path]::GetExtension($NewFile).ToLower()
        if (-not ($FileExtension -eq ".iso")){
            Clear-Host
            Write-Warning "$NewFile ist keine .ISO-Datei.`n"
            continue
        }
        if (-not($WatcherChangeType -eq "Created")) {
            Clear-Host
            Write-Warning "Aenderungen im Verzeichnis $IsoPath erkannt.`n"
            continue
        }
        if ($WatcherChangeType -eq "Created" -and $FileExtension -eq ".iso") {
            $DatumDesLogs = Get-Date -UFormat "%d-%m-%Y-%R" | ForEach-Object { $_ -replace ":", "-" } # Ausgabe Tag-Monat-Jahr-Uhrzeit
            # Aenderungen am Verzeichnis werden ausgegeben!
                Clear-Host
                Write-Host "Neue ISO-Datei erkannt: $NewFile.`nVorgang wird gestartet."
                if (-not (Test-Path "$MntDirectoryLetter$MntName")) {
                    $ParameterFuerNewItem = @{
                        Path = "$MntDirectoryLetter"
                        ItemType = 'Directory'
                        Name = "$MntName"
                    }
                    New-Item @ParameterFuerNewItem
                }

                # Mounten der ISO-Datei
                $ParameterFuerMountDiskImage = @{
                    ImagePath = "$IsoPath$NewFile"
                    PassThru = $True
                }
                $mountedDisk = Mount-DiskImage @ParameterFuerMountDiskImage
                $driveLetter = ($mountedDisk | Get-Volume).DriveLetter

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
                    LogLevel = '2'
                }
                Remove-Item -Path $DestinationImagePath$DestinationImageName -ErrorAction SilentlyContinue	
                Export-WindowsImage @ParameterFuerExportWindowsImage
                
                # ISO-Datei wieder entladen (unmount)
                $ParameterFuerDismountDiskImage = @{
                    ImagePath = "$IsoPath$NewFile"
                }
                Dismount-DiskImage @ParameterFuerDismountDiskImage
                Clear-Host
                #Write-Host "$DestinationImageName wurde extrahiert und in das Verzeichnis $DestinationImagePath kopiert."
                if ((get-childitem $WindowsUpdateDirectroy).count -eq 0){
                        Write-Host "Es wurden keine Updates gefunden`n$DestinationImageName wurde nur in das Verzeichnis $DestinationImagePath kopiert."
                        Remove-Item -Path $MntDirectoryLetter$MntName
                        $ChoiceIso = Read-Host "Moechten Sie die ISO-Datei $NewFile loeschen (Standard: Nein)? (J/N)"
                        if ([string]::IsNullOrWhiteSpace($ChoiceIso)){
                            $ChoiceIso = 'n'
                        }
                        if ($ChoiceIso.ToLower() -eq 'j') {
                            Remove-Item -Path $IsoPath$NewFile
                        }
                        #Write-Host "Skript abbrechen (Standard: Nein)? (J/N)"
                        Write-Warning "Zum neustarten bitte 'N' oder nur 'Enter' eingeben."
                        $ChoiceAbbruch = Read-host "Skript abbrechen (Standard: Nein)? (J/N)"
                        if ([string]::IsNullOrWhiteSpace($ChoiceAbbruch)) {
                            $ChoiceIso = 'n'
                        }
                        if (($ChoiceAbbruch.ToLower())-eq 'j') {
                            Break
                        }

                }
                if (-not(get-childitem $WindowsUpdateDirectroy).count -eq 0){
                    $GetItem = Get-ChildItem -Path "$WindowsUpdateDirectroy\*" -Include *.msu, *.cab -Name
                    if (-not($GetItem)){
                        $GetWrongItem = Get-ChildItem -Path "$WindowsUpdateDirectroy\*" -Name
                        Write-Warning "$GetWrongItem ist keine .cab- oder .msu-Datei.`nInstall.wim wurde ohne Updates verarbeitet`n`n"
                        continue
                    }
                }
                if (-not(get-childitem $WindowsUpdateDirectroy).count -eq 0){	
                    if (($GetItem)) {
                   
                        Write-Host "Anzahl an erkannten Updates:"$GetItem.Count"`n$GetItem`nStarte den Vorgang 'Add-WindowsPackage'."
                        # Mounten der install.wim Datei
                        $ParameterFuerMountWindowsImage = @{
                            ImagePath = "$DestinationImagePath$DestinationImageName"
                            Path = "$MntDirectoryLetter$MntName"
                            Index = '1'
                            LogLevel = '2'
                            LogPath = "$MountImageLogPath\$DatumDesLogs.log"
                            
                        }
                        Mount-WindowsImage @ParameterFuerMountWindowsImage
                        try {
                            $Backup = $ErrorActionPrefernece
                            $ErrorActionPrefernece = 'Stop'

                            $ParameterFuerAddWindowsPackage = @{
                            Path = "$MntDirectoryLetter$MntName"
                            PackagePath = "$WindowsUpdateDirectroy"
                            LogLevel = '2'
                            LogPath = "$AddPckLogPath\$DatumDesLogs.log"
                            IgnoreCheck = $False    # Bei $True: Fügt alle Pakete in einem Ordner zu einem gemounteten Windows-Image hinzu, 
                                                    # ohne zu prüfen, ob sie auf das Image anwendbar sind.
                            PreventPending = $False # Bei $True: fügt eine .msu-Datei zu einem eingehängten Windows-Image hinzu, sofern keine Aktionen für das Paket oder das Image anstehen.
                            
                            }
                            Add-WindowsPackage @ParameterFuerAddWindowsPackage

                            # Mount Verzeichnis bzw. Windows Edition aufraeumen nach einbindung Windows-Update Pakete
                            $ParameterFuerRepairWindowsImage = @{
                                Path = "$MntDirectoryLetter$MntName"
                                StartComponentCleanup = $True
                                ResetBase = $True
                                LogLevel = '2' # Errors and warnings
                                LogPath = "$RepairWinLogPath\$DatumDesLogs.log"
                            } 
                            Repair-WindowsImage @ParameterFuerRepairWindowsImage 
                        }
                        catch {
                            "Fehler: $_"
                        }
                        finally {
                            $ParameterFuerDismountWindowsImage = @{
                                Path = "$MntDirectoryLetter$MntName"
                                Save = $True
                                LogLevel = '2'
                                LogPath = "$DisMountImageLogPath\$DatumDesLogs.log"
                                
                            }
                            $ErrorActionPrefernece = $Backup
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
                        #Write-Host "Skript abbrechen (Standard: Nein)? (J/N)"
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
Clear-Host
Write-Host "$ScriptName wurde beendet."