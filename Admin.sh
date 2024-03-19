#!/bin/sh
source ./Funcutions.sh


AdminMenu()
{
	clear
	loadingAnimation
    clear
	echo -e "\033[36m1 To add user\033[0m"
	echo -e "\033[36m2 To delete user\033[0m"
	echo -e "\033[36m3 To update a user password\033[0m"
	echo -e "\033[36m4 To acess useage information\033[0m"

	echo -e "\033[31m-------------------\033[0m"
	echo -e "\033[31mBYE for exit\033[0m"
	echo -e "\033[31m-------------------\033[0m"
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
