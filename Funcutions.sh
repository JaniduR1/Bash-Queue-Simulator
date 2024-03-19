#!/bin/sh
export SimUsageInfo="" # Global variable to track simu usage info

# Check when a user exits and calls the function UserExit
UserExitTime() {
    trap UserExit EXIT
}


# Validate Users
Validation() {
    # https://www.shellscript.sh/external.html
    if grep -iq "^$username,$password," "UPP.db"; then # Use grep to find a username and password in UPP.db case-insensitively.
        return 0 # Success
    else
        return 1  # Login Failed
    fi
}



# Loading Animation
loadingAnimation() {
	clear
	set -- "." "." "." "." "." "." "." "." # Set positional parameters as .
	printf "Loading [" # Print loading message without a newline
	for word in "$@"
	do
	printf "$word" # Print each dot
	sleep 0.1 # Wait 0.1s between each dot (effect)
	done
	printf "]" # Close the animation bracket
	printf "\n" # New line
	sleep 0.3
	clear
}

# Exit Animation
exitAnimation() {
    clear
    set -- "|" "/" "-" "\\" # Set positional parameters
	printf "Exiting... "
	for i in 1 2 3 4; do # Loop to repeat 4 times
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
    local username
    local password
    local pin
    local userType
    clear

    ## Username Creation
    while true; do # To keep looping to ask for a username at every failed username input
        clear
        echo "Please enter a username (must be 5 alphanumeric characters): "
        read username

        if echo "$username" | grep -Eq "^[a-zA-Z0-9]{5}$"; then # Checks if the given username matches the given extended regex "E" quietly
            if grep -q "^$username," "UPP.db"; then # Checks if the username already exists
                echo "The given username already exists, please change it!!!" # Error for if the username exists
                sleep 1.5
            else
                break # Exit the loop if the given username is  5 alpha num char and doesnt exist in UPP.db
            fi
        else
            echo "Username needs to be 5 alphanumeric characters!!!" # If the username is not 5 alpha num char
            sleep 1.5
        fi
    done


    ## Password Creation
    while true; do # To keep looping to ask for a password at every failed password input
        clear
        echo "Please enter a 5 alphanumeric character password for the user $username:"
        read -s password # Reads silently

        if ! echo "$password" | grep -Eq "^[a-zA-Z0-9]{5}$"; then  # Checks if the given password matches the given extended regex "E" quietly
            echo "Password needs to be 5 alphanumeric characters!!!" # If not 5 alpha num char
            sleep 1.5
            continue  # Loops back and asks for a valid password again
        fi

        echo "Please re-enter the password for the user $username:"
        read -s confirmPassword # Reads silently

        # Checks if passwords match
        if [ "$password" != "$confirmPassword" ]; then # Checks if the password and confirm password matches
            echo "Passwords don't match!!!"
            sleep 1.5
        else
            break # End the loop if it passes all the tests
        fi
    done


    ## PIN Creation
    while true; do # To keep looping to ask for a PIN at every failed PIN input
        clear
        echo "Please enter a PIN for the user $username:"
        read -s pin # Read pin quietly

        if ! echo "$pin" | grep -Eq "^[0-9]{3}$"; then # Checks if the given PIN matches the given extended regex "E" quietly
            echo "PIN must be 3 digits!!!"
            sleep 1.5
            continue # Loops back and asks for a valid PIN again
        fi

        echo "Please re-enter the PIN for the user $username:"
        read -s confirmPIN

        if [ "$pin" != "$confirmPIN" ]; then # Checks if the PIN and confirm PIN matches
            echo "PINs don't match!!!"
            sleep 1.5
        else
            break
        fi
    done


    clear
    echo "Select the user type for $username:"
    echo "1) User"
    echo "2) Admin"
    read userType # Read a user type selection to choose from when creating a user to give correct role

    case "$userType" in
        1) userType="user";;
        2) userType="admin";;
        *) 
            echo "Invalid selection, setting $username as default 'user'"  # Default to "user" for an invalid input
            sleep 2
            userType="user";;
    esac

    echo "$username,$password,$pin,$userType" >> "UPP.db" # Append the new user to the UPP.db
    echo "User $username created successfully" # Success message
    sleep 1
    return 0
}

#Check if user exists
CheckUserExists() {
    local searchUsername=$1 # Local variable for username to search for
    if grep -q "^$searchUsername," "UPP.db"; then
        return 0  # Successfully found
    else
        echo "That username doesn't exist"
        sleep 2
        return 1  # Failed status if the user doesn't exist
    fi
}

#Deleting a user
DeleteUser()
{
    clear

    echo "Users Available: "
    cut -d',' -f1 "UPP.db" # Print a list of existing usernames
    sleep 1

    while true; do
        echo "Enter a specfic user to delete"
        read userToDelete # Read the username to delete

        # Check if user exists
        if ! CheckUserExists "$userToDelete"; then
            continue # Loop back to ask to enter a user that does exist
        fi

        while true; do
            clear
            echo "Please enter your PIN number to proceed: "
            read -s confirmationPIN # Read PIN silently

            #Checks if the PIN matches that specfic users PIN
            checkUserPIN=$(grep "^$userToDelete,.*,$confirmationPIN,user" "UPP.db")
            #Checks if the PIN matches that specfic admins PIN       
            checkAdminPIN=$(grep "^$username,.*,$confirmationPIN,admin" "UPP.db")

            # If both the users and admins pin variables are empty fail 
            if [ -z "$checkUserPIN" ] && [ -z "$checkAdminPIN" ]; then
                echo "Verification check failed, Please re check the PIN"
                sleep 1
                clear
            else
                break # If Valid / Successful break the loop
            fi
        done

        echo "Are you sure you want to delete, $userToDelete? Y/N"
        read confirm

        if [ "$confirm" = "Y" ] || [ "$confirm" = "y" ]; then
            rm "simdata_$userToDelete.job" # Removes the users .job file also
            # Take everything that doesn't match the user being deleted and move to a new file, then rename that new file to UPP.db
            grep -v "^$userToDelete," "UPP.db" > "newfile" && mv "newfile" "UPP.db" # Remove the user entry and update the file
            echo "User $userToDelete deleted"
            sleep 0.5
        else
            echo "Cancelled" # If the input to confirm variable anything other than Y for yes cancel the operation
            sleep 0.5
        fi
        break # End the loop
    done
}

# Change a password
ChangePassword(){
    local currentUser=$username # Local variable for current username
    local newPassword confirmPassword userPIN
    # If the user is an admin, show a list of users available
    if [ "$type" = "admin" ]; then
        clear
        echo "Users Available: "
        cut -d',' -f1 "UPP.db" # Print a list of users
        sleep 1
        # Choose a user
        echo "Enter the name of the user you would like to change: "
        read inputUsername

        # Check if a username is entered and if it exists
        if [ -z "$inputUsername" ] || ! CheckUserExists "$inputUsername"; then
            return  # Exit the function if the user does not exist
        fi

        currentUser="$inputUsername"
    fi

    # Set the flag as false to start
    local pinValid=false
    while [ "$pinValid" = false ]; do
        echo "Enter your PIN to change the password of $currentUser: "
        read -s userPIN
        #echo "You entered $userPIN"
        #sleep 2

        # Check if the current user is an admin and if they are changing another users password or has entered a username
        if [ "$type" = "admin" ]; then
            # If there is an admin PIN with the given PIN
            if grep -q "^$username,.*,$userPIN,admin" "UPP.db"; then # Check if the logged in admin pin is correct (matches their PIN in UPP.db)
                echo "Valid PIN"
                sleep 1
                pinValid=true # Set the flag to true 
            else
                echo "Incorrect PIN!"
                sleep 1
                clear
            fi

        else  # Users changing password
            if grep -q "^$currentUser,.*,$userPIN," "UPP.db"; then # Check if the PIN matches their own PIN
                echo "Valid PIN"
                sleep 1        
                pinValid=true  # Change flag to true if valid PIN
            else
                echo "Incorrect PIN" # If the PIN is wrong
                sleep 2
                clear
            fi
        fi
    done

	while true; do
		clear
        echo "Please enter a new 5 alphanumeric character password: "
        read -s newPassword

		# Check If Password is not 5 alphanumeric characters
		if ! echo "$newPassword" | grep -Eq "^[a-zA-Z0-9]{5}$"; then
            echo "Password needs to be 5 alphanumeric characters!!!"
            sleep 1.5
			clear
            continue  # Loops back
        fi

		echo "Please re-enter the password for the user $currentUser:"
        read -s confirmPassword

        # Then, check if passwords don't match
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
    
    # Update password in UPP.db
    if [ "$currentUser" != "$username" ] || [ "$type" != "admin" ]; then
        pin=$(grep "^$currentUser," UPP.db | cut -d',' -f3) # Extract the current PIN from UPP.db
        userType=$(grep "^$currentUser," UPP.db | cut -d',' -f4) # Extract the user type from UPP.db
        
        # Update UPP.db without the current user entry then add the updated entry with new password.
        grep -v "^$currentUser," UPP.db > tempfile && echo "$currentUser,$newPassword,$pin,$userType" >> tempfile && mv tempfile UPP.db
    else
        # For admin or self-password changes keep the existing logic
        grep -v "^$username," "UPP.db" > "tempfile" && echo "$username,$newPassword,$userPIN,admin" >> "tempfile" && mv "tempfile" "UPP.db"
    fi
    echo "Password for $currentUser has been changed"
    sleep 1
    return 0
}

# Total time used per user
TotalTimePerUser() {
    clear
    echo "Users Available: "
    cut -d',' -f1 "UPP.db" # List of users
    echo "Enter the username to check total time used:"
    read user

    if CheckUserExists "$user"; then # Verify if user exists
        local totalTime=0 # Initialise the total time variable
        while IFS= read -r line; do
            if [[ "$line" == *"$user logged in"* ]]; then
                # Extract the duration (string manipulation)
                local timeInfo="${line##*a total duration of }"
                local time="${timeInfo%% seconds*}"
                totalTime=$((totalTime + time)) # Add duration to the total time
            fi
        done < Usage.db # Read the data from Usage.db

        clear
        echo "$user has used a total of $totalTime seconds" # Display total time used by the specfied user
        sleep 2
    fi
}

# Most popular sim used per user
MostPopSimPerUser() {
    clear
    echo "Users Available: "
    cut -d',' -f1 "UPP.db" # List users
    echo "Enter the username to check the most popular simulator used:"
    read user

    if CheckUserExists "$user"; then # Check user exists
        clear
        FIFO=$(grep -c "$user used the simulator FIFO" Usage.db) # Count FIFO occurrences for that user
        LIFO=$(grep -c "$user used the simulator LIFO" Usage.db) # Count LIFO occurrences for that user

        # Compare FIFO and LIFO occurrences
        if [ "$FIFO" -gt "$LIFO" ]; then
            echo "The most popular simulator used by $user is FIFO with a total of $FIFO times"
            sleep 3
        elif [ "$LIFO" -gt "$FIFO" ]; then
            echo "The most popular simulator used by $user is LIFO with a total of $LIFO times"
            sleep 3
        elif [ "$FIFO" -ne 0 ] && [ "$FIFO" -eq "$LIFO" ]; then # If its not equal to a count of 0 and both are used the same amount of times
            echo "Both simulators have been used an equal time of $FIFO times"
            sleep 3
        else
            echo "No data found for the user $user"
            sleep
        fi
    fi
}

# Most popularsim used overall
MostPopSimOverall() {
    local FIFO=$(grep -c "used the simulator FIFO" Usage.db) # Count FIFO occurrences overall
    local LIFO=$(grep -c "used the simulator LIFO" Usage.db) # Count LIFO occurrences overall

    clear
    if [ "$FIFO" -gt "$LIFO" ]; then
        echo "The most popular simulator overall is FIFO which has been used $FIFO times"
        sleep 3
    elif [ "$LIFO" -gt "$FIFO" ]; then
        echo "The most popular simulator overall is LIFO which has been used used $LIFO times"
        sleep 3
    elif [ "$FIFO" -eq "$LIFO" ] && [ "$FIFO" -ne 0 ]; then
        echo "Both FIFO and LIFO have been used equally with each being used $FIFO times" # If its not equal to a count of 0 and both are used the same amount of times
        sleep 3
    else
        echo "No data available :( RIP sadge"
        sleep 2
    fi
}

# Ranking
RankingOfUsers() {
    local uname finalDuration
    temporaryTime="totalTimes.tmp" # Create a temporary file to hold each users total time.
    > "$temporaryTime" # Create and/or clear the contents within the file

    grep "logged in" Usage.db | while read -r line; do # Find every line that has the words logged in Usage.db
        user=$(echo "$line" | cut -d' ' -f2,3)  # Take the role (type) and name from the line
        duration=$(echo "$line" | grep -oE '[0-9]+ seconds' | cut -d' ' -f1)  # Take the duration from the line by matching the given regex pattern

        if [ -n "$duration" ]; then # If the duration is not empty
            if grep -q "^$user " "$temporaryTime"; then # If the current user already has a duration total in the tmep file
                existingTotal=$(grep "^$user " "$temporaryTime" | cut -d' ' -f3) # Take the existing total duration for this user
                newTotal=$((existingTotal + duration)) # Add the new duration to that existing total
                grep -v "^$user " "$temporaryTime" > "${temporaryTime}.tmp" # Remove the current line for the user from the temp file (duplicate)
                echo "$user $newTotal" >> "${temporaryTime}.tmp" # Add the new total time for this user to the temp file
                mv "${temporaryTime}.tmp" "$temporaryTime" # Replace the original temp file with the new one
            else
                # If the user doesn't have a total add them to the temp file with their current duration
                echo "$user $duration" >> "$temporaryTime"
            fi
        fi
    done

    echo "Rankings are:"
    # Sort the temp file by the total duration (descending)
    sort -k3 -nr "$temporaryTime" | while read -r user total; do
        # $total now shows (name)(duration)
        uname=$(echo "$total" | cut -d' ' -f1) # Take the 1st field of $total (name)
        finalDuration=$(echo "$total" | cut -d' ' -f2) # Take the 2nd field of $total (total time)

        echo "The $user $uname with a total time of $finalDuration seconds" # Output for the user
    done
	
	sleep 8
    rm "$temporaryTime" # After showing the rankings remove the temp file
    rm temp.tmp # After showing the rankings remove the temp file
}

simData() {
    local data="simdata_${username}.job" # Define the filename

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

            # Validate input format using grep (format as BXX where XX is a number)
            if echo "$byteValue" | grep -Eq '^B[0-9]{2}$'; then
                inputData="$inputData$byteValue," # append to inputData
                i=$((i + 1))  # add 1 to the counter
            else
                echo "Invalid Format! Enter the value in this format BXX - B00 or B63 etc"
                sleep 1
            fi
        done
        # Save inputData to the users simulation data file
        echo "$inputData" > "simdata_${username}.job"
        echo "Simulation data saved to simdata_${username}.job."
    }

    # Check if simulation data file already exists for the user.
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
                echo "B00,B99,B89,B33,B55,B01,B29,B18,B10,B11," > "$data" # Populate with predefined data
                break
            elif [ "$choice" = "2" ]; then
                enterSimData # Call above enterSimData for manual sim data input
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
        check=$(echo $check | tr '[:lower:]' '[:upper:]') # Convert input to lower then upper case

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
                clear
                echo "That is not a valid choice. Please choose either 'Y' for yes or 'N' for No"
                ;;
        esac
    done
} # https://www.shellscript.sh/functions.html



SimUsage() {
    local simName="$1" # Local variable for simulator name
    local timeUsed
    timeUsed=$(date +"%Y-%m-%d %H:%M:%S") # Get the current time
    
    SimUsageInfo="${SimUsageInfo}The $type $username used the simulator $simName at $timeUsed" # Append the usage information
    echo "$SimUsageInfo" >> Usage.db # Write updated information to Usage.db
}

# Function to handle user exit, logging the session duration and usage information.
UserExit() {
    local userLogoutTime=$(date +%s) # Get logout time (in seconds)
    local duration=$((userLogoutTime - userLoginTime)) # Calculate duration

    local loginTimeFormatted=$(date +"%Y-%m-%d %H:%M:%S" -d "@$userLoginTime") # Reformat login time (displaying)
    local logoutTimeFormatted=$(date +"%Y-%m-%d %H:%M:%S" -d "@$userLogoutTime") # Reformat logout time (displaying)

    #echo "Debugging SimUsageInfo before logging: $SimUsageInfo"
    #echo "Debugging Lower before logging: $simUsageInfo"

    printf "===================================================================\n" >> Usage.db # Display purposes (seperate from sim usage stuff)
    # Log the username and times and duration into
    printf "The $type $username logged in at $loginTimeFormatted and logged out at $logoutTimeFormatted, which is a total duration of $duration seconds" >> Usage.db
    echo "$SimUsageInfo" >> Usage.db
    printf "===================================================================\n" >> Usage.db
}