#!/bin/bash
echo "Updating PMUS to the latest version..."
cd ~ && curl -L "https://github.com/orlandoayeras/pmus/archive/refs/heads/main.zip" --output pmus.zip && unzip -q pmus.zip && rsync -a -q pmus-main/ .pmus/ && chmod +x .pmus/cmd/* && rm -rf pmus.zip pmus-main && cd -
sleep 0.5
echo "PMUS updated to the latest version!"