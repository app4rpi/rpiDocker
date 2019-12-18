#!/bin/bash
# This script has been tested on Raspbian 10 Buster image (v. September 2019)
# chmod +x ./test.sh
#  --------------------------------------------------------------------------
sudo chmod +x ./functions.sh
sudo chmod +x ./rpiInstallApps.sh
sudo chmod +x ./rPiMaintenance.sh
sudo chmod +x ./rpiManageStorage.sh
sudo chmod +x ./start.sh
sudo chmod +x ./webServerConfig.sh
sudo chmod +x ./webServerMaintenance.sh
sudo chmod +x ./webServerStartup.sh
#  --------------------------------------------------------------------------
echo -en "\n"$LINE"\n\t"; read -rsn1 -p "Press key to continue -> " key
