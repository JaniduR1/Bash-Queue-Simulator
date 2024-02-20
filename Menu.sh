#!/bin/sh

loading_animation() {
	clear
	set -- "." "." "." "." "." "." "." "."
	printf "Loading ["
	for word in "$@"
	do
	printf "$word"
	sleep 0.1
	done
	printf "]"
	printf "\n"
	sleep 0.3

}

#Menu Display & Select
Menu()
{
	clear
	loading_animation
	clear
	echo -e "\033[32mHi $Uname, Make your selection or type bye to exit:\033[0m" #https://gist.github.com/vratiu/9780109
	echo -e "\033[34m1 for FIFO\033[0m"
	echo -e "\033[34m2 for LIFO\033[0m"
	echo -e "\033[31mBYE for exit\033[0m"
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
