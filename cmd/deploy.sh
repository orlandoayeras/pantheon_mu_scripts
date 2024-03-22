#!/bin/bash

pmus_load=("Please wait while we load required resources...")
speed=0.01

function pmus_text() {
    for text in "${pmus_load[@]}"; do
        for ((i=0; i<${#pmus_load}; i++)); do
            echo -n "${pmus_load:$i:1}"
            sleep $speed
        done
        echo
        sleep 1  # Add a pause between lines
    done
}

# Call the function to display the typing animation
pmus_text

sleep 2
clear


pmus=(
" _____    __  ___    ___    __      __     _______ "
"| ___  \ |  |/    \ /    \ |  |    |  |  /  _____/ "
"| |  | | |  _/^\  |_/^\  | |  |    |  | |  |____   "
"| |__/ / |  |  |  |   |  | |  |    |  |  \ ____  \ "
"|  ___/  |  |  |  |   |  | |  \ __ /  |  _____|  | "
"| |      |__|  |__|   |__|  \_______/_|  \______/  "
"|_|                                                "
)


# Function to display "pmus" characters
function display_pmus() {
    for line in "${pmus[@]}"; do
        echo "$line"
    done
}

# Call the function to display "pmus" characters
display_pmus
printf "\n\nWelcome to the Pantheon Managed Updates Script (PMUS)!\n"
echo "This script will help you deploy a Drupal or WordPress site to Pantheon."
echo "Developed and maintained by orlandoayeras for the Pantheon MU Team."
echo "Version: 0.4.3"
printf "Date: 2024-03-22\n\n\n"

deploy_drupal_site() {
    echo "Running Drupal script..."
    sleep 1
    ~/.pmus/cmd/mu_deploy_drupal.sh  # The actual path to for Drupal script
}

deploy_wp_site() {
    echo "Running WordPress script..."
    sleep 1
    ~/.pmus/cmd/mu_deploy_wp.sh  # The actual path to for WordPress script
}
exit_script() {
    echo "Exiting..."
    sleep 1
    exit 1
}

printf "\nWelcome! Please select an option:\n"
echo "1. Deploy a Drupal site"
echo "2. Deploy a WordPress site"
echo "3. Exit"
read -p "Enter the number corresponding to your choice: " choice

case $choice in
    1) deploy_drupal_site;;
    2) deploy_wp_site;;
    3) exit_script;;
    *) echo "Invalid choice. Please select a valid option.";;
esac
