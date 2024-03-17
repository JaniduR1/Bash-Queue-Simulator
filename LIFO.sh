#!/bin/sh
source ./Funcutions.sh  

var="simdata_$username.job"

cat $var | cut -d "," -f 10
cat $var | cut -d "," -f 9
cat $var | cut -d "," -f 8
cat $var | cut -d "," -f 7
cat $var | cut -d "," -f 6
cat $var | cut -d "," -f 5
cat $var | cut -d "," -f 4
cat $var | cut -d "," -f 3
cat $var | cut -d "," -f 2
cat $var | cut -d "," -f 1

SimUsage "LIFO"

sleep 2
exit 0

# logSimulatorUsage "LIFO"

# # Existing content of LIFO.sh
# var="simdata_$username.job"

# # Assuming this part executes the LIFO logic
# cat $var | tail -r  # This is a simplistic approach; adjust based on your actual LIFO logic

# sleep 5
# exit 0