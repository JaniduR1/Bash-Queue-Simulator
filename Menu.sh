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
			echo "Do you really wanna exit (Y/N)"
			read yes
			if [ "$yes" = "Y" ] || [ "$confirm" = "y" ]; then
                exit 0
			else
				Menu
			fi
			;;

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
