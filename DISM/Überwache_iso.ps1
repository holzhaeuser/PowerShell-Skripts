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
    
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {
	    Write-Warning "$ScriptName benoetigt Administratorrechte."
            $StartProcess = @{
            FilePath = 'powershell.exe'
            Verb = 'RunAs'
            ArgumentList = "-File $PSScriptRoot\$ScriptName"
        }
		Pause
		Start-Process @StartProcess
		Break 
        
    } else {
	    Write-Host "EvalIsoToWim gestartet.`n`nFestgelegte Pfade:`nBereitgestellte .ISOs - $IsoPath`nBereitgestellte Updates - $WindowsUpdateDirectroy`nMount Pfad - $MntDirectoryLetter$MntName`n`nUeberwache $IsoPath"
        $result = $FileSystemWatcher.WaitForChanged("All")
        $WatcherChangeType = $result.ChangeType
        $NewFile = $result.Name
        $FileExtension = [System.IO.Path]::GetExtension($NewFile).ToLower()
        if (-not ($FileExtension -eq ".iso")){
            Clear-Host
            Write-Warning "$NewFile ist keine .ISO-Datei.`n"
            continue
        }
        if ($WatcherChangeType -eq "Created" -and $FileExtension -eq ".iso") {
            $DatumDesLogs = Get-Date -UFormat "%d-%m-%Y-%R" | ForEach-Object { $_ -replace ":", "-" } # Ausgabe Tag-Monat-Jahr-Uhrzeit
            # Aenderungen am Verzeichnis werden ausgegeben!
                Clear-Host
                Write-Host "Neue ISO Datei erkannt: $NewFile, Vorgang wird gestartet!"
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
                }
                Remove-Item -Path $DestinationImagePath$DestinationImageName -ErrorAction SilentlyContinue	
                Export-WindowsImage @ParameterFuerExportWindowsImage  
                Write-Host "$DestinationImageName wurde extrahiert und in das Verzeichnis: $DestinationImagePath kopiert."
                # ISO-Datei wieder entladen (unmount)
                $ParameterFuerDismountDiskImage = @{
                    ImagePath = "$IsoPath$NewFile"
                }
                Dismount-DiskImage @ParameterFuerDismountDiskImage

                    $GetItem = Get-ChildItem -Path "$WindowsUpdateDirectroy\*" -Include *.msu, *.cab	
                    if (($GetItem)) {
                        if (($GetItem.Count) -gt 1){
                            Write-Host "Es wurden "$GetItem.Count" gefunden, starte den Vorgang 'Add-WindowsPackage'."
                        }
                        else {
                            Write-Host "Es wurde "$GetItem.Count" gefunden.`nStarte den Vorgang 'Add-WindowsPackage'."
                            # Mounten der install.wim Datei
                            $ParameterFuerMountWindowsImage = @{
                                ImagePath = "$DestinationImagePath$DestinationImageName"
                                Path = "$MntDirectoryLetter$MntName"
                                Index = '1'
                                LogPath = "$MountImageLogPath\$DatumDesLogs.log"
                            }
                            Mount-WindowsImage @ParameterFuerMountWindowsImage
                                $ParameterFuerAddWindowsPackage = @{
                                Path = "$MntDirectoryLetter$MntName"
                                PackagePath = "$WindowsUpdateDirectroy"
                                LogPath = "$AddPckLogPath\$DatumDesLogs.log"

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
                            $ParameterFuerDismountWindowsImage = @{
                                Path = "$MntDirectoryLetter$MntName"
                                Save = $True
                                LogPath = "$DisMountImageLogPath\$DatumDesLogs.log"
                            }
                            Dismount-WindowsImage @ParameterFuerDismountWindowsImage
                            Remove-Item -Path $MntDirectoryLetter$MntName
                            
                            Remove-Item -Path $IsoPath$NewFile
                            Remove-Item -Path "$WindowsUpdateDirectroy\*"
                            Clear-Host
                            Write-Host "$DestinationImageName wurde mit Updates gespeichert. Uebwerwache jetzt wieder $IsoPath."
                        }
                    } else {
                            Write-Host "Keine Updates gefunden, starte Vorgang ohne Add-WindowsPackage."
                            # Mounten der install.wim Datei
                            $ParameterFuerMountWindowsImage = @{
                                ImagePath = "$DestinationImagePath$DestinationImageName"
                                Path = "$MntDirectoryLetter$MntName"
                                Index = '1'
                                LogPath = "$MountImageLogPath\$DatumDesLogs.log"
                            }
                            Mount-WindowsImage @ParameterFuerMountWindowsImage
                            $ParameterFuerDismountWindowsImage = @{
                                Path = "$MntDirectoryLetter$MntName"
                                Save = $True
                                LogPath = "$DisMountImageLogPath\$DatumDesLogs.log"
                            }
                            Dismount-WindowsImage @ParameterFuerDismountWindowsImage
                            Remove-Item -Path $MntDirectoryLetter$MntName
                            Remove-Item -Path $IsoPath$NewFile
                            Write-Host "Install.wim wurde ohne Updates verarbeitet. Ueberwache jetzt wieder $IsoPath."
                        }
        
        }
        $FileSystemWatcherUpd = New-Object System.IO.FileSystemWatcher $WindowsUpdateDirectroy 
        $resultupd = $FileSystemWatcherUpd.WaitForChanged("All")
        $WatcherChangeTypeupd = $resultupd.ChangeType
        $NewFileUpd = $resultupd.Name
        $FileExtensionupd = [System.IO.Path]::GetExtension($NewFileupd).ToLower()
        if ($WatcherChangeTypeupd -eq "Created"){
            if ($FileExtensionupd -eq ".cab" -or $FileExtensionupd -eq ".msu") {
                Write-Host "Update wurde im Ordner gefunden: $NewFileupd"
                $ParameterFuerNewItem = @{
                        Path = "$MntDirectoryLetter"
                        ItemType = 'Directory'
                        Name = "$MntName"
                    }
                    New-Item @ParameterFuerNewItem
                $ParameterFuerMountWindowsImage = @{
                    ImagePath = "$DestinationImagePath$DestinationImageName"
                    Path = "$MntDirectoryLetter$MntName"
                    Index = '1'
                    LogPath = "$MountImageLogPath\$DatumDesLogs.log"
                    }
                    Mount-WindowsImage @ParameterFuerMountWindowsImage
                $ParameterFuerAddWindowsPackage = @{
                    Path = "$MntDirectoryLetter$MntName"
                    PackagePath = "$WindowsUpdateDirectroy"
                    LogPath = "$AddPckLogPath\$DatumDesLogs.log"

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
                $ParameterFuerDismountWindowsImage = @{
                    Path = "$MntDirectoryLetter$MntName"
                    Save = $True
                    LogPath = "$DisMountImageLogPath\$DatumDesLogs.log"
                    }
                Dismount-WindowsImage @ParameterFuerDismountWindowsImage
                Remove-Item -Path $MntDirectoryLetter$MntName
                Remove-Item -Path "$WindowsUpdateDirectroy\*"
                Write-Host "Das Update wurde fuer $DestinationImageName hinzugefuegt."
                
        }
            }
        if (-not($WatcherChangeTypeupd -eq "Created")){
            Write-Host "Aenderungen im Verzeichnis $WindowsUpdateDirectroy erkannt."
            continue
            if (-not ($FileExtensionupd -eq ".cab" -or $FileExtensionupd -eq ".msu")) {
                Write-Host "Windows-Update Datei ist keine msu/cab Datei: $NewFileUpd"
                continue
            }
        }
        if (-not ($WatcherChangeType -eq "Created" -and $FileExtension -eq ".iso")){
            Write-Host "$NewFile ist keine .ISO-Datei."
            continue
        } else {
                continue
            } 
    }     
}