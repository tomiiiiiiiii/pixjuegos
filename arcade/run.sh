#!/bin/sh
export PATH=$PWD/bennu-linux:$PATH
export LD_LIBRARY_PATH=$PWD/bennu-linux/lib:$LD_LIBRARY_PATH

cd arcade
next=`bgdi arcade`
cd ..

echo Next: $next

if ["$next"=="salir"]; then exit; fi
cd $next
bgdi $next arcade
cd ..

./run.sh