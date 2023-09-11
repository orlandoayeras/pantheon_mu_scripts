#!/bin/bash

# Check if PMU-ops is loggend in the Terminus
who_ami=$(terminus whoami)
sleep 1.5

# Check if the $who_ami variable matches the specific value
if [ "$who_ami" != "managedupdates@pantheon.io" ]; then
    terminus auth:login --machine-token=5T3RvqzfTnUKhilmZm-pd33xCbv4H7_dBDDAtC06yp8aA
else
# Machine token for PMU-ops is used here, you can replace and add your own machine token
    echo "Hello! You are now logged in as: $who_ami"
fi

# Added pause (2 sec) and clear
sleep 2
clear


# Pull the machine name of the site
# To pull the machine name, you can check the platform domain and find the machine name by: dev-[machine-name].pantheonsite.io
echo "\nThis is a script for MU Multidev Deleting...\n"
echo "--- To pull the machine name, you can check the platform domain and find the machine name by: dev-[machine-name].pantheonsite.io --- \n"
echo "Please type-in the machine name of the Pantheon site: "
read sitename

# Define the pattern to search for multidev environments
pattern="^mu-[0-9]{6}$"

# The machine name will be put here $sitename for the multidev environments
environments=$(terminus multidev:list "$sitename" --format=list --field=id)

# Loop through the multidev environments
for environment in $environments; do
  # Check if the environment name matches the pattern
  if [[ $environment =~ $pattern ]]; then
    # Delete the multidev environment
    terminus multidev:delete --delete-branch $sitename.$environment -y
    echo "Deleted Multidev Environment: $environment"
  fi
done

# Creating the multidev out of master branch and pulling the contents from Live
# cur_date is the current date in the desired date
cur_date=$(date +'%y%m%d')
terminus multidev:create $sitename.live mu-$cur_date
terminus env:clear-cache "$sitename.mu-$cur_date"
