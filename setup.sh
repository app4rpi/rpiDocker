#!/bin/bash
# This script has been tested on Raspbian 10 Buster image (v. September 2019)
# sudo chmod +x ./setup.sh
# wget https://raw.githubusercontent.com/app4rpi/rpiDocker/master/setup.sh
#  --------------------------------------------------------------------------
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
cd ./.startup
}
#  -----------------------------
function finalIssues(){
# final issues
echo -e "\n\t\tFinal issues...\n"
apt -y autoremove --purge && apt -y clean
cd ..
}
#  ---------------------------------------------------------
# Update server
function updateServer(){
echo -e 'Update server'
apt update -y && apt dist-upgrade -y && apt upgrade -y
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
    if ! grep -q "nameserver $name" $file; then echo 'nameserver '$name >> $file; fi
    done
cat $file
echo $LINE$LINE
return
}
# --------------------------------------------------------------------------
function downloadGit(){
echo -e '\nDownload git files:'
echo -e "\tCopy & overwriting all bash script files\n"$LINE
file=(start.sh context.sh webServerMaintenance.sh webServerStartup.sh webServerConfig.sh rPiMaintenance.sh rpiInstallApps.sh rpiManageStorage.sh dockerMaintenance.sh functions.sh)
echo -n "Bash files: "
for ((i=0; i<${#file[@]}; i++)); do
    echo -n '<'${file[i]}'> : '
    wget -q https://raw.githubusercontent.com/app4rpi/rpiDocker/master/${file[i]} -O ./${file[i]}
    chmod +x ./${file[i]}
    done
echo -e "\n"$LINE$LINE
echo
return
}
#  ---------------------------------------------------------
function installFirewall(){
echo -e $LINE "\nInstall && config ufw Firewall ... "
[[ $(dpkg --get-selections ufw) ]] && { echo "Already installed";  return 1;}
apt-get install -y ufw
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw status verbose
echo 'fw installed'
echo -e $LINE "\n"
return 1
}
#  ----------------------------------------
function installOther(){
echo -e $LINE "\nInstall git ... "
[[ $(dpkg --get-selections git) ]] && echo "Git Already installed" || apt-get install -y git
echo 'Install davfs2 ... '
[[ $(dpkg --get-selections davfs2) ]] && echo "davfs2 installed" || DEBIAN_FRONTEND=noninteractive apt-get -yq install davfs2
echo 'Install tar ... '
[[ $(dpkg --get-selections tar) ]] && echo "tar installed" || apt-get install -y tar
echo 'Install curl ... '
[[ $(dpkg --get-selections curl) ]] && echo "curl installed" || apt-get install -y curl
return 1
}
#  ----------------------------------
function installDocker(){
echo -e $LINE "\nInstall docker ... "
[[ $(dpkg --get-selections docker-ce) ]] && { echo "Already installed";  return 1;}
curl -fsSL https://get.docker.com | sh
usermod -aG docker $USER
apt-get install -y libffi-dev libssl-dev
apt-get install -y python python-pip
apt-get remove -y python-configparser
systemctl enable docker
systemctl start docker
return 1
}
#  ------------------------------------------------------------------------------------------------------------------
# Main process
#
clear 
echo -e "\nAutomatic install & config & start server and web server.\n"$LINE$LINE
#  -----------------------
configFunctions=(initialIsues updateNameservers updateServer downloadGit installFirewall installOther installDocker finalIssues)
for process in ${configFunctions[*]} ; do
    $process
    done
#  ---------------------------------------------------------
# Modify setup.sh file (this file)
sed -i '9,$d' setup.sh
cat >> setup.sh << EOF
cd .startup
./start.sh
cd ..
exit
EOF
exit
