#!/bin/sh

# Validate Users
Validation() {
    grep -q "^$username,$password," "UPP.db" # https://www.shellscript.sh/external.html
    return $?
}



# Loading Animation
loadingAnimation() {
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
	clear
}

# Exit Animation
exitAnimation() {
    clear
    set -- "|" "/" "-" "\\"
	printf "Exiting... "
	for i in 1 2 3 4; do
        for spin in "$@"; do
            printf "\b%s" "$spin"
            sleep 0.1
        done
    done
    printf "\b"
    printf "\n"
	clear
}

# Creating a user
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
    sleep 1
    return 0
}

#Deleting a user
DeleteUser()
{
    clear

    echo "Users Available: "
    cut -d',' -f1 "UPP.db"
    sleep 1

    while true; do
        echo "Enter a specfic user to delete"
        read userToDelete

        #Check if user exists
        if ! grep -q "^$userToDelete," "UPP.db"; then
            echo "Username: $userToDelete, doesn't exist, please enter a valid existing user to delete"
            sleep 1.5
            clear
            continue # Loop back
        fi

        while true; do
            clear
            echo "Please enter your PIN number to proceed: "
            read confirmationPIN

            #Checks if the PIN matches that specfic users PIN
            checkUserPIN=$(grep "^$userToDelete,.*,$confirmationPIN,user" "UPP.db")
            #Checks if the PIN entered is an Admin PIN
            checkAdminPIN=$(grep ",$confirmationPIN,admin" "UPP.db")

            # If both the users and admins pin variables are empty fail 
            if [ -z "$checkUserPIN" ] && [ -z "$checkAdminPIN" ]; then
                echo "Verification check failed, Please re check the PIN"
                sleep 1
                clear
            else
                break # Valid / Successful
            fi
        done

        echo "Are you sure you want to delete, $userToDelete? Y/N"
        read confirm

        if [ "$confirm" = "Y" ] || [ "$confirm" = "y" ]; then
            # Take everything that doesn't match the user being deleted and move to a new file, then rename that new file to UPP.db
            grep -v "^$userToDelete," "UPP.db" > "newfile" && mv "newfile" "UPP.db"
            echo "User $userToDelete deleted"
            sleep 0.5
        else
            echo "Cancelled"
            sleep 0.5
        fi
        break
    done
}

#Check if user exists
CheckUserExists() {
    local searchUsername=$1
    if grep -q "^$searchUsername," "UPP.db"; then
        return 0  # Successfully found
    else
        echo "That username doesn't exist"
        sleep 2
        return 1  # Failed status if the user doesn't exist
    fi
}

# Change a password
ChangePassword(){
    local currentUser=$username
    # If the user is an admin, show a list of users available
    if [ "$type" = "admin" ]; then
        clear
        echo "Users Available: "
        cut -d',' -f1 "UPP.db"
        sleep 1
        # Choose a user
        echo "Enter the name of the user you would like to change: "
        read inputUsername
        if [[ ! -z "$inputUsername" ]]; then
            if CheckUserExists "$inputUsername"; then
                currentUser="$inputUsername"
            else
                return 1
            fi
        fi
    fi

    # Set the flag as false to start
    local pinValid=false
    while [ "$pinValid" = false ]; do
        echo "Enter your PIN to change the password of $currentUser: "
        read userPIN
        #echo "You entered $userPIN"
        #sleep 2

        # Check if the current user is an admin and if they are changing another users password or has entered a username
        if [ "$type" = "admin" ]; then
            # If there is an admin PIN with the given PIN
            # Check if the admin pin is correct
            if grep -q "^$username,.*,$userPIN,admin" "UPP.db"; then
                echo "Valid"
                sleep 1
                pinValid=true # Set the flag to true
            else
                echo "Incorrect PIN!"
                sleep 1
                clear
            fi

        else  # Users changing password
            if grep -q "^$currentUser,.*,$userPIN," "UPP.db"; then
                echo "Valid"
                sleep 1        
                pinValid=true  # If a user exists with the given PIN
            else
                echo "Incorrect PIN"
                sleep 2
                clear
            fi
        fi
    done

	while true; do
		clear
        echo "Please enter a new 5 alphanumeric character password: "
        read -s newPassword

		# Check If Password is 5 alphanumeric characters
		if ! echo "$newPassword" | grep -Eq "^[a-zA-Z0-9]{5}$"; then
            echo "Password needs to be 5 alphanumeric characters!!!"
            sleep 1.5
			clear
            continue  # Loops back
        fi

		echo "Please re-enter the password for the user $username:"
        read -s confirmPassword

        # Then, check if passwords match
        if [ "$newPassword" != "$confirmPassword" ]; then
            echo "Passwords don't match!!!"
            sleep 1
			clear
            continue  # Loop back to the beginning of the while loop
        else
			clear
            break  # Exit loop if successful
        fi
    done

    # Create admin or user?
    
    # Update password in UPP.db
    grep -v "^$username," "UPP.db" > "tempfile" && echo "$username,$newPassword,$userPIN,$type" >> "tempfile" && mv "tempfile" "UPP.db"
    echo "Your password has been changed"
	sleep 1
    return 0
}

simData() {
    local data="simdata_${username}.job"

    enterSimData() {
        inputData=""
        byteValue=""
        i=1  # Counter to check for 10 bytes

        while [ $i -le 10 ]; do
            clear
            if [ -n "$inputData" ]; then
                echo "Values entered so far - $inputData" # Values entered so far
            fi

            # Prompt for the next byte of data
            echo "Please enter the value for byte ${i}:"
            read byteValue

            # Validate input format using grep.
            if echo "$byteValue" | grep -Eq '^B[0-9]{2}$'; then
                inputData="$inputData$byteValue," # append to inputData with a ,
                i=$((i + 1))  # add 1 to the counter
            else
                echo "Invalid Format! Enter the value in this format BXX - B00 or B63 etc"
                sleep 0.5
            fi
        done
        # Save inputData to the user's simulation data file
        echo "$inputData" > "simdata_${username}.job"
        echo "Simulation data saved to simdata_${username}.job."
    }

    if [ ! -f "$data" ]; then
        clear
        echo "No simulation data file found"
        while true; do
            echo "Would you like to: "
            echo "1) Use the predefined simulation data"
            echo "2) Enter your own simulation data"
            read choice
            
            if [ "$choice" = "1" ]; then
                echo "Creating simulation data file with predefined data..."
                sleep 1.5
                echo "B00,B99,B89,B33,B55,B01,B29,B18,B10,B11," > "$data"
                break
            elif [ "$choice" = "2" ]; then
                enterSimData
                break
            else
                echo "Invalid choice. Please choose either 1 or 2"
                sleep 1
                clear
            fi
        done
    else
        clear
        echo "Simulation data file already exists"
        while true; do
            echo "Would you like to: "
            echo "1) Keep and use existing simulation data"
            echo "2) Overwrite with new data"
            read choice

            if [ "$choice" = "1" ]; then
                echo "Using existing simulation data"
                sleep 1
                clear
                break
            elif [ "$choice" = "2" ]; then
                enterSimData
                break
            else
                echo "Invalid choice. Please enter 1 or 2"
                sleep 1
                clear
            fi
        done
    fi
}

# Bye
BYE() {
    while true; do
        echo "Do you really wanna exit (Y/N)"
        read check
        check=$(echo $check | tr '[:lower:]' '[:upper:]')

        case "$check" in
            Y)
                exitAnimation
                sleep 0.5
                exit 0
                ;;
            N)
                return 0  # Return to the calling function
                ;;
            *)
                echo "That is not a valid choice. Please choose either 'Y' for yes or 'N' for No"
                ;;
        esac
    done
}

# https://www.shellscript.sh/functions.html