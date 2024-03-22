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
printf "\nThis is a script for Drupal MU Deployment...\n"
echo "Please type-in the machine name of the Pantheon site: "
read sitename
# echo "Please type-in the environment name of the source: "
# read multidev

# Prompt the user to select a name of the staging environment
echo "Choose the naming convention of the Staging environment: "
echo "1. mu-yymmdd (Manual Staging)"
echo "2. spu-yymmdd (PMU Staging))"
echo "3. autopilot (Autopilot Staging))"
read -p "Enter the number of the staging environment (1, 2, or 3): " pattern_choice

# Set the pattern based on user input
if [ "$pattern_choice" == "1" ]; then
  pattern="^mu-[0-9]{6}$"
  echo "Selected Staging environment: mu-yymmdd"
elif [ "$pattern_choice" == "2" ]; then
  pattern="^spu-[0-9]{6}$"
  echo "Selected Staging environment: spu-yymmdd"
elif [ "$pattern_choice" == "3" ]; then
  pattern="autopilot"
  echo "Selected Staging environment: autopilot"
else
  echo "Invalid staging environment choice. Using default staging environment: mu-yymmdd"
  pattern="^mu-[0-9]{6}$"
fi

# The machine name will be put here $sitename for the multidev environments
environments=$(terminus multidev:list "$sitename" --format=list --field=id)

# Loop through the multidev environments
for multidev in $environments; do
  # Check if the environment name matches the pattern 
  if [[ $multidev =~ $pattern ]]; then
    # Display the machine name and multidev environment
    printf "\nThe Pantheon site's machine name is $sitename and the environment is $multidev\n\n"
    # Exit the loop since the correct environment has been found
    break
  fi
done


# Prompt the user to select the action to be performed and ask for Snapshot Environments creation
while true; do
    read -p "Do you want to proceed with the deployment? [y,n] " yn
    case $yn in
        [Yy]* ) echo "Proceeding the creation of Snapshot Environments...";
                sleep 0.5
                while true; do
                    read -p "Do you want to create Snapshot environments? [y,n] " yn
                    case $yn in
                        [Yy]* ) echo "Proceeding the creation of Snapshot Environments...";
                                # CREATE SNAPSHOT ENVIRONMENTS FOR DEV, TEST, AND LIVE
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
                                cur_date=$(TZ="PST8PDT" date +'%y%m%d')
                                terminus multidev:create $sitename.dev snpd-$cur_date
                                echo "Created Dev Snapshot Environment: snpd-$cur_date"
                                sleep 1

                                # Define the pattern for TEST multidev environment
                                pattern1="^snpt-[0-9]{6}$"
                                # The machine name will be put here $sitename for the multidev environments
                                environments=$(terminus multidev:list "$sitename" --format=list --field=id)
                                # Loop through the multidev environments
                                for multidevt in $environments; do
                                  # Check if the environment name matches the pattern1
                                  if [[ $multidevt =~ $pattern1 ]]; then
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


                                # Define the pattern for LIVE multidev environment
                                pattern1="^snpl-[0-9]{6}$"

                                # The machine name will be put here $sitename for the multidev environments
                                environments=$(terminus multidev:list "$sitename" --format=list --field=id)

                                # Loop through the multidev environments
                                for multidevl in $environments; do
                                  # Check if the environment name matches the pattern1
                                  if [[ $multidevl =~ $pattern1 ]]; then
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
                                break;;
                        [Nn]* ) echo "Moving to deployment process..."
                                sleep 1
                                break;;
                        * ) echo "Please answer yes[y] or no[n]. ";;
                    esac
                done
        break;;
        [Nn]* ) echo "Exiting..."
        exit;;
        * ) echo "Please answer yes[y] or no[n]. ";;
    esac
done
sleep 1.5


# Pre-deployment prompt for available commits ready to merge from DEV to multidev
echo "Pulling the site's dashboard. Please check for any available updates through the dashboard...."
terminus dashboard:view --print $sitename.dev
# Prompt the user to press any key to continue
echo "Press any key to continue..."
read -n 1 -s

devtomdev(){
  echo "Merging commits from Dev to multidev $multidev..."
  terminus multidev:merge-from-dev -- "$sitename.$multidev"
  terminus drush "$sitename.$multidev" -- updb -y
  return
}
mdevtodev(){
  echo "\nMerging commits from multidev $multidev to Dev..."
  terminus multidev:merge-to-dev "$sitename.$multidev"
  terminus env:clear-cache "$sitename.dev"
  echo "Done!"
  echo "Visit the site here: https://dev-$sitename.pantheonsite.io"

  # Prompt the user to press any key to continue
  echo "Press any key to continue on deployment..."
  read -n 1 -s
  return
}


echo "Waking up $multidev environment..."
terminus env:wake "$sitename.$multidev";
echo "Done!"
sleep 1
while true; do
    read -p "Do you want to merge new commits from Dev to multidev [y,n,skip,exit] " yn
    case $yn in
        [Yy]* )   echo "\nMaking sure that new commits from Dev are merge to multidev $multidev..."
                  devtomdev
                  mdevtodev
        break;;
        [Nn]* )   echo "Proceeding on the next step..."
                  mdevtodev
        break;;
        [skip]* ) echo "Skipping to Test..."
                  sleep 1
        break;;
        [exit]* ) echo "Exiting..."
                  sleep 1.5
        exit;;
        *) echo "Please answer yes or no. "
        ;;
    esac
done



: '
# CREATING A VRT YAML FILE FOR SNPD AGAINST DEV
site_info=$(terminus site:info $sitename --fields=id,organization --format=json)
site_uuid=$(echo "$site_info" | jq -r '.id')
org_uuid=$(echo $site_info | jq -r '.organization')

reference_url="https://snpd-$cur_date-$sitename.pantheonsite.io"
subject_url="https://dev-$sitename.pantheonsite.io"


# Define the directory where you want to save the YAML file
output_directory="/Users/dymmrobot/pantheon/mu/ap_vrt_tools/vrt_yml/" # Replace this with your own directory

# Define the YAML file name
output_file="$output_directory/$sitename-dev.yml"

# Prompt the user to input labels and paths for tests
declare -a labels
declare -a paths

while true; do
    read -p -r "Enter a label for the page (or press Enter to finish): " label
    if [ -z "$label" ]; then
        break
    fi
    read -p "Enter the path for the page: " path
    labels+=("$label")
    paths+=("$path")
done


cat <<EOF > "$output_file"
site_uid: "$site_uuid"
org_uid: "$org_uuid"
reference_url: "$reference_url"
subject_url: "$subject_url"
tests:
  - label: "Home"
    path: "/"
    threshold: 0.8
    delay: 5
    follows_redirect: true
EOF

# Add the user-inputted labels and paths to the YAML file
for ((i=0; i<${#labels[@]}; i++)); do
    cat <<EOF >> "$output_file"
  - label: "${labels[i]}"
    path: "${paths[i]}"
    threshold: 0.8
    delay: 5
    follows_redirect: true
EOF
done

echo "Generated values saved to $output_file"

sleep 1.5
# Run the VRT
terminus env:wake $sitename.snpd-$cur_date
terminus env:wake $sitename.dev
terminus vrt ~/pantheon/mu/ap_vrt_tools/vrt_yml/$sitename-dev.yml # Replace this with your own directory
sleep 1.5
echo "If every pages passed, press any key to continue..."
read -n 1 -s
'

# Deploying staged updates from Dev to Test Step #1
# terminus env:deploy $sitename.test --sync-content --cc --note="Managed Updates: Deploying from Dev to Test"
while true; do
    read -p "Do you want to sync the content from Live to Test? [y,n] " yn
    case $yn in
        [Yy]* ) printf "Syncing the content from Live to Test..."
                terminus env:clone-content $sitename.live test --updatedb -y
                echo "Done! Proceeding on the next step..."
                break;;
        [Nn]* ) echo "Proceeding on the next step..."
                sleep 0.5
                break;;
        * ) echo "Please answer yes[y] or no[n]. ";;
    esac
done

# Deploying staged updates from Dev to Test Step #2
printf "\nDeploying from Dev to Test..."
# Prompt the user to input the deployment message
# Drupal Core
printf "\nEnter the Drupal core version updated (ex. 'Drupal core has been updated from 9.5.9 to 9.5.11' or 'Drupal core was not updated'): \n"
read v_message
dcv_message="Drupal Core:
- $v_message"
# Packages
printf "Enter a list of updated modules/themes (press Enter after each module, type 'done' when finished):\n"
# Initialize an empty array to store the modules
packages=()
# Read input from the user until they type 'done'
while true; do
    read package
    if [ "$package" = "done" ]; then
        break
    fi
    packages+=("$package") 
done
# Store the list of updated modules with bullet points
num_packages=${#packages[@]}
pkg_message="Modules/Themes ($num_packages):"
for package in "${packages[@]}"; do
    pkg_message+=$'\n'"- $package"
done
sleep 0.5

head_message="Pantheon Managed Updates - Deployed from $multidev"
deploy_message="$head_message

$dcv_message

$pkg_message"

terminus env:deploy $sitename.test --cc --note="$deploy_message" --updatedb
echo "Done!"
echo "Visit the site here: https://test-$sitename.pantheonsite.io"
# Prompt the user to press any key to continue
# echo "Press any key to continue on deployment.."
# read -n 1 -s

: '
# CREATING A VRT YAML FILE FOR SNPT AGAINST TEST
site_info=$(terminus site:info $sitename --fields=id,organization --format=json)
site_uuid=$(echo "$site_info" | jq -r '.id')
org_uuid=$(echo $site_info | jq -r '.organization')

reference_url="https://snpt-$cur_date-$sitename.pantheonsite.io"
subject_url="https://test-$sitename.pantheonsite.io"


# Define the directory where you want to save the YAML file
output_directory="/Users/dymmrobot/pantheon/mu/ap_vrt_tools/vrt_yml/" # Replace this with your own directory

# Define the YAML file name
output_file="$output_directory/$sitename-test.yml"

# Prompt the user to input labels and paths for tests
declare -a labels
declare -a paths

while true; do
    read -p "Enter a label for the page [or press Enter to finish]: " label
    if [ -z "$label" ]; then
        break
    fi
    read -p "Enter the path for the page: " path
    labels+=("$label")
    paths+=("$path")
done


cat <<EOF > "$output_file"
site_uid: "$site_uuid"
org_uid: "$org_uuid"
reference_url: "$reference_url"
subject_url: "$subject_url"
tests:
  - label: "Home"
    path: "/"
    threshold: 0.8
    delay: 5
    follows_redirect: true
EOF

# Add the user-inputted labels and paths to the YAML file
for ((i=0; i<${#labels[@]}; i++)); do
    cat <<EOF >> "$output_file"
  - label: "${labels[i]}"
    path: "${paths[i]}"
    threshold: 0.8
    delay: 5
    follows_redirect: true
EOF
done

echo "Generated values saved to $output_file"

sleep 1.5
# Run the VRT
terminus env:wake $sitename.snpt-$cur_date
terminus env:wake $sitename.test
terminus vrt ~/pantheon/mu/ap_vrt_tools/vrt_yml/$sitename-test.yml  # Replace this with your own directory
sleep 1.5
echo "If every pages passed, press any key to continue..."
read -n 1 -s
'


sleep 0.5
# Deploying staged updates from Test to Live
printf "\nDeploying from Test to Live..."
terminus env:deploy $sitename.live --cc --note="$deploy_message" --updatedb
echo "Done!"
echo "Visit the site here: https://live-$sitename.pantheonsite.io"
echo "Press any key to exit..."
read -n 1 -s

: '
# CREATING A VRT YAML FILE FOR SNPL AGAINST LIVE
site_info=$(terminus site:info $sitename --fields=id,organization --format=json)
site_uuid=$(echo "$site_info" | jq -r '.id')
org_uuid=$(echo $site_info | jq -r '.organization')

reference_url="https://snpl-$cur_date-$sitename.pantheonsite.io"
subject_url="https://live-$sitename.pantheonsite.io"


# Define the directory where you want to save the YAML file
output_directory="/Users/dymmrobot/pantheon/mu/ap_vrt_tools/vrt_yml/" # Replace this with your own directory

# Define the YAML file name
output_file="$output_directory/$sitename-live.yml"

# Prompt the user to input labels and paths for tests
declare -a labels
declare -a paths

while true; do
    read -p "Enter a label for the page [or press Enter to finish]: " label
    if [ -z "$label" ]; then
        break
    fi
    read -p "Enter the path for the page: " path
    labels+=("$label")
    paths+=("$path")
done


cat <<EOF > "$output_file"
site_uid: "$site_uuid"
org_uid: "$org_uuid"
reference_url: "$reference_url"
subject_url: "$subject_url"
tests:
  - label: "Home"
    path: "/"
    threshold: 0.8
    delay: 5
    follows_redirect: true
EOF

# Add the user-inputted labels and paths to the YAML file
for ((i=0; i<${#labels[@]}; i++)); do
    cat <<EOF >> "$output_file"
  - label: "${labels[i]}"
    path: "${paths[i]}"
    threshold: 0.8
    delay: 5
    follows_redirect: true
EOF
done

echo "Generated values saved to $output_file"

sleep 1.5
# Run the VRT
terminus env:wake $sitename.snpl-$cur_date
terminus env:wake $sitename.live
terminus vrt ~/pantheon/mu/ap_vrt_tools/vrt_yml/$sitename-live.yml # Replace this with your own directory
sleep 1.5
echo "If every pages are pass, press any key to continue..."
read -n 1 -s
'

exit