#!/bin/bash

deploy_drupal_site() {
    echo "Running Drupal script..."
    sleep 1
    ./mu_deploy_drupal.sh  # The actual path to for Drupal script
}

deploy_wp_site() {
    echo "Running WordPress script..."
    sleep 1
    ./mu_deploy_wp.sh  # The actual path to for WordPress script
}

echo "Welcome! Please select an option:"
echo "1. Deploy a Drupal site"
echo "2. Deploy a WordPress site"

read -p "Enter the number corresponding to your choice: " choice

case $choice in
    1) deploy_drupal_site;;
    2) deploy_wp_site;;
    *) echo "Invalid choice. Please select a valid option.";;
esac
