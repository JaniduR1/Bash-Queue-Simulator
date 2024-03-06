#!/bin/sh

clear
echo "Enter ur username"
read username

echo "Enter your password"
read -s password

Validation() {
    grep -q "^$username,$password," "UPP.db"
    return $?
}

if Validation; then
    echo "Login successful. Access granted."
    sleep 2
    type=$(grep "^$username,$password," UPP.db | cut -d',' -f4)
    ./Menu.sh "$username" "$type"
    clear
else
    echo "Login failed: Invalid username or password. Access denied."
    sleep 2
    ./Login.sh
fi