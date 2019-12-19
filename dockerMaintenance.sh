#!/bin/bash
# This script has been tested on Raspbian 10 Buster image (v. September 2019)
# chmod +x ./dockerMaintenance.sh
#  --------------------------------------------------------------------------
[[ "$EUID" -ne 0 ]] && { echo "Must be root";   exit; }
LINE="-------------------------------------------------------"
source ./functions.sh
# --------------------------------------------------------------------------
function startUtils(){
echo -e '\n\n'$LINE'\nUtilitats: download image and run ... \n'$LINE
dockerImage="app4rpi/utils"
dockerContainer="utils"
if [[ -z $(docker images -q $dockerImage) ]]; then
    echo -e "\tLocal Docker image does not exist.\n\tDownload image from DockerHub...\n"
else 
    echo -e "\n\tLocal Docker image already downloaded.\n\tDelete image first: \n\t>#  docker rmi $dockerImage\n"
fi
docker run -d -t --net host --privileged --name $dockerContainer $dockerImage

echo -e "\n\t WebServer run on port :8008"
echo -e '\t docker exec utils nmap -sP 192.168.43.0/24'
echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
}
# --------------------------------------------------------------------------
function startPortainer(){
echo -e '\n\n'$LINE'\nDocker Portainer: download image and run ... \n'$LINE
dockerImage="portainer/portainer"
if [[ -z $(docker images -q $dockerImage) ]]; then
    echo -e "\tLocal Docker image does not exist.\n\tDownload image from DockerHub...\n"
    docker pull portainer/portainer
docker volume create portainer_data
docker run -d --name portainer --restart=always -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data $dockerImage
else 
    echo -e "\n\tLocal Docker image already downloaded.\n\tDelete image first: \n\n\t>#  docker rmi $dockerImage\n"
fi
echo -e "\n Portainer container run on port :9000\n"
echo -e '\t'$eth0IP:9000
echo -e '\t'$wlan0IP:9000
echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
return
}
# --------------------------------------------------------------------------
function dockerImages(){
    echo -e "\n"$LINE"\n\tDocker images\n"$LINE
SAVEIFS=$IFS;IFS=$'\n'      # Save & Change IFS to new line
llista=($(docker images))
IFS=$SAVEIFS   # Restore IFS
for ((i=0; i<${#llista[@]}; i++)); do echo -e "( "$i" ) > "${llista[i]}; done
return
}
# ---------------------------------
function manageImage(){
opcio=$1
echo $opcio
dockerImages
echo -en "\n"$LINE"\n"; read -rsn1 -p "Image number to $opcio -> " key
image=(${llista[key]})
i=${#image[@]}-1
echo -en "\n\n$opcio Image:" ${image[0]}:${image[1]}" >> " ${image[i]}
isOk;val=$?; [[ $val == 0 ]] && return;
case $opcio in
	Remove) docker rmi ${image[0]}
		echo -en "\nImage removed";;
esac
}
# ---------------------------------
function dockerContainers(){
    echo -en "\n"$LINE"\n\tDocker containers\n"$LINE
SAVEIFS=$IFS;IFS=$'\n'      # Save & Change IFS to new line
llista=($(docker ps -a))
IFS=$SAVEIFS   # Restore IFS
for ((i=0; i<${#llista[@]}; i++)); do echo -en "\n( "$i" ) > "${llista[i]}; done
return
}
# ---------------------------------
function manageContainer(){
opcio=$1
echo $opcio
dockerContainers
echo -en "\n"$LINE"\n"; read -rsn1 -p "Container number to $opcio -> " key
[[ $key<1 || $key>${#llista[@]}-1 ]] && return;
container=(${llista[key]})
i=${#container[@]}-1
echo -en "\n\n$opcio Container ID:" ${container[0]}" >> " ${container[i]}
isOk;val=$?; [[ $val == 0 ]] && return;
case $opcio in
	Stop) docker stop ${container[0]}
		echo -en "\nContainer stoped";;
	Restart) docker restart ${container[0]}
		echo -en "\nContainer restarted";;
	Remove) docker rm ${container[0]}
		echo -en "\nContainer removed";;
	Logs) docker logs ${container[0]}
		echo -en "\nContainer logs";;
	Inspect) docker inspect ${container[0]}
		echo -en "\nContainer logs";;

esac
}

# --------------------------------------------------------------------------
#
echo -e "\n\n"
while true; do
    clear
    echo -e "\n"$LINE"\n\tDocker: maintenance & utilities\n"$LINE 
    echo -e "  1. Docker containers"
    echo -e "  2. Stop container"
    echo -e "  3. Start / restart container"
    echo -e "  4. Remove container"
    echo -e "  5. View Container Logs"
    echo -e "  6. Inspect Container"
    echo
    echo -e "  7. Docker images"
    echo -e "  8. Remove image"
    echo
    echo -e "  u. Install Utilities "
    echo -e "  x. Exit"
    echo -en $LINE"\n\t"; read -rsn1 -p "Enter choice -> " key
    case $key in
        1) dockerContainers ;;
	2) manageContainer Stop;;
	3) manageContainer Restart;;
	4) manageContainer Remove;;
	5) manageContainer Logs;;
	6) manageContainer Inspect;;
        7) dockerImages ;;
	8) manageImage Remove ;;
        9) startPortainer ;;
        u) startUtils ;;
        x) break ;;
        *) continue ;;
    esac
    echo -en "\n"$LINE"\n\t"; read -rsn1 -p "Press key to continue -> " key
done
echo -e "\n\n"
exit
