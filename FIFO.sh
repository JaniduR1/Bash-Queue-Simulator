#!/bin/sh
source ./Funcutions.sh  

echo "The Simulation Data as FIFO: "
cat "simdata_$username.job"

SimUsage "FIFO"

sleep 2
exit 0