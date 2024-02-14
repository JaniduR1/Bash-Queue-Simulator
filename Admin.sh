#!/bin/sh

###
#This system will operate separately from the host systems (OS) username/ password system and will have separate username/password verification prior to the menu loading. 
#To this end you will need to create an admin script that will have the ability to create usernames, passwords and PIN which will store this information to an existing ‘UPP.db’ file. 
#Note that there must also be an ability to delete/update existing users too, which will only work when given the correct PIN. 
#Creating users/ deleting users can only be executed by the admin script, whilst changing the password can be done by both admin & user.
###

CreateUser()
{
    echo "creating user..."
}

DeleteUser()
{
    echo "deleting user..."
}

UpdateUser()
{
    echo "updating user..."
}

