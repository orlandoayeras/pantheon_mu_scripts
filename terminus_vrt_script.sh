#!/bin/zsh

echo "Please type-in the machine name of the Pantheon site: "
read sitename


site_info=$(terminus site:info $sitename --fields=id,organization --format=json)
site_uuid=$(echo "$site_info" | jq -r '.id')
org_uuid=$(echo $site_info | jq -r '.organization')

reference_url="https://snpd-230911-$sitename.pantheonsite.io"
subject_url="https://dev-$sitename.pantheonsite.io"


# Define the directory where you want to save the YAML file
output_directory="/Users/dymmrobot/pantheon/mu/ap_vrt_tools/vrt_yml/"

# Define the YAML file name
output_file="$output_directory/$sitename.yml"

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
terminus env:wake $sitename.snpd-230911
terminus env:wake $sitename.dev
terminus vrt ~/pantheon/mu/ap_vrt_tools/vrt_yml/$sitename.yml