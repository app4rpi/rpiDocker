#!/bin/bash
# This script has been tested on Raspbian 10 Buster image (v. September 2019)
# chmod +x ./webServerMaintenance.sh
#  --------------------------------------------------------------------------
[[ "$EUID" -ne 0 ]] && { echo "Must be root";   exit; }
LINE="-------------------------------------------------------"
source ./functions.sh
source ./context.sh
# --------------------------------------------------------------------------
function downloadNginx() {
echo -e '\n\n'$LINE"\nDownload Nginx Docker Image: [ "${dockerNginxImage}' ]'
echo -e $LINE
if [[ -z $(docker images -q $dockerNginxImage) ]]; then
    echo -e "\tLocal Docker image does not exist.\n\tDownload image from DockerHub...\n"
    docker pull ${dockerNginxImage}
    [[ -z $(docker images -q $dockerNginxImage) ]] && { echo -e "\n\tUnavailable docker image. Trial start docker finished.\n\tUse console options to start docker nginx image"; return 0;}
    echo -e "\n[ "$dockerImage" ]  already downloaded ... "
else 
    echo -e "\n\tLocal Docker image already downloaded.\n\tDelete image first: \n\n\t>#  docker rmi $dockerNginxImage\n"
fi
echo -e $LINE
return
}
#  ----------------------------------
function restartContainer() {
echo -e '\n\n'$LINE$LINE"\n\tRestart Docker Container: [ "${dockerNginxContainer}' ]'
echo -e $LINE
if [[ -n "$(docker ps -q -f status=running -f name=^/${dockerNginxContainer}$)" ]]; then
    echo -e "\t[ ${dockerNginxContainer} ] container exists.\n\tStop & delete container"
    docker stop ${dockerNginxContainer} && docker rm ${dockerNginxContainer}
fi
echo -e "\nStarting  container:[ ${dockerNginxContainer} ] Image:[${dockerNginxImage}] config:[${appFolder}] www:[${wwwFolder}]"
docker run -d --restart always --net=host -v ${wwwFolder}:/var/www/ -v ${appFolder}:/etc/nginx/conf.d/ --name ${dockerNginxContainer} ${dockerNginxImage}
echo -e $LINE$LINE
return
}
# --------------------------------------------------------------------------
function restartContext(){
echo -e '\n'$LINE'\nDelete <context.sh> config files,'
echo -e "Restore from file or download new file from GitUb\n"$LINE
isCorrect; val=$?;
[[ $val == 0 ]] && return
mv ./context.sh ./context.old
[[ -f context.bak ]] && cp ./context.bak ./context.sh || { wget https://raw.githubusercontent.com/app4rpi/rpiDocker/master/context.sh -P ./; chmod +x ./context.sh; }
echo -e "\tFile <context.sh> restored."
return 1
}
#  ----------------------------------
function viewMain(){
echo -e "\n"$LINE$LINE"\n\nEnvironamental variables.\n"$LINE$LINE
echo -e "Main domain:[$mainDomain]   IP:[$mainIP]\n"$LINE
echo -en "Folders:  App:[$appFolder]  Backup:[$backupFolder]  www:[$wwwFolder]  Error dir:[$errorDir]  "
echo -en "Error style: "
[[ ${errorStyleLocal} = true ]] && echo 'Local' || echo 'Global'
}
#  ----------------------------------
function viewDomains(){
echo -e $LINE$LINE"\n[domain IP workDir nameSite colorSite subDirIn]\n"$LINE
title=(${context[0]:1:-1})
for ((i=1; i<${#context[@]}; i++));  do
    data=(${context[i]:1:-1})
    [[ -z $data ]] && break
    for ((j=0; j<${#data[@]}; j++)); do
        echo -n "["${data[j]}']  '
        done
    echo
    done
echo $LINE$LINE
}
#  ----------------------------------
function viewContext(){
source ./context.sh
viewMain
echo -e "SSL/TLS: [$SSL]   email:[$SSLemail]   Domains:[$SSLdomains]"
temp=($DAVconfig)
echo -e "WebDav:  Server:[${temp[0]}]   email:[${temp[2]}]   Pw:[${temp[3]}]"
viewDomains
return 1
}
# --------------------------------------------------------------------------
function askDomain(){
echo -e "\n\n"$LINE$LINE"\nWeb config options in line orders:\n(all in the same line):\n"$LINE
echo -e "    <nameMainDomain>.<extension> <subdomain> ...  [NOIP] [ERRORLOCAL]\n"
echo -e "    [x]  Cancel & Return\n"$LINE$LINE 
}
# --------------------------------------------------------------------------
function addSite(){
data=(${@});
[[ -z $data ]] && return
thisSite="server {\nlisten 80"
[[ ${data[0]} = ${mainDomain} ]] && thisSite+=" default_server"
thisSite+=";\nlisten [::]:80;\nserver_name "
[[ -n ${data[0]:1:-1} ]] && thisSite+=${data[0]} || thisSite+="_"
thisSite+=";\ncharset utf-8;\nroot ${wwwFolder}/${data[2]};\nindex index.html index.htm;\n"
thisSite+="# location\nlocation /include { alias "${wwwFolder}/include"; autoindex off; }\n"
thisSite+="include /etc/nginx/errors.conf;\ninclude /etc/nginx/drop.conf;\n}"
echo -e $thisSite > ${appFolder}/${data[3]}.conf
if [ ! -z ${data[5]:1:-1} ]; then 
    line2add="location /"${data[0]%%.*}" { alias "${wwwFolder}/${data[2]}"; autoindex off; }"
    sed -i "/# location/i ${line2add}" ${appFolder}/${data[5]}.conf
    fi
chown -R pi:pi ${appFolder}/${data[3]}.conf
return
}
# --------------------------------------------------------------------------
function addW3(){
data=(${@});
[[ -z $data ]] && return
[[ ! -d ${wwwFolder}/${data[2]} ]] && mkdir -p ${wwwFolder}/${data[2]} ${wwwFolder}/${data[2]}/css ${wwwFolder}/${data[2]}/scripts ${wwwFolder}/${data[2]}/img
thisSite='<!DOCTYPE html>\n<html lang="es-ES"><head><meta charset="utf-8" />\n<style>body{background:'
[[ -n ${data[4]:1:-1} ]] && thisSite+=${data[4]:1:-1} || thisSite+=${mainColor}
thisSite+=';font:bold normal 4em "Arial"}\nh1{color:#ded;margin-top:21%;text-align:center;}</style>\n'
thisSite+="</head><body><h1>"
[[ -n ${data[0]:1:-1} ]] && thisSite+=${data[0]} || thisSite+='Welcome to nginx'
thisSite+="</h1></body></html>"
echo -e $thisSite > ${wwwFolder}/${data[2]}/index.html
chown -R pi:pi ${wwwFolder}
return
}
# --------------------------------------------------------------------------
function addDomain(){
domain=$1
random=$(date +%1N);
[[ ${domain} == *${mainDomain} ]] && { subDomain=${domain%$mainDomain}; subSite=' mainSite'; } || { subDomain=${domain}; subSite=''; }
subDomain=${subDomain//.}
temp='"('${domain}" '' "${subDomain}" "${subDomain}Site" '"${color[$random]}"'"${subSite}')"'
echo -n ${temp}
isOk; ok=$?;
if [ $ok ]; then
    sed -i "/^)/i${temp}" context.sh
    addSite ${temp:2:-2}
    addW3 ${temp:2:-2}
    echo "Added domain & nginx config"
else
    echo "Discarded add domain"
fi
return
}
# --------------------------------------------------------------------------
function delDomain(){
temp=$(sed -e "/^\"(${domain} / !d" context.sh)
temp=( ${temp:2:-2} )
isOk; ok=$?;
if [ $ok ]; then
    sed -i "s/\"(${domain} .*$//;/^$/d" context.sh
    rm -f $appFolder/${temp[3]}.conf
    [[ ! ${temp[5]} ]] && rm -rf $wwwFolder/${temp[2]}
    echo "Deleted domain & nginx config"
else
    echo "Discard delete domain"
fi
return
}
# --------------------------------------------------------------------------
function manageDomain(){
source ./context.sh
option=$1
echo
echo -n ' > '
[[ $verifiedContext = false ]] && option='all' || { echo -e "\n\n"$LINE$LINE"\n\nDomains:"; viewDomains; }
case $option in
    all) echo -e "\nConfig Main domain:\n"$LINE"\n    [NOIP] [ERRORLOCAL] <nameMainDomain>.<extension> <subdomain> <subdomain> <...>\n" ;;
    web) echo -e "\nConfig Main domain:\n"$LINE"\n    [...] \n" ;;
    add) echo -e "\nAdd domains:\n"$LINE"\n    [<subdomain>]<nameMainDomain>.<extension> ...\n" ;;
    del) echo -e "\nDelete domains:\n"$LINE"\n    [<subdomain>]<nameMainDomain>.<extension> ...\n" ;;
    esac
echo -e "    [x]  Cancel & Return\n"$LINE$LINE 
read -p "   > " lineOrder
if [[ $lineOrder =~ ^(x|X) || ! $lineOrder ]]; then 
    echo; return;
fi
if [ $option = all ]; then
    echo -e "\n"$LINE$LINE"\n\nInitial configuration file"
    ./webServerStartup.sh $lineOrder; 
    ./webServerConfig.sh;
    echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
    return
fi
if [ $option = web ]; then
    echo -e "\n"$LINE$LINE"\n\nInitial configuration file"
    ./webServerConfig.sh;
    echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
    return
fi
lineOrder=($lineOrder)
echo -en $LINE$LINE"\n"
[[ $option = add ]] && echo -n "Add" || echo -n "Delete"
echo -n " domains >  "
for domain in ${lineOrder[*]}; do
    echo -n "[ "$domain" ] "
    done
echo -e "\n"
isCorrect
valor=$?; [[ "${valor}" == 0 ]] && { echo; return; }
echo -e "\n"$LINE$LINE"\nDomains:\n"$LINE
for domain in ${lineOrder[*]}; do
    echo -n "[ "$domain" ] "
    [[ ! ${domain} = *"."* ]] && { echo "> It's not a domain!"; continue; }
    [[ ${domain} = $mainDomain ]] && { echo "> It's main domain!"; continue; }
    if [ $option = add ]; then
        [[ ${context[@]} = *"(${domain} "* ]] && { echo "> Domain already exist!"; continue; }
        addDomain ${domain}  
    else
        [[ ${context[@]} != *"(${domain} "* ]] && { echo "> Non-existent domain"; continue; }
        delDomain ${domain}  
    fi
    done
return
}
# --------------------------------------------------------------------------
function deleteDomain(){
echo -e "\n\n"$LINE$LINE"\n\nDomains:"
viewDomains
echo -e "\nDelete domains:\n"$LINE
echo -e "    [<subdomain>]<nameMainDomain>.<extension> ...\n"
echo -e "    [x]  Cancel & Return\n"$LINE$LINE 
read -p "   > " lineOrder
if [[ $lineOrder =~ ^(x|X) || ! $lineOrder ]]; then 
    echo; return;
fi
lineOrder=($lineOrder) 
echo -en $LINE$LINE"\nDelete domains >  "
for domain in ${lineOrder[*]}; do
    echo -n "[ "$domain" ] "
    done
echo -e "\n"
isCorrect
valor=$?; [[ "${valor}" == 0 ]] && { echo; return; }
echo -e "\n"$LINE$LINE"\nDomains:\n"$LINE
for domain in ${lineOrder[*]}; do
    echo -n "[ "$domain" ] "
    [[ ! ${domain} = *"."* ]] && { echo "> It's not a domain!"; continue; }
    [[ ${domain} = $mainDomain ]] && { echo "> Unable to delete: It's main domain!"; continue; }
    [[ ${context[@]} != *"(${domain} "* ]] && { echo "> Non-existent domain"; continue; }
    echo "Deleted domain & nginx config"
    done
return
}
# --------------------------------------------------------------------------
function verifyConfig(){
source ./context.sh
echo -e '\n\n\n'$LINE"\n\tVerify configuration >  "
echo -e $LINE
echo -e "Verify <context.sh> files: \n"$LINE
[[ $verifiedContext = false ]] && { manageDomain all; return; }
[[ $folderCreated = false ]] && { manageDomain web; return; }
for ((i=1; i<${#context[@]}; i++));  do
    site=(${context[i]:1:-1})
    [[ -z $site ]] && break
    echo -en '[ '${site[3]}' ]  '
    if [ -f $appFolder/${site[3]}.conf ]; then
        echo -n "<config file> is OK  -  "
    else
        echo -n 'Unavailable config: Create it '
        isOk; ok=$?;
        if [ $ok ]; then
            addSite ${context[i]:1:-1}
            echo -n " > Added nginx config"
        else
            echo -n " > Discarded config"
        fi
    fi
    if [ -d $wwwFolder/${site[2]} ]; then
        echo "<web dir> is OK "
    else
        echo -n 'Unavailable web dir. Create it?  '
        isOk; ok=$?;
        if [ $ok ]; then
            addW3 ${context[i]:1:-1}
            echo -n " > Added web dir & files"
        else
            echo -n " > Discarded"
        fi
    fi
    done
echo -e '\n'$LINE"\n\nVerify nginx config dir: $appFolder\n"$LINE
arr=( "${appFolder}"/*.conf )
for f in "${arr[@]}"; do
site=${f#"$appFolder"}
echo -en "[ ${site:1} ]    >  "
if [[ ${context[@]} == *" ${site:1:-5} "* ]]; then
echo "Ok! : config site at <context.sh>"
elif  [[ ${site} == "/default.conf" ]]; then
echo "Protected config site"
else
echo -en "Delete unknown config site"
        isOk; ok=$?;
        if [ $ok = 1 ]; then
rm -f ${f}
            echo " > Deleted files"
        else
            echo " > Discarded"
        fi
fi
done
echo -e $LINE"\n\nVerify web folder: $wwwFolder\n"$LINE
arr=( "${wwwFolder}"/**/ )
for f in "${arr[@]}"; do
site=${f#"$wwwFolder"}
echo -en "[ ${site:1:-1} ]    >  "
if [[ ${context[@]} == *" ${site:1:-1} "* ]]; then
echo "Ok! : web folder at <context.sh>"
elif  [[ ${protectetLocations} == *"${f:0:-1}"* ]]; then
echo "Protected web folder"
else
echo -en "Delete orphan www folder"
        isOk; ok=$?;
        if [ $ok = 1 ]; then
rm -rf ${f} 
            echo " > Deleted files & folder"
        else
            echo " > Discarded"
        fi
fi
done
return
}
#  ----------------------------------
#  no implementat
function includeFolder(){
echo 'Create include folder ... '
[[ ! -d ${wwwFolder}/include ]] && mkdir -p ${wwwFolder}/include
[[ ! -f ${wwwFolder}/include/jquery.min.js ]] && wget -O ${wwwFolder}/include/jquery.min.js https://code.jquery.com/jquery-3.4.1.min.js 
#
}
# --------------------------------------------------------------------------
# 
while true; do
    clear
    echo -e "\n"$LINE"\n\tWeb server Maintenance\n"$LINE 
    echo -e "  1. Download Nginx Docker Image"
    echo -e "  2. Status Nginx Docker"
    echo -e "  3. Start | Restart Nginx Docker"
    echo -e $LINE
    echo -e "  5. View <context.sh> config files"
    echo -e "  6. Add domain & config files"
    echo -e "  7. Delete domains & config files"
    echo -e "  8. Verify config files & web structure"
    echo -e $LINE
    echo -e "  r. Restart <context.sh> config file"
    echo -e "  b. Backup files & folders"
    echo -e "  x. Exit"
    echo -en $LINE"\n\t"; read -rsn1 -p "Enter choice -> " key
    case $key in
        1) downloadNginx ;;
        2) statusContainer nginx ;;
        3) restartContainer ;;
        5) viewContext ;;
        6) manageDomain add ;;
        7) manageDomain del ;;
        8) verifyConfig ;;
        r|R) restartContext ;;
#        b|B) ./syncDav.sh ;;
        x) break ;;
        *) continue ;;
    esac
    echo -en "\n"$LINE"\n\t"; read -rsn1 -p "Press key to continue -> " key
done
clear
exit
