#!/bin/sh

###
#This system will operate separately from the host systems (OS) username/ password system and will have separate username/password verification prior to the menu loading. 
#To this end you will need to create an admin script that will have the ability to create usernames, passwords and PIN which will store this information to an existing ‘UPP.db’ file. 
#Note that there must also be an ability to delete/update existing users too, which will only work when given the correct PIN. 
#Creating users/ deleting users can only be executed by the admin script, whilst changing the password can be done by both admin & user.
###

CreateUser()
{
    echo "Please enter a username (5 alphanumeric characters):"
    read username

    echo "Please enter a password for the user $username (5 alphanumeric characters):"
    read -s password
    echo "Please re-enter the password for the user $username:"
    read -s confirmPassword

    echo "Please enter a PIN for the user $username:"
    read -s pin
    echo "Please re-enter the PIN for the user $username:"
    read -s confirmPIN

    echo "$username,$password,$pin" >> "Usage.db"
    echo "User $username added successfully."
}

DeleteUser()
{
    echo "deleting user..."
}

UpdateUser()
{
    echo "updating user..."
}

echo "Admin Menu:"
echo "1. Add user"
echo "2. Delete user"
echo "3. Update user password"
read -p "Choose an option: " adminMenu

case $adminMenu in
    1) CreateUser;;
    2) DeleteUser;;
    3) UpdateUser;;
    *) echo "Invalid option";;
esac
