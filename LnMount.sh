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
    echo "${TAB}requested UUID   : ${reqUUID}"
    echo "${TAB}is it in myTable : $isValidUUID"
    echo
    set -u
}


# ========================================================================================
# - Legge il file di configurazione dove trova la tabella degli UUID
# ========================================================================================
function readingConfigFile {
    local confFile="$1"

    if [[ "$ACTION" == 'list' ]]; then
        echo "${TAB}--------------------------------------------------------"
        echo "${TAB}UUID            TYPE    preferred MPoint"
        echo "${TAB}--------------------------------------------------------"

    fi

        # ---------------------------------------------------------
        # - Reading configuration file $ConfFile
        # - NON usare cat $ConfFile | \ while read ....
        # - ...perchè apre un subShell e si perdono le Variabili
        # ---------------------------------------------------------
    isValidUUID='false'

    while read UUID TYPE prefMPoint; do
        if [[ "$ACTION" == 'list' ]]; then
            if [[ "$UUID" != "#" ]]; then
                echo "${TAB}$UUID       $TYPE       $prefMPoint"
            fi

        elif [[ "$UUID" == "$reqUUID" ]]; then
            isValidUUID='true'
            break
        fi

    done < $confFile
    [[ "$ACTION" == 'list' ]] && echo && exit 1
}




################################
# -
################################
function verifyDiskByUUID {
    # isValidUUID='false'
    # currMPath="-"
    isMOUNTED='-'
    # prefMPoint="-"
    # diskExists='false'


        # tabellina dove inseriamo gli UUID che riconosciamo validi
    # [[ "$reqUUID" == '34F4-73E2' ]] && isValidUUID='true' && prefMPoint='/home/Loreto32GB' && TYPE='exfat'
    # [[ "$reqUUID" == '24C4-EA91' ]] && isValidUUID='true' && prefMPoint='/home/Loreto32GB' && TYPE='exfat'
    # [[ "$reqUUID" == '1C01-1919' ]] && isValidUUID='true' && prefMPoint='/home/Loreto32GB' && TYPE='vfat'
    # [[ "$reqUUID" == '1C03-1548' ]] && isValidUUID='true' && prefMPoint='/home/Loreto32GB' && TYPE='vfat'

        # verifichiamo se lo UUID è presente nel sistema
    # currMPath=$(readlink -f /dev/disk/by-uuid/${reqUUID})
    currMPath=$(blkid -U ${reqUUID})


    if [[ -n "$currMPath" ]]; then
        diskExists='true'
        mountLine=$(mount | grep $currMPath)

        if [[ -n "$mountLine" ]]; then
            isMOUNTED=$(echo $mountLine | cut -f3 -d\ )
            # wrConsole "disk is already mounted:"

        # else
            # isMOUNTED='-'
            # wrConsole "disk exist but is NOT mounted"
        fi

    else
        # currMPath='-'
        wrConsole "disk doesn't exists on system."
        exit 1

    fi

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

    [[ "$ACTION" != 'mount' && "$ACTION" != "umount" ]] && ACTION='list'

    readingConfigFile "$configFile"
    if [[ "$isValidUUID" != "true" ]]; then
        wrConsole "disk will not mounted because it is not in myTable."
        exit 1
    fi


    verifyDiskByUUID
    if   [[ "$ACTION" == "mount" ]]; then
        if [[ "$isMOUNTED" == "-" ]]; then
            mountDiskByUUID
            verifyDiskByUUID
            wrConsole "disk status after mount"
            if [[ "$rCode" -ne 0 ]]; then
                echo "sudo lsof $isMOUNTED"
                echo "sudo fuser -vm $isMOUNTED"
            fi
        else
            wrConsole "disk status is already mounted."
        fi


    elif [[ "$ACTION" == "umount" ]]; then
        if [[ ! "$isMOUNTED" == "-" ]]; then
            uMountDiskByUUID
            verifyDiskByUUID
            wrConsole "disk status after umount."
            if [[ "$rCode" -ne 0 ]]; then
                echo "sudo lsof $isMOUNTED"
                echo "sudo fuser -vm $isMOUNTED"
            fi
        else
            wrConsole "disk status is already unMounted."
        fi

    # else
    #     ACTION='list'
    #     echo 'sono qui'
    #     exit
        # readingConfigFile 'LnMount.conf' 'LIST'

    fi