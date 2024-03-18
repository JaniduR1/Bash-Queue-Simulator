#!/bin/sh
source ./Funcutions.sh


UsageMenu()
{
    clear
	echo -e "\033[34m1 To see total time used by a specified user\033[0m"
	echo -e "\033[34m2 To see the most popular simulator used (per specified user)\033[0m"
	echo -e "\033[34m3 To see the most popular simulator overall\033[0m"
	echo -e "\033[34m4 To see a ranking list of the users who have used the system the most\033[0m"

	echo -e "\033[31mBYE for exit\033[0m"
	echo "Please Enter Selection:"
	read selected
	UsageMenuSelected $selected
}

UsageMenuSelected()
{
    case $(echo $1 | tr '[:lower:]' '[:upper:]') in
		1) TotalTimePerUser;;
		2) MostPopSimPerUser;;
		3) MostPopSimOverall;;
		4) RankingOfUsers;;

		BYE) BYE;;

		*) echo "Invalid Selection"
		sleep 1
		UsageMenu;;
	esac
}


while true; do
	UsageMenu
done