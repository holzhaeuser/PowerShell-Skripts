param (
    [string]$IsoPath = 'C:\dism\iso\SERVER_EVAL_x64FRE_de-de.iso',
    [string]$MntName = 'mnt',
    [string]$MntDirectoryLetter = 'C:\',
    [string]$DestinationImagePath = 'C:\dism\komp\',
    [string]$DestinationImageName = 'install.wim',
    [string]$WindowsUpdateDirectroy = 'C:\dism\updates\'
)
$folder = "$WindowsUpdateDirectroy"

$FileSystemWatcher = New-Object System.IO.FileSystemWatcher $folder

while ($true) {
    $result = $FileSystemWatcher.WaitForChanged('all')
    if ($result.TimedOut -eq $false)
    {
    # Aenderungen am Verzeichnis werden ausgegeben!
    $NewFile = ("{1}" -f $result.ChangeType, $result.name)
    Write-Host "Neues Update: $WindowsUpdateDirectroy$NewFile"
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
    $ParameterFuerAddWindowsPackage = @{
        Path = "$MntDirectoryLetter$MntName"
        PackagePath = "$WindowsUpdateDirectroy$NewFile"
    }
    Add-WindowsPackage @ParameterFuerAddWindowsPackage
    
    # Mount Verzeichnis bzw. Windows Edition aufraeumen nach einbindung Windows-Update Pakete
    $ParameterFuerRepairWindowsImage = @{
        Path = "$MntDirectoryLetter$MntName"
        StartComponentCleanup = $True
        ResetBase = $True
    }
    Repair-WindowsImage @ParameterFuerRepairWindowsImage
    
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
    }
    
}