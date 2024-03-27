param (
    [string]$IsoPath = 'C:\dism\iso\',
    [string]$MntName = 'mnt',
    [string]$MntDirectoryLetter = 'C:\',
    [string]$DestinationImagePath = 'C:\dism\komp\',
    [string]$DestinationImageName = 'install.wim',
    [string]$WindowsUpdateDirectroy = 'C:\dism\updates\',
    [string]$AddPckLogPath = 'C:\dism\log\addpck',
    [string]$RepairWinLogPath = 'C:\dism\log\repairwin',
    [string]$MountImageLogPath = 'C:\dism\log\mountimage',
    [string]$DisMountImageLogPath = 'C:\dism\log\dismountimage'
)
$FileSystemWatcher = New-Object System.IO.FileSystemWatcher $IsoPath


while ($true) {
    $result = $FileSystemWatcher.WaitForChanged("Created")
    $WatcherChangeType = $result.ChangeType
 
    if ($WatcherChangeType -eq "Created") {
        $DatumDesLogs = Get-Date -UFormat "%d-%m-%Y-%R" | ForEach-Object { $_ -replace ":", "-" } # Ausgabe Tag-Monat-Jahr-Uhrzeit
        # Aenderungen am Verzeichnis werden ausgegeben!
        $NewFile = $result.Name
        $FileExtension = [System.IO.Path]::GetExtension($NewFile).ToLower()
 
        if ($FileExtension -eq ".msu" -or $FileExtension -eq ".cab") {
            #Write-Host "Neue Update-Datei in $WindowsUpdateDirectroy gefunden: $NewFile"
 
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
                ImagePath = "$IsoPath"
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
            Export-WindowsImage @ParameterFuerExportWindowsImage  

            # ISO-Datei wieder entladen (unmount)
            $ParameterFuerDismountDiskImage = @{
                ImagePath = "$IsoPath"
            }
            Dismount-DiskImage @ParameterFuerDismountDiskImage

            # Mounten der install.wim Datei
            $ParameterFuerMountWindowsImage = @{
                ImagePath = "$DestinationImagePath$DestinationImageName"
                Path = "$MntDirectoryLetter$MntName"
                Index = '1'
                LogPath = "$MountImageLogPath\$DatumDesLogs.log"
            }
            Mount-WindowsImage @ParameterFuerMountWindowsImage
 
            # Hinzufuegen des Windows Update-Pakets
            $ParameterFuerAddWindowsPackage = @{
                Path = "$MntDirectoryLetter$MntName"
                PackagePath = "$WindowsUpdateDirectroy$NewFile"
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
            # Entmounten der install.wim Datei
            $ParameterFuerDismountWindowsImage = @{
                Path = "$MntDirectoryLetter$MntName"
                Save = $True
                LogPath = "$DisMountImageLogPath\$DatumDesLogs.log"
            }
            Dismount-WindowsImage @ParameterFuerDismountWindowsImage
            Remove-Item -Path $MntDirectoryLetter$MntName
            
        }
    }
}