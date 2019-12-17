#!/bin/bash
# This script has been tested on Raspbian 10 Buster image (v. September 2019)
# chmod +x ./setupServer.sh
#  --------------------------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="-----------------------------------------------"
#  ---------------------------------------------------------
RELEASE=$(lsb_release -cs)
#  ---------------------------------------------------------
ffunction installFirewall(){
echo -e "\n"$LINE "\nInstall && config ufw Firewall ... "
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
#  ----------------------------------
function finalissues(){
echo -e "\n\t\tFinal issues...\n"
apt -y autoremove --purge && apt -y clean
return 1
}
#  ---------------------------------------------------------
appUsables=(installFirewall installOther installDocker finalissues)
# apt-get -y update
echo -e "\n Update server & install package ...\n"
for app in ${appUsables[*]} ; do
    $app
    done
#
echo -e $LINE"\n>  Server already uptated\n"$LINE
echo -e "\n\t sudo reboot now\n\n"$LINE
read -rsn1 -p "Press any key to continue > "
#
exit 0
