#!/bin/bash
# by Loreto:            08/11/2016
# ############################################

# Sample
# sudo /bin/mount -tauto -o defaults,noauto,relatime,nousers,rw,flush,utf8=1,uid=pi,gid=pi,dmask=002,fmask=113 -U34F4-73E2 /home/Loreto32GB

TAB='   '



################################
# -
################################
function wrConsole {
    set +u
    TEXT=$*
    echo
    echo "${TAB}---------------------------------------------------------------"
    echo "${TAB}--- $TEXT"
    echo "${TAB}---------------------------------------------------------------"
    echo "${TAB}exists           : $diskExists"
    echo "${TAB}isMOUNTED on     : $isMOUNTED"
    echo "${TAB}preferred MPoint : $prefMPoint"
    echo "${TAB}path             : $currMPath"
    [[ "$ACTION" != 'status' ]] && echo "${TAB}requested UUID   : ${reqUUID}"
    # echo "${TAB}is it in myTable : $isValidUUID"
    echo
    set -u
}


# ========================================================================================
# - Legge il file di configurazione dove trova la tabella degli UUID
# ========================================================================================
function readingConfigFile {
    local confFile="$1"
    local lUUID="$2"

        # ---------------------------------------------------------
        # - Reading configuration file $ConfFile
        # - NON usare cat $ConfFile | \ while read ....
        # - ...perchè apre un subShell e si perdono le Variabili
        # ---------------------------------------------------------
    isValidUUID='false'
    if [[ "$ACTION" != "status"  && -n "$reqUUID" ]]; then
        echo "missing UUID parameter..."
        exit 1
    fi

    while read UUID TYPE prefMPoint; do
        if [[ "$ACTION" == 'status' ]]; then
            if [[ "$UUID" != "#" ]]; then
                verifyDiskByUUID $UUID
                wrConsole "status per UUID: $UUID"
            fi

        elif [[ "$UUID" == "$lUUID" ]]; then
            isValidUUID='true'
            break
        fi

    done < $confFile
    [[ "$ACTION" == 'status' ]] && echo && exit 1
}




################################
# -
################################
function verifyDiskByUUID {
    local uuid=$1
    isMOUNTED='-'
    local rCode=0



        # verifichiamo se lo UUID sia presente nel sistema
    # currMPath=$(readlink -f /dev/disk/by-uuid/${reqUUID})
    # currMPath=$(blkid -U ${reqUUID})
    currMPath=$(/sbin/blkid -U ${uuid})


    # rCode=0
    diskExists='false'
    if [[ -n "$currMPath" ]]; then
        diskExists='true'
        mountLine=$(mount | grep $currMPath)

        if [[ -n "$mountLine" ]]; then
            isMOUNTED=$(echo $mountLine | cut -f3 -d\ )
        fi

    else
        # wrConsole "disk doesn't exists on system."
        rCode=1

    fi

    # return $rCode
}


################################
# -
################################
function mountDiskByUUID {

    if [[ ! -d "$prefMPoint" ]]; then
        echo "directory $prefMPoint doesn't exists. Please create it.."
        echo
        exit 1
    fi

    echo "${TAB}trying to mount disk with UUID: ${reqUUID}"
    OPTIONS='defaults,noauto,relatime,nousers,rw,flush,utf8=1,uid=pi,gid=pi,dmask=002,fmask=113'
    CMD="/bin/mount -t ${TYPE} -o ${OPTIONS} -U ${reqUUID} ${prefMPoint}"
    echo ${TAB}$CMD
    eval "sudo $CMD"
    rCode=$?
    echo
}



################################
# -
################################
function uMountDiskByUUID {
    : "$reqUUID, $isMOUNTED, $TAB"

    echo "${TAB}trying to umount disk with UUID: ${reqUUID}"
    CMD="/bin/umount ${isMOUNTED}"
    echo "${TAB}$CMD"
    eval "sudo $CMD"
    rCode=$?
    echo
}








################################
# - MAIN
################################

ACTION=$1
reqUUID=$2
set -u # or set -o nounset

    scriptDir="$(dirname  "$(test -L "$0" && readlink "$0" || echo "$0")")"     # risolve anche eventuali LINK presenti sullo script
    scriptDir=$(cd $(dirname "$scriptDir"); pwd -P)/$(basename "$scriptDir")        # GET AbsolutePath
    baseDir=${scriptDir%/.*}                                                      # Remove /. finale (se esiste)
    configFile="${baseDir}/LnMount.conf"

    [[ "$ACTION" != 'mount' && "$ACTION" != "umount" ]] && ACTION='status'

    readingConfigFile "$configFile" "$reqUUID"
    # if [[ "$isValidUUID" != "true"  && -n "$reqUUID" ]]; then
    #     wrConsole "disk  is not in myTable."
    #     exit 1
    # fi


    # [[ -z "$reqUUID" ]] && echo "missing UUID parameter" && exit 1
    verifyDiskByUUID "$reqUUID"

    exit

    case "$ACTION" in
        mount)

            if [[ "$isMOUNTED" == "-" ]]; then
                mountDiskByUUID
                verifyDiskByUUID $reqUUID
                wrConsole "disk status after mount"
                if [[ "$rCode" -ne 0 ]]; then
                    echo "sudo lsof $isMOUNTED"
                    echo "sudo fuser -vm $isMOUNTED"
                fi
            else
                wrConsole "disk status is already mounted."
            fi
            ;;

        umount)
            [[ -z "$reqUUID" ]] && echo "missing UUID parameter" && exit 1

            if [[ ! "$isMOUNTED" == "-" ]]; then
                uMountDiskByUUID
                verifyDiskByUUID $reqUUID
                wrConsole "disk status after umount."
                if [[ "$rCode" -ne 0 ]]; then
                    echo "sudo lsof $isMOUNTED"
                    echo "sudo fuser -vm $isMOUNTED"
                fi
            else
                wrConsole "disk status is already unMounted."
            fi
            ;;

        *)
            echo 'sono qui'

    esac