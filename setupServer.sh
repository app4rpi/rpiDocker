#!/bin/bash
# This script has been tested on Debian 9 Stretch image
# chmod +x ./setupServer.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="-----------------------------------------------"
#  ---------------------------------------------------------
RELEASE=$(lsb_release -cs)
#  ---------------------------------------------------------
function installFirewall(){
echo -e $LINE "\nInstall && config ufw Firewall ... "
[[ $(dpkg --get-selections ufw) ]] && { echo "Already installed";  return 1;}
apt-get install -y ufw
ufw enable
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
[[ $(dpkg --get-selections davfs2) ]] && echo "davfs2 installed" || apt-get -y install davfs2
echo 'Install tar ... '
[[ $(dpkg --get-selections tar) ]] && echo "tar installed" || apt-get -y install tar
echo 'Install curl ... '
[[ $(dpkg --get-selections curl) ]] && echo "curl installed" || apt-get -y install curl
return 1
}
#  ----------------------------------
function installDocker(){
echo -e $LINE "\nInstall docker ... "
[[ $(dpkg --get-selections docker-ce) ]] && { echo "Already installed";  return 1;}

apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

#add-apt-repository "deb https://download.docker.com/linux/raspbian $(lsb_release -cs) stable"
echo "deb [arch=armhf] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
     $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list
apt update
# curl -sSL https://get.docker.com | sh
# version 18.09 not work on arm6
apt-get install -y docker-ce=18.06.3~ce~3-0~raspbian containerd.io

#curl -sSL https://get.docker.com | sh

    ## Alternativament
    # curl -fsSL get.docker.com -o get-docker.sh
    # sudo bash get-docker.sh

systemctl enable docker
systemctl start docker
usermod -aG docker $USER
[[ $SUDO_USER ]] && usermod -aG docker $SUDO_USER || usermod -aG docker $USER
apt autoremove --purge && apt clean



return 1
}
#  ----------------------------------
function finalissues(){
echo 'Final issues ... '
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
read -rsn1 -p "Press any key to continue > "
#
exit 0
