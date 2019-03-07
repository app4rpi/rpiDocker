#!/bin/bash
# This script has been tested on Debian 9 Stretch image
# chmod +x ./start.sh
#  ---------------------------------------------------------
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
echo -e '\nFinal issues ... '
return 1
}
# --------------------------------------------------------------------------
function updateWeb() {
while true; do
    echo -e "\n"$LINE"\n\tUpdate web config\n"$LINE 
    echo -e "  1. View <context.sh> config files"
    echo -e "  3. Add domain & config files"
    echo -e "  4. Delete domains & config files"
    echo -e "  7. Verify config files & web structure"
    echo -e "  x. Exit\n"$LINE
    echo -en "\t"; read -rsn1 -p "Enter choice -> " key
    case $key in
        1) viewContext ;;
        3) manageDomain add ;;
        4) manageDomain del ;;
        7) verifyConfig ;;
        x) break ;;
        esac
    done
return
}
#  ----------------------------------
function updateServer() {
while true; do
    echo -e "\n"$LINE"\n\tUpdate & install options\n"$LINE 
    echo -e "  1. Update bash script config files"
    echo -e "  2. Update server & install uninstalled packages"
    echo -e "  r. Restart <context.sh> config file"
    echo -e "  4. Change Nameserver"
    echo -e "  5. Change Time Zone"
    echo -e "  6. Change locale"
    echo -e "  8. Config WebDav backup service"
    echo -e "  9. Install SSL/TLS certificates"
    echo -e "  x. Exit\n"$LINE
    echo -en "\t"; read -rsn1 -p "Enter choice -> " key
    case $key in
        1) downloadGit ;;
        2) ./setupServer.sh ;;
        r|R) restartContext ;;
        4) changeHostname ;;
        5) changeTimeZone ;;
        6) changeLocale ;;
#        8) ./configDav.sh ;;
        x) break ;;
        esac
    done
return
}
#  ----------------------------------
function manageWebserver() {
while true; do
    echo -e "\n"$LINE"\n\tManage Docker Nginx web server\n"$LINE 
    echo -e "  1. Download Nginx Docker Image"
    echo -e "  2. Status Nginx Docker"
    echo -e "  5. Restart Nginx Docker"
    echo -e "  9. Backup files & folders"
    echo -e "  x. Exit\n"$LINE
    echo -en "\t"; read -rsn1 -p "Enter choice -> " key
    case $key in
        1) downloadNginx ;;
        2) statusContainer nginx ;;
        5) restartContainer ;;
#        9) ./syncDav.sh ;;
        x) break ;;
        esac
    done
return
}
# --------------------------------------------------------------------------
# Main menu
initialIssues
while true; do
    clear
    echo -e $LINE"\n\tOptions\n"$LINE 
    echo -e "  1. Update server & install packages & services"
    echo -e "  2. Web server config"
    echo -e "  4. Server maintenance: Backup"
    echo -e "  7. Manage Docker Nginx web server"
    echo -e "  9. Other services & apps"
    echo -e "  x. Exit\n"$LINE
    echo -en "\t"; read -rsn1 -p "Enter choice -> " key
    case $key in
        1) updateServer ;;
        2) updateWeb ;;
        7) manageWebserver ;;
        x) break ;;
    esac
done
#
finalIssues
exit
