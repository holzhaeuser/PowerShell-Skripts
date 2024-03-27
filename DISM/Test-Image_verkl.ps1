Export-WindowsImage -SourceImagePath "E:\sources\install.wim" -SourceIndex 4 -CompressionType max -DestinationImagePath "D:\dism\export.wim"
New-Item -Name "_Mount" -ItemType Directory -Path "D:\"
Mount-WindowsImage -ImagePath "D:\dism\export.wim" -Index 1 -Path "D:\_Mount"
Repair-WindowsImage -Path "D:\_Mount" -StartComponentCleanup -ResetBase
Dismount-WindowsImage -Path "D:\_Mount" -Save
Remove-Item -Path "D:\_Mount"
