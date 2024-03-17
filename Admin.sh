#!/bin/sh
source ./Funcutions.sh

###
#This system will operate separately from the host systems (OS) username/ password system and will have separate username/password verification prior to the menu loading. 
#To this end you will need to create an admin script that will have the ability to create usernames, passwords and PIN which will store this information to an existing ‘UPP.db’ file. 
#Note that there must also be an ability to delete/update existing users too, which will only work when given the correct PIN. 
#Creating users/ deleting users can only be executed by the admin script, whilst changing the password can be done by both admin & user.
###


AdminMenu()
{
    clear
	echo -e "\033[34m1 To add user\033[0m"
	echo -e "\033[34m2 To delete user\033[0m"
	echo -e "\033[34m3 To update a user password\033[0m"
	echo -e "\033[34m4 To acess useage information\033[0m"

	echo -e "\033[31mBYE for exit\033[0m"
	echo "Please Enter Selection:"
	read selected
	AdminMenuSelected $selected
}
# Bye even at login

AdminMenuSelected()
{
    case $(echo $1 | tr '[:lower:]' '[:upper:]') in
		1) CreateUser;;
		2) DeleteUser;;
		3) ChangePassword;;
		4) ./UsageInformation.sh;;

		BYE) BYE;;

		*) echo "Invalid Selection"
		sleep 1
		AdminMenu;;
	esac
}

while true; do
	AdminMenu
done
