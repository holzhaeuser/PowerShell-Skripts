# Pfad zur ISO-Datei
#$isoPath = "C:\dism\iso\SERVER_EVAL_x64FRE_de-de.iso" <- Statischer Pfad
$isoPath = $args[0]
# Einbinden der ISO-Datei
$mntedDisk = Mount-DiskImage -ImagePath $isoPath -PassThru
$driveLetter = ($mntedDisk | Get-Volume).DriveLetter
# Pfad zur "install.wim" Datei innerhalb des ISO Laufwerks
$sourcePath = "${driveLetter}:\sources"
$installWimPath = Join-Path $sourcePath "install.wim"
# Aus der install.wim die "Datacenter mit GUI"-Edition rausziehen und komprimieren und ISO-Datei wieder entladen
Export-WindowsImage -SourceImagePath $installWimPath -SourceIndex 4 -CompressionType max -DestinationImagePath "C:\dism\komp\install.wim"
DisMount-DiskImage -ImagePath $isoPath
# Verzeichnis "_mnt" erstellen und "install.wim" einbinden
New-Item -Name "_mnt" -ItemType Directory -Path "C:\"
Mount-WindowsImage -ImagePath "C:\dism\komp\install.wim" -Index 1 -Path "C:\_mnt"
# Mount Verzeichnis bzw. Windows Edition aufraeumen und Ausgabe verf. Edition
#Repair-WindowsImage -Path "C:\_mnt" -StartComponentCleanup -ResetBase
#Get-WindowsEdition -Path "C:\_mnt"
# Nach Abschluss Aenderungen speichern und Verzeichnis "_mnt" entladen und löschen
Dismount-WindowsImage -Path "C:\_mnt" -Save $true
Remove-Item -Path "C:\_mnt"  