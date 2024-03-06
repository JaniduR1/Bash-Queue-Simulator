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

exit_animation() {
    clear
    set -- "|" "/" "-" "\\"
	printf "Exiting... "
	for i in 1 2 3 4 5 6 7 8; do
        for spin in "$@"; do
            printf "\b%s" "$spin"
            sleep 0.1
        done
    done
    printf "\b"
    printf "\n"
}

#User information from Login page:
username="$1"
type="$2"

#Menu Display & Select
Menu()
{
	clear
	loading_animation
	clear
	echo -e "\033[32mHi $username, Make your selection or type bye to exit:\033[0m" #https://gist.github.com/vratiu/9780109
	echo -e "\033[34m1 for FIFO\033[0m"
	echo -e "\033[34m2 for LIFO\033[0m"

	#Checks Type (Admin or user)
	if [ "$type" = "admin" ]; then
        echo -e "\033[34m3 for Admin\033[0m"
    fi

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

		#Checks Type (Admin or user)
		3) 	if [ "$type" = "admin" ]; then
                sh Admin.sh
            else
                echo "Error 500"
                sleep 1
            fi;;

		BYE)
			while true; do
				echo "Do you really wanna exit (Y/N)"
				read check
				check=$(echo $check | tr '[:lower:]' '[:upper:]') # https://phoenixnap.com/kb/linux-tr

				if [ "$check" = "Y" ]; then
					exit_animation
					sleep 0.5
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
while true; do
	Menu
done
