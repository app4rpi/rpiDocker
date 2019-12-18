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
dockerMinidlna=dockerMinidlna
function minidlnaDockerCreate(){
localDir='../'$dockerMinidlna
echo -e '\n\n'
if [ ! -d "$localDir" ]; then
    mkdir "$localDir"
    chmod 775 "$localDir"
    chown -R pi:pi "$localDir"
    echo -e '... Crea dir: '$localDir
    fi
file=$localDir/Dockerfile
if [[ -f $file ]]; then
	echo "[ $dockerMinidlna/Dockerfile ] already exist"
else
fileContent="FROM arm32v6/alpine 
\nMAINTAINER app4rpi <app4rpi@outlook.com> 
\nRUN apk add --no-cache bash minidlna && rm -rf /var/cache/apk/* \nADD minidlna.conf /etc/minidlna.conf 
\nRUN [ \$(getent group minidlna) ] || addgroup minidlna && [ \$(getent passwd minidlna) ] || adduser -G minidlna -S minidlna 
\nRUN mkdir -p /media /var/log /media/video /media/music /media/img /media/db && chown minidlna:minidlna /media /var/log /media/video /media/music /media/img /media/db 
\nEXPOSE 1900/udp \nCOPY entrypoint.sh /entrypoint.sh \nRUN chmod +x /entrypoint.sh \nENTRYPOINT [\"/entrypoint.sh\"]"
    echo -e $fileContent > $file
	echo "[ $dockerMinidlna/Dockerfile ] created"
fi

file=$localDir/entrypoint.sh
if [[ -f $file ]]; then
	echo "[ $dockerMinidlna/entrypoint.sh ] already exist"
else
fileContent="#!/bin/bash\nset -e \nfor VAR in \`env\`; do\n\tif [[ \$VAR =~ ^MINIDLNA_ ]]; then
\n\t\tminidlna_name=\`echo \"\$VAR\" | sed -r \"s/MINIDLNA_(.*)=.*/\1/g\" | tr \'[:upper:]\' \'[:lower:]\'\`
\n\t\tminidlna_value=\`echo \"\$VAR\" | sed -r \"s/.*=(.*)/\1/g\"\`
\n\t\techo \"\${minidlna_name}=\${minidlna_value}\" >> /etc/minidlna.conf\n\tfi \ndone
\n [ -f /var/run/minidlna/minidlna.pid ] && rm -f /var/run/minidlna/minidlna.pid\nexec minidlnad -d \$@"
echo -e $fileContent > $file
echo "[ $dockerMinidlna/entrypoint.sh ] created"
fi
file=$localDir/minidlna.conf
if [[ -f $file ]]; then
	echo "[ $dockerMinidlna/ ] already exist"
else
fileContent="# minidlna file config
\n#uuid= \n#friendly_name=rPi2+ \nport=8200 \ndb_dir=/media/db \nlog_dir=/var/log \nmedia_dir=A,/media/music 
\nmedia_dir=V,/media/video \nalbum_art_names=Cover.jpg/cover.jpg/Album.jpg/album.jpg/Folder.jpg/folder.jpg 
\ninotify=yes \nenable_tivo=no \nstrict_dlna=no \nnotify_interval=900 \nserial=1001001 \nmodel_number=1 
\n#minissdpdsocket=/var/run/minissdpd.sock \n#root_container=. \nwide_links=yes"
echo -e $fileContent > $file
echo "[ $dockerMinidlna/minidlna.conf ] created"
fi
mkdir -p /app/minidlna/{musica,video,img}
sudo chown -R pi:pi /app/minidlna $localDir
echo -e $LINE'\n'; read -rsn1 -p "Press key to continue -> " key;
return
}
# ----------------------------------
function makeMinidlnaImage(){
cd ../$dockerMinidlna
echo
ls
docker build --rm -t minidlna .
docker volume create minidlna
 echo -e $LINE'\n'; read -rsn1 -p "Press key to continue -> " key;
return
cd -
}
# --------------------------------------------------------------------------
dockerUtils=dockerUtils
function utilsDockerCreate(){
localDir='../'$dockerUtils
echo -e '\n\n'
if [ ! -d "$localDir" ]; then
    mkdir "$localDir"
    chmod 775 "$localDir"
    chown -R pi:pi "$localDir"
    echo -e '... Crea dir: '$localDir
    fi
file=$localDirDockerfile
if [[ -f $file ]]; then
	echo "[ $file ] already exist"
else
fileContent='FROM arm32v6/alpine\nRUN apk update\nRUN apk add busybox busybox-extras nmap\nRUN rm -rf /var/cache/apk/*
\nRUN mkdir -p /www /conf\nCOPY "index.html" /www\nRUN touch /etc/httpd.conf\nWORKDIR /www
\nEXPOSE 8008\nADD entrypoint.sh /entrypoint.sh\nRUN chmod +x /entrypoint.sh
\n# CMD [ "/usr/sbin/httpd", "-f", "-h", "/www", "-p", "8008", "-c", "/etc/httpd.conf" ]\nENTRYPOINT [ "sh","/entrypoint.sh" ]'
    echo -e $fileContent > $file
	echo "[ $file ] created"
fi

file=$localDirentrypoint.sh
if [[ -f $file ]]; then
	echo "[ $file ] already exist"
else
fileContent='#!/bin/bash\n#\n/usr/sbin/httpd -f -h /www -p 8008 -c /etc/httpd.conf
\necho "End of file"\nsleep infinity &\nchild=$!\nwait "$child"'
echo -e $fileContent > $file
echo "[ $file ] created"
fi
file=$localDirindex.html
if [[ -f $file ]]; then
	echo "[ $file ] already exist"
else
fileContent='<!DOCTYPE html>\n<html lang="es-ES"><head><meta charset="utf-8" />
\n<style>body{background:#898E88;font:bold normal 4em "Arial"}\nh1{color:#ded;margin-top:21%;text-align:center;}</style>
\n</head><body><h1>rPi</h1></body></html>'
echo -e $fileContent > $file
echo "[ $file ] created"
fi
mkdir -p /app/html/
sudo chown -R pi:pi /app/html $localDir
echo -e $LINE'\n'; read -rsn1 -p "Press key to continue -> " key;
return
}
# --------------------------------------------------------------------------
#
echo -e "\n\n"
while true; do
    clear
    echo -e "\n"$LINE"\n\tDocker: maintenance & utilities\n"$LINE 
    echo -e "  1. Docker Start"
    echo -e "  2. Docker Stop"
    echo -e "  3. View Docker Logs"
    echo -e "Docker images && docker ps -a"
    echo -e "  u. Install Utilities "
    echo -e "  x. Exit\n"$LINE
    echo -en "\t"; read -rsn1 -p "Enter choice -> " key
    case $key in
        9) startPortainer ;;
        u) startUtils ;;
        x) break ;;
        *) continue ;;
    esac
    echo -en "\n"$LINE"\n\t"; read -rsn1 -p "Press key to continue -> " key
done
echo -e "\n\n"
exit
