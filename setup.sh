#!/bin/bash
# This script has been tested on Debian 9 Stretch image
# chmod +x ./setup.sh
# wget https://raw.githubusercontent.com/app4rpi/rpiDocker/master/setup.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="---------------------------------------"
#  ---------------------------------------------------------
function isContinue(){
echo -n "[x] Cancel & break     [c] Continue   > "
while true; do  read -rsn1  input
  case $input in 
	[cC]) break ;;
	[xX]) { echo; exit 0;} ;; 
 esac
done
return 1
}
#  ---------------------------------------------------------
# Initial issues
function initialIsues(){
[ ! -d ./.startup ] && mkdir -p ./.startup
apt autoremove --purge && apt clean
cd ./.startup
}
#  -----------------------------
function finalIssues(){
# final issues
echo -e "\n\t\tFinal issues...\n"
cd ..
}
#  ---------------------------------------------------------
# Update server
function updateServer(){
echo -e 'Update server'
apt update && apt dist-upgrade -y && apt upgrade -y
apt autoremove --purge && apt clean
echo $LINE$LINE
return
}
#  ---------------------------------------------------------
# Update nameservers
function updateNameservers(){
RELEASE=$(lsb_release -cs)
#  ----------------------------------
cat /etc/issue
echo $LINE
echo 'Update system: '$(lsb_release -cs)
file="/etc/resolv.conf"
echo -e "\n DNS servers\n"$LINE$LINE
nameServers=("8.8.8.8" "1.1.1.1" "9.9.9.9" "208.67.222.222" "8.8.4.4" "149.112.112.112" "208.67.220.220")
for name in ${nameServers[*]} ; do
    [[ ! $(sed -n "/^nameserver $name/p;q" $file) ]] && echo 'nameserver '$name >> $file
    done
cat $file
echo $LINE$LINE
return
}
# --------------------------------------------------------------------------
function downloadGit(){
echo -e '\nDownload git files:'
echo -e "\tCopy & overwriting all bash script files\n"$LINE
file=(start.sh context.sh setupServer.sh startup.sh nginxConfig.sh functions.sh)
echo -n "Bash files: "
for ((i=0; i<${#file[@]}; i++)); do
    echo -n '<'${file[i]}'> : '
    wget -q https://raw.githubusercontent.com/app2linux/webDebian/master/${file[i]} -P ./
    chmod +x ./${file[i]}
    done
echo -e "\n"$LINE$LINE
echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
echo
return
}
#  ------------------------------------------------------------------------------------------------------------------
# Main process
#
clear 
echo -e "\nAutomatic install & config & start server and web server.\n"$LINE$LINE
#  -----------------------
configFunctions=(initialIsues updateNameservers updateServer downloadGit ./setupServer.sh finalIssues)
for process in ${configFunctions[*]} ; do
    $process
    done
#  ---------------------------------------------------------
# Modify setup.sh file (this file)
sed -i '8,$d' setup.sh
cat <<'EOF' >> setup.sh
cd .startup
./start.sh
cd ..
exit
EOF
exit
