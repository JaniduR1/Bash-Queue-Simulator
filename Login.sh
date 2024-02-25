#!/bin/sh

clear
echo "Enter ur username"
read username

echo "Enter your password"
read -s password
echo password


Validation() {
    grep -q "^$username,$password," "Usage.db"
    return $?
}

if Validation; then
    echo "Login successful. Access granted."
    sleep 2
    clear
    ./Menu.sh
else
    echo "Login failed: Invalid username or password. Access denied."
    sleep 2
    ./Login.sh
fi