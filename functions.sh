#!/bin/bash
# This script has been tested on Raspbian 10 Buster image (v. September 2019)
# chmod +x ./functions.sh
#  --------------------------------------------------------------------------
function isCorrect(){
while true; do  echo -en "\t"
    read -r -p "Are all correct & continue? [Y/n] " input
    case $input in 
        [cC][yY][eE][sS]|[sS][iI]|[yYsS]) return 1 ;;
        [xX][nN][oO]|[nN]) return 0 ;; 
        *) echo -en  "\tInvalid input...  ->   " ;;
        esac
    done
return 1
}
#  ----------------------------------
function isOk(){
echo -en "  ::  It's OK?  >  "; 
while IFS= read -rsn1 key; do
    [[ $key =~ ^[YySs]$ ]] && return 1
    [[ $key =~ ^[Nn]$ ]] && return 0
    done
return 1
}
# --------------------------------------------------------------------------
function unableFunction() {
echo -e '\n\n'$LINE"\n\t Unable function"
return 1
}
# --------------------------------------------------------------------------
function statusContainer() {
temp=$1
echo -e '\n\n'$LINE"\n\t Docker Container Status"
echo -e $LINE
docker inspect ${temp}
echo -e $LINE
docker logs ${temp}
return
}
# --------------------------------------------------------------------------
