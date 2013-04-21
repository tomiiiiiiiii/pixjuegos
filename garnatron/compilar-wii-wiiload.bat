echo Introduce la IP de tu Wii de esta forma: tcp:192.168.1.6
set /p WIILOAD=
..\bennu-wii\wiiload ../bennu-wii/bgdc.elf /apps/garnatron/boot.prg
pause