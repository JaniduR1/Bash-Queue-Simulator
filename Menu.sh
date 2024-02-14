#!/bin/sh

#This is skel code

#Menu Display & Select
Menu()
{
	clear
	echo "Hi $Uname, Make your selection or type bye to exit:" 
	echo "1 for FIFO"
	echo "2 for LIFO"
	echo "BYE for exit"
	echo "Please Enter Selection:"
	read Sel
	MenuSel $Sel
}



#Menu case
MenuSel()
{
	case $(echo $1 | tr '[:lower:]' '[:upper:]') in
		1) sh FIFO.sh;;
		2) sh LIFO.sh;;

		BYE)
			while true; do
				echo "Do you really wanna exit (Y/N)"
				read check
				check=$(echo $check | tr '[:lower:]' '[:upper:]') # https://phoenixnap.com/kb/linux-tr

				if [ "$check" = "Y" ]; then
					exit 0
				elif [ "$check" = "N" ]; then
					Menu
					break
				else
					echo "That is not a valid choice. Please choose either 'Y' for yes or 'N' for No"
				fi
			done;;

		*) echo "Invalid Selection"
		sleep 1
		Menu;;
	esac
}

#Store username in global var
echo "Please Enter Username"
read Uname

while true; do
	Menu
done
