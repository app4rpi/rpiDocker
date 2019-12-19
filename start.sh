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
echo -e '\n\tFinal issues ... \n'$LINE'\n'
return 1
}
# --------------------------------------------------------------------------
# Main menu
initialIssues
while true; do
    clear
    echo -e $LINE"\n\tOptions\n"$LINE 
    echo -e "  1. rPi maintenance"
    echo -e "  2. Manage USB drives"
    echo -e "  3. Docker maintenance"
    echo -e "  4. Web Server maintenance"
    echo
    echo -e "  u. Other services & apps"
    echo -e "  t. Test script"
    echo
    echo -e "  x. Exit"
    echo -en $LINE"\n\t"; read -rsn1 -p "Enter choice -> " key
    case $key in
        1) ./rPiMaintenance.sh ;;
        2) ./rpiManageStorage.sh ;;
        3) ./dockerMaintenance.sh ;;
        4) ./webServerMaintenance.sh ;;
        u) unableFunction 
           echo -en "\n"$LINE"\n\t"; read -rsn1 -p "Press key to continue -> " key ;;
        t) ./test.sh ;;
        x) break ;;
    esac
    [[ $? = 1 ]] && break
done
#
finalIssues
exit
