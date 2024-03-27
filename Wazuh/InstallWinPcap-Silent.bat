
IF NOT EXIST "%ProgramFiles(x86)%\WinPcap" MKDIR "%ProgramFiles(x86)%\WinPcap"
COPY /Y "\\DC01\Freigabe\Programme\WinPcap\Program Files (x86)-WinPcap\*.*" "%ProgramFiles(x86)%\WinPcap\"
 
COPY /Y "\\DC01\Freigabe\Programme\WinPcap\System32\Packet.dll" "%SystemRoot%\System32\"
COPY /Y "\\DC01\Freigabe\Programme\WinPcap\System32\wpcap.dll" "%SystemRoot%\System32\"
COPY /Y "\\DC01\Freigabe\Programme\WinPcap\System32\drivers\npf.sys" "%SystemRoot%\System32\drivers\"
 
COPY /Y "\\DC01\Freigabe\Programme\WinPcap\SysWOW64\Packet.dll" "%SystemRoot%\SysWOW64\"
COPY /Y "\\DC01\Freigabe\Programme\WinPcap\SysWOW64\wpcap.dll" "%SystemRoot%\SysWOW64\"
COPY /Y "\\DC01\Freigabe\Programme\WinPcap\SysWOW64\pthreadVC.dll" "%SystemRoot%\SysWOW64\"
sc create npf type= kernel start= auto error= normal binPath= System32\drivers\npf.sys tag= no DisplayName= "NetGroup Packet Filter Driver"
sc start npf

REGEDIT /s "WinPcap.reg"
REGEDIT /s "WinPcapInst.reg"

:END