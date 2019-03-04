#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./context.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
export RELEASE=$(lsb_release -cs)
#
export mainDomain="''"
export mainIP="''"
export mainColor="#BA0020"
#
export appFolder="/app/nginx"
export backupFolder="/app/backup"
export wwwFolder="/var/www"
export errorDir="/var/www/error"
export protectetLocations="/var/www/error /var/www/include"
export errorStyleLocal=false 		
#errorStyleLocal=False for Global, [/var/www/error]  | =True for Local, [www<site>/style dir]
color=('#DC443A' '#98243A' '#11589F' '#715138' '#D69C2F' '#616247' '#898E88' '#2e5090' '#5F4B8B' '#BA0020' '#0E3A53' '#DC443A' '#98243A' '#11589F' '#715138' '#D69C2F' '#616247' '#898E88' '#2e5090' '#5F4B8B')
#
export context=("(domain IP workDir nameSite colorSite subDirIn)"
) 
#
export dockerNginxImage="app2linux/nginx2ssl:latest"
export dockerNginxContainer="nginx"
export SSL=""
export SSLemail=""
export SSLdomains=""
export DAVconfig=""
export verifiedContext=false
export folderCreated=false
