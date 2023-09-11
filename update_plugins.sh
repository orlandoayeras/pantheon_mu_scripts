#!/bin/bash

# Check if PMU-ops is loggend in the Terminus
who_ami=$(terminus whoami)
sleep 1.5
clear
# Check if the $who_ami variable matches the specific value
if [ "$who_ami" == "managedupdates@pantheon.io" ]; then
    echo "Hello! You are now logged in as: $who_ami"
else
    terminus auth:login --machine-token=5T3RvqzfTnUKhilmZm-pd33xCbv4H7_dBDDAtC06yp8aA
fi
# Added pause (2 sec) and clear
sleep 2
clear


# Pull the site's details
echo -e "\nThis is a script for MU WP staging...\n"
echo "Please type-in the machine name of the Pantheon site: "
read sitename

while true; do
    read -p "Do you want to proceed the staging? [y,n] " yn
    case $yn in
        [Yy]* ) echo "Waking up Dev environment..."
        terminus env:wake "$sitename.dev";
        break;;
        [Nn]* )
        exit;;
        * ) echo "Please answer yes(y) or no(n). ";;
    esac
done
sleep 1.5
clear

# Creating the multidev out of master branch and pulling the contents from Live
# cur_date will current date in the desired date
cur_date=$(date +'%y%m%d')
terminus multidev:create $sitename.live mu-$cur_date
terminus env:clear-cache "$sitename.mu-$cur_date"
terminus connection:set "$sitename.mu-$cur_date" sftp

# Get the list of plugins in JSON format
plugin_list=$(terminus wp $sitename.live -- plugin list --update=available --format=json)

# This will loop through the plugins and update them
echo "$plugin_list" | jq -r '.[] | .name' | while read -r plugin; do
    # Update the plugin
    terminus wp "$sitename.mu-$cur_date" -- plugin update "$plugin"
    
    # Check if the plugin update was successful
    if [ $? -eq 0 ]; then
        # Plugin updated successfully, create a Git commit
        terminus env:commit --message=“Updated $plugin” --force --  "$sitename.mu-$cur_date"
    else
        echo "Error updating $plugin plugin"
        continue  # Continue to the next plugin
    fi
done

# Define the list of plugins to update
# plugins=("plugin1" "plugin2" "plugin3")

# Loop through the plugins and update them one by one
# for plugin in "${plugins[@]}"; do
#     terminus wp plugin update "$plugin"
# done

