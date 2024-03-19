#!/bin/sh
source ./Funcutions.sh  

clear
loadingAnimation
clear

echo "The Simulation Data as FIFO: "
cat "simdata_$username.job"

SimUsage "FIFO"

echo "Press any key to exit"
read -n 1 -s
exit 0