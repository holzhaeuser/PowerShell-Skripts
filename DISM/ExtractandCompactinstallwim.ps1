param (
    [string]$IsoPath = 'D:\dism\iso\SERVER_EVAL_x64FRE_de-de.iso',
    [string]$MntName = 'mnt',
    [string]$MntDirectoryLetter = 'D:\',
    [string]$DestinationImagePath = 'D:\dism\komp\',
    [string]$DestinationImageName = 'install.wim',
    [string]$WindowsUpdateDirectroy = 'D:\dism\updates'
)

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

# Verzeichnis "mnt" erstellen und "install.wim" einbinden
$ParameterFuerNewItem = @{
    Name = "$MntName"
    ItemType = 'Directory'
    Path = "$MntDirectoryLetter"
}
$ParameterFuerMountWindowsImage = @{
    ImagePath = "$DestinationImagePath$DestinationImageName"
    Index = '1'
    Path = "$MntDirectoryLetter$MntName"
}
New-Item  @ParameterFuerNewItem
Mount-WindowsImage @ParameterFuerMountWindowsImage

# Windows Update Einbinden - bei mehreren Updates:
# Updates werden Lexikografischreihenfolge [2_Update.msi, 10_Update.msi] eingelesen
#$ParameterFuerAddWindowsPackage = @{
#    Path = "$MntDirectoryLetter$MntName"
#    PackagePath = "$WindowsUpdateDirectroy"
#}
#Add-WindowsPackage @ParameterFuerAddWindowsPackage

# Mount Verzeichnis bzw. Windows Edition aufraeumen nach einbindung Windows-Update Pakete
#$ParameterFuerRepairWindowsImage = @{
#    Path = "$MntDirectoryLetter$MntName"
#    StartComponentCleanup = $True
#    ResetBase = $True
#}
#Repair-WindowsImage @ParameterFuerRepairWindowsImage

# Nach Abschluss der Aenderungen speichern und Verzeichnis "Mount" entladen und loeschen
$ParameterFuerDismountWindowsImage = @{
    Path = "$MntDirectoryLetter$MntName"
    Save = $True
}
$ParameterFuerRemoveItem = @{
    Path = "$MntDirectoryLetter$MntName"
}
Dismount-WindowsImage @ParameterFuerDismountWindowsImage
Remove-Item @ParameterFuerRemoveItem 

