#!/bin/bash

# Check if PMU-ops is loggend in the Terminus
who_ami=$(terminus whoami)
sleep 1.5

# Check if the $who_ami variable matches the specific value
if [ "$who_ami" != "managedupdates@pantheon.io" ]; then
    terminus auth:login --machine-token=5T3RvqzfTnUKhilmZm-pd33xCbv4H7_dBDDAtC06yp8aA # You can replace and add your own machine token here
else
# Machine token for PMU-ops is used here
    echo "Hello! You are now logged in as: $who_ami"
fi

# Added pause (2 sec) and clear
sleep 2
clear

# Pulling site's machine name
printf "\nCreating Snapshot Environments...\n"
echo "Please type-in the machine name of the Pantheon site: "
read sitename

cur_date=$(TZ="PST8PDT" date +'%y%m%d')
# Functions for creating snapshots of Dev, Test, and Live environemnts
# CREATE SNAPSHOT ENVIRONMENTS FOR DEV, TEST, AND LIVE
createsnpd() {
    # Define the pattern for DEV multidev environment
    pattern1="^snpd-[0-9]{6}$"
    # The machine name will be put here $sitename for the multidev environments
    environments=$(terminus multidev:list "$sitename" --format=list --field=id)
    # Loop through the multidev environments
    for multidevd in $environments; do
      # Check if the environment name matches the pattern1
      if [[ $multidevd =~ $pattern1 ]]; then
        # Delete the multidev environment
        terminus multidev:delete --delete-branch "$sitename.$multidevd" -y
        echo "Deleted Dev Snapshot Environment: $multidevd"
        # Exit the loop since the correct environment has been found
        break
      fi
    done
    terminus multidev:create $sitename.dev snpd-$cur_date
    echo "Created Dev Snapshot Environment: snpd-$cur_date"
    sleep 1
}

createsnpt() {
    # Define the pattern for TEST multidev environment
    pattern2="^snpt-[0-9]{6}$"
    # The machine name will be put here $sitename for the multidev environments
    environments=$(terminus multidev:list "$sitename" --format=list --field=id)
    # Loop through the multidev environments
    for multidevt in $environments; do
      # Check if the environment name matches the pattern2
      if [[ $multidevt =~ $pattern2 ]]; then
        # Delete the multidev environment
        terminus multidev:delete --delete-branch "$sitename.$multidevt" -y
        echo "Deleted Test Snapshot Environment: $multidevt"
        # Exit the loop since the correct environment has been found
        break
      fi
    done
    terminus multidev:create $sitename.test snpt-$cur_date
    echo "Created Test Snapshot Environment: snpt-$cur_date"
    sleep 1
}

createsnpl() {
    # Define the pattern for LIVE multidev environment
    pattern3="^snpl-[0-9]{6}$"
    # The machine name will be put here $sitename for the multidev environments
    environments=$(terminus multidev:list "$sitename" --format=list --field=id)
    # Loop through the multidev environments
    for multidevl in $environments; do
      # Check if the environment name matches the pattern3
      if [[ $multidevl =~ $pattern3 ]]; then
        # Delete the multidev environment
        terminus multidev:delete --delete-branch "$sitename.$multidevl" -y
        echo "Deleted Live Snapshot Environment: $multidevl"
        # Exit the loop since the correct environment has been found
        break
      fi
    done
    terminus multidev:create $sitename.live snpl-$cur_date
    echo "Created Live Snapshot Environment: snpl-$cur_date"
    sleep 1
}

while true; do
    read -p "Do you want to create the snapshot environments for $sitename? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Proceeding the creation of Snapshot Environments...";
                createsnpd
                createsnpt
                createsnpl
        break;;
        [Nn]* )
        exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

printf "\n\nSnapshot Environments for $sitename have been created successfully!\n"
sleep 1
echo "Press any key to exit..."
read -n 1 -s