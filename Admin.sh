#!/bin/sh

###
#This system will operate separately from the host systems (OS) username/ password system and will have separate username/password verification prior to the menu loading. 
#To this end you will need to create an admin script that will have the ability to create usernames, passwords and PIN which will store this information to an existing ‘UPP.db’ file. 
#Note that there must also be an ability to delete/update existing users too, which will only work when given the correct PIN. 
#Creating users/ deleting users can only be executed by the admin script, whilst changing the password can be done by both admin & user.
###

CreateUser()
{
    clear

    ## Username Creation
    while true; do
        clear
        echo "Please enter a username (must be 5 alphanumeric characters): "
        read username

        if echo "$username" | grep -Eq "^[a-zA-Z0-9]{5}$"; then # Checks if it doesnt match the given extended regex "E"
            if grep -q "^$username," "UPP.db"; then # Checks if the username already exists
                echo "The given username already exists, please change it!!!"
                sleep 1.5
            else
                break
            fi
        else
            echo "Username needs to be 5 alphanumeric characters!!!"
            sleep 1.5
        fi
    done


    ## Password Creation
    while true; do
        clear
        echo "Please enter a 5 alphanumeric character password for the user $username:"
        read -s password

        if ! echo "$password" | grep -Eq "^[a-zA-Z0-9]{5}$"; then
            echo "Password needs to be 5 alphanumeric characters!!!"
            sleep 1.5
            continue  # Loops back and asks for a valid password again
        fi

        echo "Please re-enter the password for the user $username:"
        read -s confirmPassword

        # Checks if passwords match
        if [ "$password" != "$confirmPassword" ]; then
            echo "Passwords don't match!!!"
            sleep 1.5
        else
            break
        fi
    done


    ## PIN Creation
    while true; do
        clear
        echo "Please enter a PIN for the user $username:"
        read -s pin

        if ! echo "$pin" | grep -Eq "^[0-9]{3}$"; then
            echo "PIN must be 3 digits!!!"
            sleep 1.5
            continue # Loops back and asks for a valid PIN again
        fi

        echo "Please re-enter the PIN for the user $username:"
        read -s confirmPIN

        if [ "$pin" != "$confirmPIN" ]; then
            echo "PINs don't match!!!"
            sleep 1.5
        else
            break
        fi
    done

    echo "$username,$password,$pin,user" >> "UPP.db"
    #echo "$username,$password,$pin,user" | tee UPP.db > /dev/null
    echo "User $username created successfully."
    return 0
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
