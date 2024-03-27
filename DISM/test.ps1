$isoFolder = "G:\dism2\iso\"
$updateFolder = "G:\dism2\updates\"

$FileSystemWatcherISO = New-Object System.IO.FileSystemWatcher $isoFolder
$FileSystemWatcherUpdate = New-Object System.IO.FileSystemWatcher $updateFolder

# Manueller Abbruch der Schleife
Write-Host "Mit CTRL+C kann das Überwachen abgebrochen werden."

while ($true) {
    $resultISO = $FileSystemWatcherISO.WaitForChanged("Created")
    $resultUpdate = $FileSystemWatcherUpdate.WaitForChanged("Created")

    if ($resultISO.ChangeType -eq "Created") {
        # Neue ISO-Datei gefunden
        $NewISO = $resultISO.Name
        Write-Host "Neue ISO-Datei entdeckt: $NewISO"

        # Extrahieren der install.wim
        $installWimPath = "G:\dism2\komp\install.wim"
        Expand-WindowsImage -ImagePath "$isoFolder$NewISO" -Index 1 -DestinationPath $installWimPath -Force
    }

    if ($resultUpdate.ChangeType -eq "Created") {
        # Neue Update-Datei gefunden
        $NewUpdateFile = $resultUpdate.Name
        Write-Host "Neue Update-Datei entdeckt: $NewUpdateFile"
        
        # Prüfen, ob es Update-Pakete gibt und anwenden
        if ((Get-ChildItem -Path $updateFolder -Filter *.msu,*.cab).Count -gt 0) {
            # Mounten der install.wim Datei
            $MountPath = "G:\mnt"
            if (-not (Test-Path $MountPath)) {
                New-Item -Path G:\ -ItemType Directory -Name mnt
            }
            Mount-WindowsImage -ImagePath $installWimPath -Path $MountPath -Index 1

            # Hinzufügen der Update-Pakete
            Add-WindowsPackage -Path $MountPath -PackagePath "$updateFolder$NewUpdateFile"

            # Entmounten der install.wim Datei
            Dismount-WindowsImage -Path $MountPath -Save
            Remove-Item -Path $MountPath
        } else {
            # Keine Update-Pakete gefunden, nur install.wim speichern
            Write-Host "Keine Update-Pakete gefunden. Speichere nur install.wim."
            Dismount-WindowsImage -Path $installWimPath -Save
        }
    }
}
