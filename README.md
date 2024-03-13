# pantheon_mu_scripts
Pantheon MU Scripts (PMUS)

Welcome to the Pantheon Managed Updates Script
This shell script tool will help you do MU processes on a Drupal or WordPress site in Pantheon.
Developed and maintained by orlandoayeras for the Pantheon MU Team.
Version: 0.2
Date: 2024-03-13

Install via cURL
curl -L "https://github.com/orlandoayeras/pmus/archive/refs/heads/main.zip" --output pmus.zip && unzip pmus.zip && mv pmus-main .pmus && chmod +x .pmus/* && rm -rf pmus.zip
Create a symlink to /usr/local/bin
sudo ln -s ~/.pmus/pmus.sh /usr/local/bin/pmus && chmod +x /usr/local/bin/pmus
If prompt, type your password.
Enjoy running it globally!
