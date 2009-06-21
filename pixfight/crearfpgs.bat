@echo off
mkdir fpg
cd src
..\bennu\bgdc -Ca pxlfpg.prg > null
..\bennu\bgdi pxlfpg
del pxlfpg.dcb /f
del null /f
cd ..
exit