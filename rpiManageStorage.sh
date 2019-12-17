#!/bin/bash
# This script has been tested on Raspbian 10 Buster image (v. September 2019)
# chmod +x ./manageStorage.sh
# Usage: sudo bash manageStorage.sh [-h -help] [-l -list] [-mount] [-umount] [-reg] [-del]
#  --------------------------------------------------------------------------
[[ "$EUID" -ne 0 ]] && { echo "Must be root";   exit; }
LINE="-------------------------------------------------------"
# --------------------------------------------------------------------------
mapfile -t deviceList < <(blkid | egrep '(s|h)d[a-z]')
mapfile -t mountedList < <(df | egrep '(s|h)d[a-z]')
mapfile -t fstabList < <(cat /etc/fstab | grep '^UUID\| UUID')
mountDir="/media"
# --------------------------------------------------------------------------
function listDevices(){
    echo -e $LINE"\n  -- >  Connecteted devices:"
    for element in "${deviceList[@]}"; do echo "dev: " ${element}; done
    echo -e $LINE"\n  -- >  Mounted devices:"
    for element in "${mountedList[@]}"; do echo "mnt: " ${element}; done
    echo -e $LINE"\n  -- >  Registered devices:"
    for element in "${fstabList[@]}"; do echo "fst: " ${element}; done
    echo -e $LINE
    return 0
}
# -------------------------------
function listOptions(){
    echo -e 'Script options:\n'
    echo -e '  MOUNT DISK:\tmount sd<XX>[+<insertionDir>]  '
    echo -e '  UMOUNT DISK:\tumount sd<XX> .or. umount=<dir2mount>>' 
    echo -e '  ADD FSTAB:\tadd sd<XX> <insertionDir> [<auto | noauto>]'
    echo -e '  DEL FSTAB:\tdel sd<XX> .or. del <dir2mount>'
    echo -e '\nDirectory to mount units -> ' $mountDir
    echo -e $LINE  
}
# -------------------------------
function creaDir(){
    if [ -d "$1" ]; then return 0; fi
    mkdir "$1"
    chmod 775 "$1"
    chown -R pi:pi "$1"
    echo 'Crea dir: '$1
    return 0
}
# -------------------------------
function mountUnit(){
    [[ $# == 0 ]] && { echo 'Indicate some device to mount'; return; }
    mysd="${1}"; mysd=( ${mysd//+/ } );
    [[ ! "${deviceList[@]}"  =~ /dev/"${mysd[0]}" ]] && { echo "Unable to mount "${mysd[0]}; return 1;}
    [[ "${mountedList[@]}"  =~ /dev/"${mysd[0]}" ]] && { echo "Unit already mounted "${mysd[0]}; return 1;}
    for valor in "${deviceList[@]}"; do
        [[ "${valor}"  =~ "${mysd[0]}" ]] && {
            device=( ${valor} )
            for opcio in "${device[@]}" ; do
                [[ "${opcio:0:5}" == "UUID=" ]] && { uuid=${opcio:6:-1}; }
                [[ "${opcio:0:5}" == "/dev/" ]] && { dispositiu=${opcio:5:4}; }
            done
        break;
        }
    done
    if [[ "${fstabList[@]}"  =~ "${uuid}" ]]; then mount /dev/"${dispositiu}"
        elif [ -z "${mysd[1]}" ]; then { echo 'Please, indicate the insertion dir ...'; return 1;}
        else
        creaDir /media/"${mysd[1]}"
        mount /dev/"${dispositiu}" /media/"${mysd[1]}" 
    fi
    echo "Mounted device "$dispositiu
    return 0
}
# -------------------------------
function umountUnit(){
    [[ "${mountedList[@]}"  =~ /dev/"${1}" ]] && { umount /dev/"${1}"; echo "${1}" umounted; return 0;}
    [[ "${mountedList[@]}"  =~ /media/"${1}" ]] && { umount /media/"${1}"; echo "${1}" umounted; return 0;}
    echo /dev/"${1}" .and. /media/"${1}" not exist; echo Indicate correct device    
    return 1
}
# -------------------------------
function regUnit(){
    mysd="${1}"; mysd=( ${mysd//+/ } )
    sd='';point='';auto='';
    for valor in ${mysd[*]} ; do
        [[ $valor  == "auto" || $valor  == "noauto" ]] && { auto=$valor; continue; }
        [[ ${valor:0:4}  == "sd"[a-m][0-9] ]] && sd=$valor || point=$valor   
        done
    [ -z "${sd}" ] && { echo 'Please, indicate some device ...'; return 1;}
    [ -z "${point}" ] && { echo 'Please, indicate the insertion dir ...'; return 1;}
    [ -z "${auto}" ] && auto='auto'
    [[ "${fstabList[@]}"  =~ "${point}" ]] && { echo 'Already assigned the insertion dir ...'; return 1;}
    device=''
    for valor in "${deviceList[@]}" ; do
        [[ "${valor}" =~ /dev/"${sd}" ]] && { device=$valor; break; }
    done
    [ -z "${device}" ] && { echo 'Device '${sd}' not connected ...'; return 1;}
    device=( ${device} )
    for valor in "${device[@]}" ; do
        [[ "${valor:0:5}" == "UUID=" ]] && { uuid=${valor:6:-1}; }
        [[ "${valor:0:5}" == "TYPE=" ]] && { type=${valor:6:-1}; }
    done
    [[ "${fstabList[@]}"  =~ "${uuid}" ]] && { echo 'Device '$uuid' already registered in fstab  ...'; return 1;}
    creaDir $mountDir'/'${point}
    echo "UUID add  >"${uuid}' : /media/'${point}' : '${type}; 
    echo "UUID="${uuid}" /media/"${point}' '${type}' nofail,noatime,'${auto}',users,rw,uid=1000,gid=100,umask=0002 0 0' | tee -a /etc/fstab
    return
}
# -------------------------------
function delUnit(){
echo 'Erase register fstab -> '"${1}"
    [ -z "${1}" ] && { echo 'Please, indicate the insertion dir ...'; return 1;}
    [[ ! "${fstabList[@]}"  =~ /media/"${1}" ]] && { echo 'Insertion dir not assigned...'; return 1;}
sed -i "/"${1}"/d" /etc/fstab
    return
}
# --------------------------------------------------------------------------
function askOption(){
echo -e "Indicate option with args (all in the same line):"
echo -e "    <option>=<arg1> [<arg2>]"
echo -e "    [x]  Cancel & Return\n"$LINE 
}

# --------------------------------------------------------------------------
function test(){
echo "${1}"
	read -rsn1 -p "Press key to continue -> " key;
}
# --------------------------------------------------------------------------
#
myArgs=( "$@" )

clear
echo -e "\t\tDEVICE MANAGER" 
listDevices;listOptions;askOption;
read -p "   > " lineOrder
[[ $lineOrder =~ ^(x|X) || ! $lineOrder ]] && { echo; exit; }
echo -e $LINE
[[ $lineOrder != *" "* ]] && { echo -en "\nIndicate option with parameters\n\t";
	read -rsn1 -p "Press key to continue -> " key; echo; exit; }
case "${lineOrder%% *}" in
     mount) mountUnit "${lineOrder#* }" ;;
     umount) umountUnit "${lineOrder#* }" ;;
     add) regUnit "${lineOrder#* }" ;;
     del) delUnit "${lineOrder#* }" ;;
     *) echo -e '\nIncorrect option [ '"${lineOrder%% *}"' ].' ;;
esac    
echo be
read -rsn1 -p "Press key to continue -> " key; echo; 
exit

if [ -z "${myArgs[0]}" ]; then listDevices;listOptions; echo -e "Indicate option"; exit 0; fi
for option in ${myArgs[*]} ; do
option=$(sed -e "s/\/dev\///g" <<< $option)
option=$(sed -e "s/\/media\///g" <<< $option)
    input=( ${option//=/ } )
    echo 'Option  ->  [ '${input[0]}' ] with [ '${input[1]}' ]'
    case ${input[0]} in
    	-h | -help) listDevices; listOptions ;;
    	-l | -list) listDevices ;;
        -mount) mountUnit ${input[1]} ;;
        -umount) umountUnit ${input[1]} ;;
        -reg) regUnit ${input[1]} ;;
        -del) delUnit ${input[1]} ;;
        *) echo ' Incorrect option: [ '${input[0]:1}' ].' ;;
    esac    
done
if [ $# -gt 0 ]; then echo -e "All done!"; exit 0; fi
exit
