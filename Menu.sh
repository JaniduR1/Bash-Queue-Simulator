#!/bin/sh
source ./Funcutions.sh

#Menu Display & Select
Menu()
{
	clear
	#loadingAnimation
	clear
	# echo "$type"
	# sleep 5
	# clear
	echo -e "\033[32mHi $username, Make your selection or type bye to exit:\033[0m" #https://gist.github.com/vratiu/9780109
	echo -e "\033[34m1 For FIFO\033[0m"
	echo -e "\033[34m2 For LIFO\033[0m"
	echo -e "\033[34m3 To change your password\033[0m"
	echo -e "\033[34m4 To manage simulation data\033[0m"

	#Checks Type (Admin or user)
	if [ "$type" = "admin" ]; then
        echo -e "\033[34m===================\033[0m"
        echo -e "\033[34m5 For Admin Functions\033[0m"
        echo -e "\033[34m===================\033[0m"
    fi

	echo -e "\033[31m-------------------\033[0m"
	echo -e "\033[31mBYE for exit\033[0m"
	echo -e "\033[31m-------------------\033[0m"
	echo "Please Enter Selection:"
	read selected
	MenuSel $selected
}


#Menu case
MenuSel()
{
	case $(echo $1 | tr '[:lower:]' '[:upper:]') in
		1) sh FIFO.sh;;
		2) sh LIFO.sh;;
		3) 
			clear 
			ChangePassword;;
		4)
    		clear
			simData;;

		#Checks Type (Admin or user)
		5) 	if [ "$type" = "admin" ]; then
				clear
                ./Admin.sh
				# exit 0
            else
                echo "Permision Denied"
                sleep 1.5
				Menu
            fi;;
		

		BYE) BYE;;

		*) echo "Invalid Selection"
			sleep 1
			Menu;;
	esac
}

while true; do
	Menu
done
