#!/bin/sh
source ./Funcutions.sh

clear
echo "Enter ur username"
read username

echo "Enter your password"
read -s password


# Bye even at login

if Validation; then
    echo "Login successful. Access granted."
    #export SimUsageInfo=""
    sleep 2
    # Set these as global variable to access them throughout the different scripts
    export type=$(grep "^$username,$password," UPP.db | cut -d',' -f4)
    export username="$username"

    #export SimUsageInfo=""
    export userLoginTime=$(date +%s)
    UserExitTime

    # Sim Data Checker
    simData

    ./Menu.sh
    clear
else
    echo "Login failed: Invalid username or password. Access denied."
    sleep 2
    ./Login.sh
fi