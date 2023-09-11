#!/bin/zsh

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
echo "\nThis is a script for WP MU Deployment...\n"
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
  echo "Invalid staging environment choice. Using default staging environment: autopilot"
  pattern="autopilot"
fi

# The machine name will be put here $sitename for the multidev environments
environments=$(terminus multidev:list "$sitename" --format=list --field=id)

# Loop through the multidev environments
for multidev in $environments; do
  # Check if the environment name matches the pattern 
  if [[ $multidev =~ $pattern ]]; then
    # Display the machine name and multidev environment
    echo "\nThe Pantheon site's machine name is $sitename and the environment is $multidev"
    # Exit the loop since the correct environment has been found
    break
  fi
done

while true; do
    read -p "Do you want to proceed the deployment? [y,n] " yn
    case $yn in
        [Yy]* ) echo "Waking up $multidev environment..."
        terminus env:wake "$sitename.$multidev";
        echo "Done!"
        sleep 1
        break;;
        [Nn]* ) echo "Exiting..."
        exit;;
        * ) echo "Please answer yes(y) or no(n). ";;
    esac
done
sleep 1.5



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
    terminus multidev:delete --delete-branch $sitename.$multidevd -y
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
    terminus multidev:delete --delete-branch $sitename.$multidevt -y
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
    terminus multidev:delete --delete-branch $sitename.$multidevl -y
    echo "Deleted Live Snapshot Environment: $multidevl"
    # Exit the loop since the correct environment has been found
    break
  fi
done
terminus multidev:create $sitename.live snpl-$cur_date
echo "Created Live Snapshot Environment: snpl-$cur_date"
sleep 1



# Deploying the staged updates from multidev to Dev
echo "Press any key to continue..."
read -n 1 -s
echo "Making sure that new commits from Dev are merge to multidev $multidev..."
terminus multidev:merge-from-dev -- $sitename.$multidev
echo "Done, merging.. from Dev to $multidev"
sleep 0.5
echo "Merging commits from multidev $multidev to Dev..."
terminus multidev:merge-to-dev $sitename.$multidev
echo "Done!"
echo "Visit the site here: https://dev-$sitename.pantheonsite.io"
# Prompt the user to press any key to continue
echo "Press any key to continue..."
read -n 1 -s

echo "Please type-in the machine name of the Pantheon site: "
read sitename


# CREATING A VRT YAML FILE FOR SNPD AGAINST DEV
site_info=$(terminus site:info $sitename --fields=id,organization --format=json)
site_uuid=$(echo "$site_info" | jq -r '.id')
org_uuid=$(echo $site_info | jq -r '.organization')

reference_url="https://$multidevd-$sitename.pantheonsite.io"
subject_url="https://dev-$sitename.pantheonsite.io"


# Define the directory where you want to save the YAML file
output_directory="/Users/dymmrobot/pantheon/mu/ap_vrt_tools/vrt_yml/" # Replace this with your own directory

# Define the YAML file name
output_file="$output_directory/$sitename-dev.yml"

# Prompt the user to input labels and paths for tests
declare -a labels
declare -a paths

while true; do
    read -p "Enter a label for the page (or press Enter to finish): " label
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
terminus env:wake $sitename.$multidevd
terminus env:wake $sitename.dev
terminus vrt ~/pantheon/mu/ap_vrt_tools/vrt_yml/$sitename-dev.yml # Replace this with your own directory
sleep 1.5
echo "If every pages passed, press any key to continue..."
read -n 1 -s


# Deploying staged updates from Dev to Test
# terminus env:deploy $sitename.test --sync-content --cc --note="Managed Updates: Deploying from Dev to Test"
while true; do
    read -p "Do you want to sync the content from Live to Test? [y,n] " yn
    case $yn in
        [Yy]* ) echo "Syncing the content from Live to Test..."
                terminus env:clone-content -- $sitename.live test -y
                terminus wp $sitename.test -- cache flush
                echo "Done! Proceeding on the next step..."
                break;;
        [Nn]* ) echo "Proceeding on the next step..."
                break;;
        * ) echo "Please answer yes(y) or no(n). ";;
    esac
done
echo "Deploying from Dev to Test..."
terminus env:deploy $sitename.test --cc --note="Pantheon Managed Updates: Deployed from $multidev"
echo "Done!"
echo "Visit the site here: https://test-$sitename.pantheonsite.io"
# Prompt the user to press any key to continue
echo "Press any key to continue to VRT..."
read -n 1 -s


# CREATING A VRT YAML FILE FOR SNPT AGAINST TEST
site_info=$(terminus site:info $sitename --fields=id,organization --format=json)
site_uuid=$(echo "$site_info" | jq -r '.id')
org_uuid=$(echo $site_info | jq -r '.organization')

reference_url="https://$multidevt-$sitename.pantheonsite.io"
subject_url="https://test-$sitename.pantheonsite.io"


# Define the directory where you want to save the YAML file
output_directory="/Users/dymmrobot/pantheon/mu/ap_vrt_tools/vrt_yml/" # Replace this with your own directory

# Define the YAML file name
output_file="$output_directory/$sitename-test.yml"

# Prompt the user to input labels and paths for tests
declare -a labels
declare -a paths

while true; do
    read -p "Enter a label for the page (or press Enter to finish): " label
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
terminus env:wake $sitename.$multidevt
terminus env:wake $sitename.test
terminus vrt ~/pantheon/mu/ap_vrt_tools/vrt_yml/$sitename-test.yml  # Replace this with your own directory
sleep 1.5
echo "If every pages passed, press any key to continue..."
read -n 1 -s



# Deploying staged updates from Test to Live
echo "Deploying from Test to Live..."
terminus env:deploy $sitename.live --cc --note="Pantheon Managed Updates: Deploying from $multidev"
echo "Done!"
echo "Visit the site here: https://live-$sitename.pantheonsite.io"
echo "Press any key to continue to VRT..."
read -n 1 -s


# CREATING A VRT YAML FILE FOR SNPL AGAINST LIVE
site_info=$(terminus site:info $sitename --fields=id,organization --format=json)
site_uuid=$(echo "$site_info" | jq -r '.id')
org_uuid=$(echo $site_info | jq -r '.organization')

reference_url="https://$multidevl-$sitename.pantheonsite.io"
subject_url="https://live-$sitename.pantheonsite.io"


# Define the directory where you want to save the YAML file
output_directory="/Users/dymmrobot/pantheon/mu/ap_vrt_tools/vrt_yml/" # Replace this with your own directory

# Define the YAML file name
output_file="$output_directory/$sitename-live.yml"

# Prompt the user to input labels and paths for tests
declare -a labels
declare -a paths

while true; do
    read -p "Enter a label for the page (or press Enter to finish): " label
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
terminus env:wake $sitename.$multidevl
terminus env:wake $sitename.live
terminus vrt ~/pantheon/mu/ap_vrt_tools/vrt_yml/$sitename-live.yml # Replace this with your own directory
sleep 1.5
echo "If every pages are pass, press any key to continue..."
read -n 1 -s
exit


# echo "Almost there! Flushing the caches..."
# terminus remote:wp bighealth.dev -- cache flush
# terminus env:clear-cache bighealth.dev
# echo "Done! Please run the Manual VRT."
