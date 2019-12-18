#!/bin/bash
# This script has been tested on Raspbian 10 Buster image (v. September 2019)
# sudo chmod +x ./setup.min.sh
# wget https://raw.githubusercontent.com/app4rpi/rpiDocker/master/setup.min.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="---------------------------------------"
#  ---------------------------------------------------------
RELEASE=$(lsb_release -cs)
#  ----------------------------------
[ ! -d ./.startup ] && mkdir -p ./.startup
cd ./.startup
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
#
echo -e '\n'$LINE'\nDownload git files:'
echo -e "\tCopy & overwriting all bash script files except <context.sh>"
echo -e "\tTo modify <context.sh> erase file first\n"$LINE
[[ $val == 0 ]] && return
file=(start.sh webServerMaintenance.sh webServerStartup.sh webServerConfig.sh rPiMaintenance.sh rpiInstallApps.sh rpiManageStorage.sh functions.sh)
echo -n "Bash files: "
for ((i=0; i<${#file[@]}; i++)); do
    echo -n '<'${file[i]}'> : '
    wget -q https://raw.githubusercontent.com/app4rpi/rpiDocker/master/${file[i]} -O ./${file[i]}
    chmod +x ./${file[i]}
    done
[[ ! -f ./context.sh ]] && wget -q https://raw.githubusercontent.com/app4rpi/rpiDocker/master/context.sh -O ./context.sh
echo -e "\n"$LINE$LINE"\n\n\tExit now & restart bash script file \n\n"
echo -en "\n"$LINE"\n\t"; read -rsn1 -p "Press key to continue -> " key
./start.sh
cd ..
#  ---------------------------------------------------------
# Modify setup.min.sh file (this file)
sed -i '9,$d' setup.min.sh
cat >> setup.min.sh << EOF
cd .startup
./start.sh
cd ..
exit
EOF
[[ -f ./setup.sh ]] && mv ./setup.sh ./setup.old
mv setup.min.sh setup.sh
chmod +x ./setup.sh
exit
