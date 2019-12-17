#!/bin/bash
# This script has been tested on Raspbian 10 Buster image (v. September 2019)
# chmod +x ./start.sh
#  --------------------------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="-------------------------------------------------------"
source ./functions.sh
#  ---------------------------------------------------------
function initialIssues(){
echo -e 'Initial issues ... '
return 1
}
#  ----------------------------------
function finalIssues(){
echo -e '\n\n\tFinal issues ... \n'$LINE'\n'
return 1
}
# --------------------------------------------------------------------------
# Main menu
initialIssues
while true; do
    clear
    echo -e $LINE"\n\tOptions\n"$LINE 
    echo -e "  1. rPi maintenance"
    echo -e "  2. Web Server maintenance"
    echo -e "  3. Docker maintenance"
    echo -e "  5. iot server"
    echo -e "  6. Media server"
    echo -e "  7. music server"
    echo -e "  9. Other services & apps"
    echo -e "\n  t. Test\n"
    echo -e "  x. Exit"
    echo -en $LINE"\n\t"; read -rsn1 -p "Enter choice -> " key
    case $key in
        1) ./rPiMaintenance.sh ;;
        2) ./webServerMaintenance.sh ;;
        3) ./dockerMaintenance.sh ;;
        5) ./iotServer.sh ;;
        6) mediaServer ;;
        7) manageWebserver ;;
        t) ./test.sh ;;
        x) break ;;
        *) continue ;;
    esac
done
#
finalIssues
exit
