# pmus
## Pantheon MU Scripts (PMUS)
```
 _____    __  ___    ___    __      __     _______ 
| ___  \ |  |/    \ /    \ |  |    |  |  /  _____/ 
| |  | | |  _/^\  |_/^\  | |  |    |  | |  |____   
| |__/ / |  |  |  |   |  | |  |    |  |  \ ____  \ 
|  ___/  |  |  |  |   |  | |  \ __ /  |  _____|  | 
| |      |__|  |__|   |__|  \_______/_|  \______/  
|_|                                                
```
![Scanner](assets/images/pmu.png)

```
Welcome to the Pantheon Managed Updates Script Tool
This shell script tool will help you do MU processes on a Drupal or WordPress site in Pantheon.
Developed and maintained by orlandoayeras for the Pantheon MU Team.
Version: 0.4.3
Date: 2024-03-22
```

### Install via cURL<br />
```
curl -L "https://github.com/orlandoayeras/pmus/archive/refs/heads/main.zip" --output pmus.zip && unzip pmus.zip && mv pmus-main .pmus && chmod +x .pmus/* && rm -rf pmus.zip
```
Create a symlink to /usr/local/bin<br />
```
sudo ln -s ~/.pmus/pmus.sh /usr/local/bin/pmus && chmod +x /usr/local/bin/pmus
```
If prompt, type your password.<br />

Enjoy running it globally!
