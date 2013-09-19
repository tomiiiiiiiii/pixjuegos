#!/bin/bash
export LD_LIBRARY_PATH=$PWD/bgd-runtime:$LD_LIBRARY_PATH
export PATH=$PWD/bgd-runtime:$PATH
bgdi pato.dcb
sync
