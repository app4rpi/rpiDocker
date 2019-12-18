#!/bin/bash
# This script has been tested on Raspbian 10 Buster image (v. September 2019)
# chmod +x ./rPiMaintenance.sh
#  --------------------------------------------------------------------------
[[ "$EUID" -ne 0 ]] && { echo "Must be root";   exit; }
LINE="-------------------------------------------------------"
source ./functions.sh
# --------------------------------------------------------------------------
function updateNameservers(){
RELEASE=$(lsb_release -cs)
#  ----------------------------------
echo -e '\n\n'
cat /etc/issue
echo -e $LINE
echo 'Update system: '$(lsb_release -cs)
file="/etc/resolv.conf"
echo -e "\n DNS servers\n"$LINE
nameServers=("8.8.8.8" "1.1.1.1" "9.9.9.9" "208.67.222.222" "8.8.4.4" "149.112.112.112" "208.67.220.220")
for name in ${nameServers[*]} ; do
    if ! grep -q "nameserver $name" $file; then echo 'nameserver '$name >> $file; fi
    done
cat $file
return
}
# --------------------------------------------------------------------------
function downloadGit(){
echo -e '\n'$LINE'\nDownload git files:'
echo -e "\tCopy & overwriting all bash script files except <context.sh>"
echo -e "\tTo modify <context.sh> erase file first\n"$LINE
isOk; val=$?;
[[ $val == 0 ]] && return
file=(start.sh webServerMaintenance.sh webServerStartup.sh webServerConfig.sh rPiMaintenance.sh rpiInstallApps.sh rpiManageStorage.sh dockerMaintenance.sh functions.sh)
echo -n "Bash files: "
for ((i=0; i<${#file[@]}; i++)); do
    echo -n '<'${file[i]}'> : '
    wget -q https://raw.githubusercontent.com/app4rpi/rpiDocker/master/${file[i]} -O ./${file[i]}
    chmod +x ./${file[i]}
    done
[[ ! -f ./context.sh ]] && wget -q https://raw.githubusercontent.com/app4rpi/rpiDocker/master/context.sh -O ./context.sh
echo -e "\n"$LINE$LINE"\n\n\tExit now & restart bash script file \n"
exit 1
}
# --------------------------------------------------------------------------
# 
while true; do
    clear
    echo -e "\n"$LINE"\n\trPi maintenance\n"$LINE 
    echo -e "  1. Start rpi-config"
    echo -e "  2. Update nameservers"
    echo -e "  3. Update server & install uninstalled packages"
    echo -e "  4. Update bash script config files"
    echo -e "  x. Exit\n"$LINE
    echo -en "\t"; read -rsn1 -p "Enter choice -> " key
    case $key in
        1) raspi-config ;;
        2) updateNameservers ;;
        3) ./rpiInstallApps.sh ;;
        4) downloadGit ;;
        x) break ;;
        *) continue ;;
    esac
    echo -en "\n"$LINE"\n\t"; read -rsn1 -p ">> Press key to continue -> " key
done
exit
