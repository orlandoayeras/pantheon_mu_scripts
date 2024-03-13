#!/bin/bash

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
echo "This shell script tool will help you do MU processes on a Drupal or WordPress site in Pantheon."
echo "Developed and maintained by orlandoayeras for the Pantheon MU Team."
echo "Version: 0.3"
printf "Date: 2024-03-13\n\n\n"

case "$1" in
  "update")
    ~/.pmus/cmd/update.sh
    ;;
   "deploy")
    ~/.pmus/cmd/deploy.sh
    ;;
    "mdev")
    ~/.pmus/cmd/del_multidev.sh
    ;;
  # Add more cases for other sub-commands as needed
  *)
    echo "Usage:
    [command] [sub-commands]
    Sub-command: 
    - update          Update the pmus version
    - deploy          Deploy a Drupal or WordPress site to Pantheon
    - mdev            Delete and create a mu-yymmdd multidev environment in Pantheon
    "
    ;;
esac