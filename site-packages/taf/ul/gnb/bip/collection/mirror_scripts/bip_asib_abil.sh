#!/bin/bash

VERSION_STRING='V01'

YELLOW='\e[33m'
RED='\e[31m'
GREEN='\e[32m'
NC='\e[0m'

directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo -e "\n${YELLOW}bip_abil.sh $VERSION_STRING${NC}"

readOptionsFromConfigFile() {
    source $directory/gnbMirroringConfig.sh
    if [ $? -eq 0 ]; then 
        echo -e "\n${YELLOW}Read options from gnbMirroringConfig.sh${NC}"
    else 
        echo -e "\n${RED}Config file (gnbMirroringConfig.sh) not found${NC}"
        exit
    fi
}

readOptionsFromComonFile() {
    source $directory/common_funcs.sh
    if [ $? -eq 0 ]; then 
        echo -e "\n${YELLOW}Read options from common_funcs.sh${NC}"
    else 
        echo -e "\n${RED}Config file (common_funcs.sh) not found${NC}"
        exit
    fi
}



readOptionsFromConfigFile
readOptionsFromComonFile
parseCommandLineOptions "$@"

if [ $XTRACE = 'on' ]; then
    set -x
fi

#Step 1 setting mirror
echo 1 > /var/run/cpss/ports/2/enable
ifconfig eths2 up
ncp_portmirror -d netdriver -p xgmac97
echo 2 both > /var/run/cpss/ports/4/mirroring_port
echo 2 both > /var/run/cpss/ports/5/mirroring_port
echo 2 both > /var/run/cpss/ports/6/mirroring_port
echo 2 both > /var/run/cpss/ports/8/mirroring_port
echo 2 both > /var/run/cpss/ports/9/mirroring_port
echo 2 both > /var/run/cpss/ports/10/mirroring_port
ncp_l2 -p XGMAC97 -I -senableSwitching.false
ncp_l2 -p XGMAC97 -i -sdiscardInvalidVlanidPackets.false
ncp_l2 -p XGMAC97 -i -sdiscardBadLengthPackets.false



if [ ! $controlCardHwType ]; then
    checkSwReleaseAndHW
fi

#Step 2 dump traffic
echo "**********Dump file will be stored in /tmp/"
evaluateTimeout
rm /tmp/tcpdump_L2L1_bip*

eval $timeoutCommand "tcpdump -i eths2 -C $FILE_SIZE_MBYTES -W $NUMBER_OF_FILES -vvv -w /tmp/tcpdump_L2L1_bip_filtering_$FILTERING.pcap '$filtered_messages'"
