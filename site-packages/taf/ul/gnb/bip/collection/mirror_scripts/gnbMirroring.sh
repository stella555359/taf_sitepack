#!/bin/bash
#
###############################################################################
# Script to configure and enable Mirroring in Loner and tcpdumps to ABIL Slave Xeon.
# ASIK can be on left or right side of AMIA.
#
# USAGE
#   - Copy script files to ASIK (for example to /ffs/run/config/scripts/ folder)
#       - gnbMirroring.sh, gnbMirroringConfig.sh and gulp
#   - Give execution rights 
#       chmod +x /ffs/run/config/scripts/*.sh
#   - Modify options in gnbMirroringConfig.sh
#   - Run script
#       sh /ffs/run/config/scripts/gnbMirroring.sh
#   - In local mode, capture is stored to /tmp/tcpdump_L2L1_bip[_gulp]_filtering_[off|on].pcap000
#   - Remember to delete captures from ASIK after downloading to not to break SW upgrade due to insufficient disk space
#
# LINKS AND INFORMATION
#   gnbMirroring confluence
#     https://confluence.int.net.nokia.com/pages/viewpage.action?spaceKey=CV&title=gNB+Mirroring
#
#   ASIK Red Rock Canyon (RRC) ports distribution:
#     https://confluence.int.net.nokia.com/display/OPSW1/ASIK+Red+Rock+Canyon+%28RRC%29+ports+distribution
#
#   Loner problem solving wiki BIP mirroring
#     https://confluence.int.net.nokia.com/display/CUP/Capture+Loner+BIP+traffic
#
#   Script is stored in rotta:
#     \\eseefsn50.emea.nsn-net.net\rotta4internal\5G\Oulu_L3_CAMP\gnbMirroring
#
# HISTORY:
#   12.7.2019  V1:  - The first version. 
#                   - Tested with Loner HIFIX_VERSION_ID="loner_R50.0.0.20190625-083354"
#                   - Partly tested with HIFIX_VERSION_ID="loner_R51-TDD-CPRI.0.0.20190703-073310"
#
#   6.8.2019   V2:  - MAC interface for loner mirroring was changed with the new Loner release.
#                   - IP addresses in right side of AMIA are different than left side with cOAM.
#                   - Fixed tcpdump filtering for 5G19A
#                   - Tested with HIFIX_VERSION_ID="loner_R51-TDD-CPRI.0.0.20190722-124846"
#
#   16.8.2019  V3:  - Support for Carrier Aggregation, not tested, for GC2/GD2 L2-RT instances
#                   - support for eCpri Loner, tested with HIFIX_VERSION_ID="loner_R51-TDD-eCPRI.0.0.20190722-134619"
#                   - L1R51 version string was changed to capitals, HIFIX_VERSION_ID="LONER-TDD-CPRI-QSFP_R51.0.0.20190813-134103"
#
#   23.8.2019  V4:  - Support for L1R52
#                   - Use monitored_ports_mask and monitored_port_flag to enable Loner mirroring
#                   - Loner mirroring is disabled in standalone mode after tcpdump
#                   - Tested 
#                       - HIFIX_VERSION_ID="LONER-TDD-CPRI-QSFP_R51.0.0.20190813-134103"
#                       - HIFIX_VERSION_ID="loner_R50.0.0.20190719-112539"
#                       - HIFIX_VERSION_ID="loner_R52-TDD-CPRI.0.0.20190806-013011"
#
#   12.9.2019  V5:  - Corrected standalone tcpdump target ABIL Slave Xeon IP for ASIK on right side configs
#
#   20.9.2019  V6:  - Support for 5G19B
#                   - Tested
#                       - HIFIX_VERSION_ID="LONER-TDD-CPRI_5G19B.0.0.20190912-205633"
#
#   22.9.2019  V7:  - Corrected instructions to stop standalone tcpdump, use Ctrl-C instead of Ctrl-Z
#                   - Kill tcpdump process from Abil Slave Xeon if standalone tcpdump is interrupted
#
#   25.9.2019  V8:  - Loner security does not allow direct ssh, changed to bsh
#                   - Tested
#                       - HIFIX_VERSION_ID="LONER-TDD-CPRI-SFP_R52.0.0.20190918-025115"
#
#   3.10.2019  V9:  - eLoner monitoring arbiter changed to arb0p2
#                   - Tested
#                       - HIFIX_VERSION_ID="LONER-TDD-eCPRI_R51.0.0.20191002-122705"
#
#   25.10.2019 V10: - Added checks for script file name and folder
#                   - Changed folder for storing standalone tcpdump files
#                   - Added support to start standalone mirroring after remote
#
#   25.10.2019 V11: - Hide unnecessary warnings from console logs
#                   - Moved options to an own file
#
#   11.11.2019 V12: - Removed dual option from filtering 
#                   - Standalone tcpdump is done to /tmp folder in Abil Slave Xeon and then copied to Asik Master Xeon
#
#   15.11.2019 V13: - Preaparations for using GULP, not working yet
#                   - Quick and dirty hack to support standalone dumping in ASIB
#
#   19.11.2019 V14: - Automatic detection of HW type
#                   - Removed dependency for script location and name
#                   - support for multiple ABILs with ASIB
#
#   20.11.2019 V15: - Standalone mode dump size is defined in duration instead of number of packets
#                   - GULP is supported for ASIK/ABIL, needs to be enabled from config, thanks to jakub.trznadel@nokia.com
#
#   4.12.2019  V16: - Fixed 5G19 mirroring which was broken in V15
#                   - Preparations for ASOD
#
#   5.12.2019  V17: - Added support for command line arguments, see gnbMirroringConfig.sh for syntax
#                   - Fixed path dependency problem for gnbMirroringConfig.sh
#                   
#   13.12.2019 V18: - Added command line help, can be printed with -h|--help
#
#   13.12.2019 V19: - Added support for rotating buffer, i.e. user can define size and number of files for dumping
#                     Thanks to tomasz.turski@nokia.com and guillaume.bousquet@nokia.com for contributing
#
#   19.12.2019 V20: - Preparations for ASIL. Missing correction to "PR492359: [5G20A][ASIL]: L1/L2 mirroring not working"
#                   - Added support for ASIB remote mirroring, thanks to jari-pekka.tuikka@nokia.com
#                     Requires Loner with correction to "PR488560: [5G20A] [ASIB] BIP mirroring in ASIB-ABIL config doesn't work"
#
#   19.12.2019 V21: - Added a new MIRRORING_MODE 'manual' which starts standalone type mirroring but does not capture data nor disable mirroring
#
#   4.2.2020   V22: - ASIB mirroring SEI interface changed according to ICOM specification
#
#   10.2.2020  V23: - Support for "5GC001514 Distributed SW Deployment"
#
#   12.5.2020  V24: - Preparation for ASOD
#                   - Added 5G20A dldata_patternConfigReq to filter
#                   - Added 5G19B dldata_csiRsSendReq to filter
#                   - Only RRC ingress traffic is mirrored from Loner port
#
#   29.5.2020  V25: - Changed mode standalone -> local 
#                   - Added a few checks for options to prevent illegal configuration
#                   - Optimized ASIK RRC configuration to prevent RRC flooding in CARRIER_AGGREGATION
#                   - Added enabling Loner L1->L2 mirroring which is disabled by default in new Loners (PR504347)
#                   - Added options for backhaul and F1-u mirroring, functionality is not verified
#
#   1.6.2020   V26: - Fixed bug in multi-ABIL syscom mirroring
#                   - Fixed bug in multi-ABIL L1->L2 mirroring enabling
#
#   9.6.2020   V27: - Added backhaul and F1-u mirorring for ASIB
#                   - Force Loner to read multicast_ctrl register https://jira3.int.net.nokia.com/browse/BIPIP-384
#
#   26.6.2020  V28: - Added a new local dumping method "local_in_l2rt_core" for L2-L1 BIP capturing
#                   - Added memory amount check for local mode
#                   - Moved local dump from ABIL to ASIK from 5G20A onwards
#                   - Fixed Loner mirroring disabling for multi ABIL
#                   - Added debug option XTRACE
#
#   29.6.2020  V29: - Added FILTER as configurable parameter for local dump
#
#   6.8.2020   V30: - Reverted "Moved local dump from ABIL to ASIK from 5G20A onwards"
#                   - Separated options to choose BB boards and interfaces
#
#   14.10.2020 V31: - Removed https://jira3.int.net.nokia.com/browse/BIPIP-384 WA for 5G20B
#                   - Fixed "ASIB detection based on TargetBD does not work anymore AirScale-9.1800.1115"
#
#   14.10.2020 V32: - Moved tcpdump to ASIK 5G20A onwards
#
#   26.11.2020 V33: - ASIB: Moved tcpdump from ABIL to ASIB
#                   - Added local mode support for ASOD
#
#   11.12.2020 V34: - Fixed ASOD tcpdump copy condition
#                   - ASIL local dump preparations
#                   - ABIO preparations
#                   - Removed https://jira3.int.net.nokia.com/browse/BIPIP-384 WA for 5G21B
#                   - Fixed missing jumbo frames by forcing dump interface MTU size 8024 -> 9194
#
#   11.12.2020 V35: - ASIB: Reverted tcpdump back to ABIL
#
#   18.12.2020 V36: - Added note about pressing Ctrl-c only once to stop tcpdump
#                   - Removed forced broadcast register read for other HW than ASIK
#                   - ASIB: Moved tcpdump from ABIL to ASIB (SBTS will work as well)
#
#   28.12.2020 V37: - Changed MTU size comparison from '<' to '-lt'
#                   - Preparations for ASIB+ABIO
#
#   07.01.2021 V38: - Fixed 'ERROR: Found no register whose name is BIPregs_BIP_Stream_blk.rf0[31].BIP_EG_PROTOCOL'
#
#   08.01.2021 V39: - Changed ASIK mirroring interface to pepbp1
#                   - Cleaned up loggin
#                   - Restore initial eth SS state after mirroring
#                   - Fixed bug in local_in_l2rt_core mode
#
#   04.03.2021 V40: - Removed unnecessarily ssh commands when dumping happens in local core
#                   - Added SW release string print
#
#   16.03.2021 V41: - Fixed ASIB syscom mirroring by adding vlans 212 and 215 to monitorin port in Marvell
#
#   24.03.2021 V42: - ASIK+ABIL: Changed Loner L1->L2 mirroring from arb0p2 to arb0p0
#                   - ASIK+ABIL: Disabled MAC learning for Loner monitoring ports
#                   - ASIB+ABIO: Limited support
#
#   29.03.2021 V43: - Renamed L2HI_L2LO to L2HI in mirrored interfaces
#                   - Added L2RT and CPRT interface options
#                   - Fixed ASIL local dump issue by moving dump back to ABIL
#
#   19.04.2021 V44: - Renamed output files to contain keyword bip
#                   - Added more interface options for ASIB mirroring
#                   - Changed hard coded mac addresses from dynamic to static
#
#   19.04.2021 V45: - Enabled L1->L2 mirroring to arb0p0 by broadcasting, required in 5G21B
#
#   06.05.2021 V46: - Removed 5G19_ support
#                   - Added option to enable BIP only for L2->L1 or L1->L2 direction
#                   - Added EmptySendReq and EmptyReceiveReq to default filter
#
#   06.05.2021 V47: - Added support for local_in_l2rt_core for ABILs in other than first slot
#
#   14.05.2021 V48: - Added automatic FSP unit type detection
#                   - Added support for ASIL+ABIO L2L1 BIP
#
#   28.05.2021 V49: - Fixed ASIB/ASIL + ABIO BB slot 7
#                   - Added local_in_l2rt_core mode for ASIB+ABIL
#                   - Added enabling mac learning for mirroring ports in teardown
#
#   22.06.2021 V50: - Changed ASIB+ABIO local mode according to LFS instructions
#
#   01.07.2021 V51: - Added support for dual L2-RT - single Loner config
#                   - Removed CARRIER_AGGREGATION
#
#   05.07.2021 V52: - Added asib_bip_nrt_vlan=201 for ASIB+ABIL mirroring
#                   - Added support for Loner journal trigger
#                   - Added manual mode support for ASIB+ABIO
#
#   09.07.2021 V53: - Fixed 22R1 slot 5 ABIL mirroring by enabling RRC port manually
#
#   25.08.2021 V54: - Added SNAPLEN to limit bytes to be captured per packet
#                   - Added L2-PS peer interface support for ASIB+ABIO
#                   - Fixed filtering syntax for gulp
#
#   04.10.2021 V55: - Added support for Loner power saving in 22R1
#                   - Added ASIL+ABIO syscom support
#                   - Journal trigger support for local_in_l2rt_core for ASIK and ASIB
#
#   11.10.2021 V56: - Added BB_Node tag to dump file name if dump happens on BB node
#                   - Added disabling for mirroring in local_in_l2rt_core mode
#                   - Fixed port enabling from power saving mode (CNI-74573)
#                   - Added enabling power saving mode after mirroring
#
#   21.10.2021 V57: - Fixed backward compatibility of power saving mode (CNI-74573) changes
#
#   17.11.2021 V58: - Added support for ASIL+ABIL local_in_l2rt_core for others than slot 1 ABIL
#                   - Added L2HI and L2RT interfaces for ASIL+ABIL
#                   - Improved FILTER example syntax and added an example for ABIO deployments 
#                     with additional VLAN
#                   - Fixed ASIB and ASIL low power mode checks
#
#   18.01.2022 V59: - Added 500 MB safety margin for memory reservation
#                   - Added support for ASIL++ABIO backhaul
#                   - Added syscom for ASIB+ABIO
#                   - Fixed L2RT_MIRRORING for ASIB+ABIO
#                   - Added L2HI_MIRRORING for ASIB+ABIO
#                   - Updated comments in config file
#
#   07.02.2022 V60: - Added option to skip SW build check. Needed for example in L1 integration test envs.
#
#   09.02.2022 V61: - Fixed a bug for ABIO HW check not working
#
#   05.05.2022 V62: - Fixed SW branch fetching from TargetBD file
#                   - ASIB: changed mirror_info to mirror_port_info
#
# BUG REPORTS:
#   Provide console log and capture to juha.kangas@nokia.com
# 
###############################################################################

VERSION_STRING='V62'
GNB_MIRRORING_LOG_FILE='gnbMirroring.log'

YELLOW='\e[33m'
RED='\e[31m'
GREEN='\e[32m'
NC='\e[0m'

MBYTES_TO_KBYTES=1024
MEMORY_MARGIN_KBYTES=512000
# In ASIB 9216
MTU_SIZE=9194

DTPATH="$(ddal ddal_devicetree_get_lfs_path | grep path | cut -d '=' -f 2)"
declare -r ASIB_BOARD_TYPE="FCTM"
declare -r ASIK_BOARD_TYPE="FCTL"
declare -r ASIL_BOARD_TYPE="FCTP"
declare -r ASOE_BOARD_TYPE="ASCE"
declare -r ABIN_UNIT_ID="ASPC"
declare -r ABIO_UNIT_ID="ASPD"

#abil1_master_xeon 192.168.253.20
#abil1_slave_xeon 192.168.253.21
#abil1_loner 192.168.253.22
##etha01=`ifconfig etha01 | grep inet`
##etha01_ip=${etha01:13:14}
##if [ $etha01_ip = '192.168.253.32' ]; then
##  abil1_slave_xeon_ip='192.168.253.37'
##  abil1_loner_ip='192.168.253.38'
##  abil2_loner_ip='192.168.253.42'
##  abil3_loner_ip='192.168.253.46'
##else
##  abil1_slave_xeon_ip='192.168.253.21'
##  abil1_loner_ip='192.168.253.22'
##  abil2_loner_ip='192.168.253.26'
##  abil3_loner_ip='192.168.253.30'
##fi

enable='e'
disable='d'

# VLAN
asib_bip_vlan=218
asib_sycom_vlan_1=212
asib_sycom_vlan_2=225
asib_bip_nrt_vlan=201

asik_bip_rt_vlan=218
asik_bip_nrt_vlan=201


# ASIK/ASIB/ABIL Nodes
asik_master_xeon_node='0'
asik_slave_xeon_node='1'
asib_axm_node='0'
asil_axm_node='0'
abil1_master_xeon_node='1:0'
abil2_master_xeon_node='2:0'
abil3_master_xeon_node='3:0'
abil1_slave_xeon_node='1:1'
abil2_slave_xeon_node='2:1'
abil3_slave_xeon_node='3:1'
abil1_loner_node='1:2'
abil2_loner_node='2:2'
abil3_loner_node='3:2'

abil_xeon_loner_interface='ethloner0'
abil_xeon_rrc_interface='ethbp1'
asik_xeon_rrc_interface='etha01'
asik_xeon_rrc_bip_interface='pepbp1'

# ASIK RRC
asik_rrc_asik_master_xeon_port=2
asik_rrc_asik_slave_xeon_port=3
asik_rrc_asik_master_xeon_bip_port=4
asik_rrc_eif1_port=14
asik_rrc_eif2_port=15
asik_rrc_abil1_master_xeon_port=20
asik_rrc_abil1_slave_xeon_port=21
asik_rrc_abil1_loner_port0=22
asik_rrc_abil1_eth_switch_port=23
asik_rrc_abil1_loner_port1=25
asik_rrc_abil2_master_xeon_port=28
asik_rrc_abil2_slave_xeon_port=29
asik_rrc_abil2_loner_port0=30
asik_rrc_abil2_eth_switch_port=31
asik_rrc_abil2_loner_port1=33
asik_rrc_abil3_master_xeon_port=36
asik_rrc_abil3_slave_xeon_port=37
asik_rrc_abil3_loner_port0=38
asik_rrc_abil3_eth_switch_port=39
asik_rrc_abil3_loner_port1=41

# L2-PS MAC addresses
# slot 1
asik_abil_l2ps_mac_slot1_1='02:40:43:80:01:31'
asik_abil_l2ps_mac_slot1_2='02:40:43:80:01:32'
asik_abil_l2ps_mac_slot1_3='02:40:43:80:01:33'
asik_abil_l2ps_mac_slot1_4='02:40:43:80:01:34'
asik_abil_l2ps_mac_slot1_5='02:40:43:80:01:35'
asik_abil_l2ps_mac_slot1_6='02:40:43:80:01:36'
asik_abil_l2ps_mac_slot1_7='02:40:43:80:01:37'
asik_abil_l2ps_mac_slot1_9='02:40:43:80:01:39'
asik_abil_l2ps_mac_slot1_a='02:40:43:80:01:3a'
asik_abil_l2ps_mac_slot1_b='02:40:43:80:01:3b'
asik_abil_l2ps_mac_slot1_c='02:40:43:80:01:3c'
asik_abil_l2ps_mac_slot1_d='02:40:43:80:01:3d'
asik_abil_l2ps_mac_slot1_e='02:40:43:80:01:3e'
asik_abil_l2ps_mac_slot1_f='02:40:43:80:01:3f'

# slot 2
asik_abil_l2ps_mac_slot2_1='02:40:43:80:02:31'
asik_abil_l2ps_mac_slot2_2='02:40:43:80:02:32'
asik_abil_l2ps_mac_slot2_3='02:40:43:80:02:33'
asik_abil_l2ps_mac_slot2_4='02:40:43:80:02:34'
asik_abil_l2ps_mac_slot2_5='02:40:43:80:02:35'
asik_abil_l2ps_mac_slot2_6='02:40:43:80:02:36'
asik_abil_l2ps_mac_slot2_7='02:40:43:80:02:37'
asik_abil_l2ps_mac_slot2_9='02:40:43:80:02:39'
asik_abil_l2ps_mac_slot2_a='02:40:43:80:02:3a'
asik_abil_l2ps_mac_slot2_b='02:40:43:80:02:3b'
asik_abil_l2ps_mac_slot2_c='02:40:43:80:02:3c'
asik_abil_l2ps_mac_slot2_d='02:40:43:80:02:3d'
asik_abil_l2ps_mac_slot2_e='02:40:43:80:02:3e'
asik_abil_l2ps_mac_slot2_f='02:40:43:80:02:3f'

# slot 3
asik_abil_l2ps_mac_slot3_1='02:40:43:80:03:31'
asik_abil_l2ps_mac_slot3_2='02:40:43:80:03:32'
asik_abil_l2ps_mac_slot3_3='02:40:43:80:03:33'
asik_abil_l2ps_mac_slot3_4='02:40:43:80:03:34'
asik_abil_l2ps_mac_slot3_5='02:40:43:80:03:35'
asik_abil_l2ps_mac_slot3_6='02:40:43:80:03:36'
asik_abil_l2ps_mac_slot3_7='02:40:43:80:03:37'
asik_abil_l2ps_mac_slot3_9='02:40:43:80:03:39'
asik_abil_l2ps_mac_slot3_a='02:40:43:80:03:3a'
asik_abil_l2ps_mac_slot3_b='02:40:43:80:03:3b'
asik_abil_l2ps_mac_slot3_c='02:40:43:80:03:3c'
asik_abil_l2ps_mac_slot3_d='02:40:43:80:03:3d'
asik_abil_l2ps_mac_slot3_e='02:40:43:80:03:3e'
asik_abil_l2ps_mac_slot3_f='02:40:43:80:03:3f'

# slot 5
asik_abil_l2ps_mac_slot5_1='02:40:43:80:11:31'
asik_abil_l2ps_mac_slot5_2='02:40:43:80:11:32'
asik_abil_l2ps_mac_slot5_3='02:40:43:80:11:33'
asik_abil_l2ps_mac_slot5_4='02:40:43:80:11:34'
asik_abil_l2ps_mac_slot5_5='02:40:43:80:11:35'
asik_abil_l2ps_mac_slot5_6='02:40:43:80:11:36'
asik_abil_l2ps_mac_slot5_7='02:40:43:80:11:37'
asik_abil_l2ps_mac_slot5_9='02:40:43:80:11:39'
asik_abil_l2ps_mac_slot5_a='02:40:43:80:11:3a'
asik_abil_l2ps_mac_slot5_b='02:40:43:80:11:3b'
asik_abil_l2ps_mac_slot5_c='02:40:43:80:11:3c'
asik_abil_l2ps_mac_slot5_d='02:40:43:80:11:3d'
asik_abil_l2ps_mac_slot5_e='02:40:43:80:11:3e'
asik_abil_l2ps_mac_slot5_f='02:40:43:80:11:3f'

# slot 6
asik_abil_l2ps_mac_slot6_1='02:40:43:80:12:31'
asik_abil_l2ps_mac_slot6_2='02:40:43:80:12:32'
asik_abil_l2ps_mac_slot6_3='02:40:43:80:12:33'
asik_abil_l2ps_mac_slot6_4='02:40:43:80:12:34'
asik_abil_l2ps_mac_slot6_5='02:40:43:80:12:35'
asik_abil_l2ps_mac_slot6_6='02:40:43:80:12:36'
asik_abil_l2ps_mac_slot6_7='02:40:43:80:12:37'
asik_abil_l2ps_mac_slot6_9='02:40:43:80:12:39'
asik_abil_l2ps_mac_slot6_a='02:40:43:80:12:3a'
asik_abil_l2ps_mac_slot6_b='02:40:43:80:12:3b'
asik_abil_l2ps_mac_slot6_c='02:40:43:80:12:3c'
asik_abil_l2ps_mac_slot6_d='02:40:43:80:12:3d'
asik_abil_l2ps_mac_slot6_e='02:40:43:80:12:3e'
asik_abil_l2ps_mac_slot6_f='02:40:43:80:12:3f'

# slot 7
asik_abil_l2ps_mac_slot7_1='02:40:43:80:13:31'
asik_abil_l2ps_mac_slot7_2='02:40:43:80:13:32'
asik_abil_l2ps_mac_slot7_3='02:40:43:80:13:33'
asik_abil_l2ps_mac_slot7_4='02:40:43:80:13:34'
asik_abil_l2ps_mac_slot7_5='02:40:43:80:13:35'
asik_abil_l2ps_mac_slot7_6='02:40:43:80:13:36'
asik_abil_l2ps_mac_slot7_7='02:40:43:80:13:37'
asik_abil_l2ps_mac_slot7_9='02:40:43:80:13:39'
asik_abil_l2ps_mac_slot7_a='02:40:43:80:13:3a'
asik_abil_l2ps_mac_slot7_b='02:40:43:80:13:3b'
asik_abil_l2ps_mac_slot7_c='02:40:43:80:13:3c'
asik_abil_l2ps_mac_slot7_d='02:40:43:80:13:3d'
asik_abil_l2ps_mac_slot7_e='02:40:43:80:13:3e'
asik_abil_l2ps_mac_slot7_f='02:40:43:80:13:3f'

# Loner MAC addresses
asik_abil_loner_mac_slot1='02:40:43:80:01:24'
asik_abil_loner_mac_slot2='02:40:43:80:02:24'
asik_abil_loner_mac_slot3='02:40:43:80:03:24'
asik_abil_loner_mac_slot5='02:40:43:80:11:24'
asik_abil_loner_mac_slot6='02:40:43:80:12:24'
asik_abil_loner_mac_slot7='02:40:43:80:13:24'



# ASIL Monterey 3MS
asil_monterey_nac_port=13
asil_monterey_sei_port=21
asil_monterey_abil1_master_xeon_port=35
asil_monterey_abil1_slave_xeon_port=36
asil_monterey_abil1_eth_switch_port=37
asil_monterey_abil1_loner_port=38
asil_monterey_abil2_master_xeon_port=39
asil_monterey_abil2_slave_xeon_port=40
asil_monterey_abil2_eth_switch_port=41
asil_monterey_abil2_loner_port=42
asil_monterey_abil3_master_xeon_port=43
asil_monterey_abil3_slave_xeon_port=44
asil_monterey_abil3_eth_switch_port=45
asil_monterey_abil3_loner_port=46
# ASIL NAC (Network Accelerator Complex)
asil_nac_monterey_port=0
asil_nac_eif2_port=14
asil_nac_monterey_interface='nac_eth2'



# ASIB Marvell 98DX8324
asib_marvell_ncp_mngt_port=0
asib_marvell_ncp_port=2
asib_marvell_abil1_master_xeon_port=4
asib_marvell_abil1_slave_xeon_port=5
asib_marvell_abil1_eth_switch_port=6
asib_marvell_abil1_loner_port=7
asib_marvell_abil2_master_xeon_port=8
asib_marvell_abil2_slave_xeon_port=9
asib_marvell_abil2_eth_switch_port=10
asib_marvell_abil2_loner_port=11
asib_marvell_abil3_master_xeon_port=12
asib_marvell_abil3_slave_xeon_port=13
asib_marvell_abil3_eth_switch_port=14
asib_marvell_abil3_loner_port=15
# ASIB NCP () 
asib_ncp_marvell_interface_abil='eths2'
asib_ncp_marvell_interface_abio='eths3'
asib_ncp_marvell_port='xgmac97'
#asib_ncp_sei_interface='ethsei00'
#asib_ncp_sei_port='xgmac64'
asib_ncp_sei_interface='ethsei10'
asib_ncp_sei_port='xgmac32'
#asib_ncp_sei_interface='ethsei12'
#asib_ncp_sei_port='xgmac48'


# ASOD Marvell 98DX8312
asod_xeon_a_node='0'
asod_xeon_b_node='1'
asod_xeon_a_bip_interface='pepbp1'
#asod_aldrin_sei_port=0
#asod_aldrin_eif1_port=1
asod_aldrin_eif2_port=1
asod_aldrin_lodin_arb0p2_port=4
asod_aldrin_lodin_arb0p1_port=5
asod_aldrin_lodin_arb0p0_port=6
asod_aldrin_ethlmp0_port=7
asod_aldrin_xeon_b_10ge_0_port=8
asod_aldrin_xeon_b_10ge_1_port=9
asod_aldrin_xeon_a_10ge_0_port=10
asod_aldrin_xeon_a_10ge_1_port=11



################################## COMMON ##################################

setJournalTrigger () {
    if [ "$WAIT_FOR_JOURNAL_EVENT" = "off" ]; then
        capture_process_mode=""
    else
	    capture_process_mode="&" 
    fi
    echo -e "\n${YELLOW}setJournalTrigger WAIT_FOR_JOURNAL_EVENT $WAIT_FOR_JOURNAL_EVENT, mode $mode ${NC}"
}

startJournalObserver () {
    if [ "$WAIT_FOR_JOURNAL_EVENT" != "off" ]; then
	    echo -e "\n${YELLOW}Starting observer for $WAIT_FOR_JOURNAL_EVENT on BB board $BB_NODE_FOR_TRIGGER ${NC}" 
        bsh $BB_NODE_FOR_TRIGGER journalctl -f | grep -i -q "$WAIT_FOR_JOURNAL_EVENT"
	    echo -e "\n${YELLOW}$WAIT_FOR_JOURNAL_EVENT detected, storing the logs${NC}"
	fi
}

setFilter() {
    if [ $FILTERING = 'off' ]; then
        filtered_messages=""
    else
        if [ "$USE_GULP" = "true" ]; then
            filtered_messages="-f $FILTER"
        else
            filtered_messages=$FILTER
        fi
    fi
    echo -e "${NC}Filter: $filtered_messages${NC}"
}

evaluateTimeout() {
    if [[ $CAPTURING_TIME_SECONDS = 'infinite' ]] || [[ $CAPTURING_TIME_SECONDS = 0 ]]; then
        timeoutCommand=""
    else
        timeoutCommand="timeout -s 2 --foreground $CAPTURING_TIME_SECONDS"
    fi
}

copyDumpFiles() {
    echo -e "\n${YELLOW}Capturing stopped, copy dump files if needed${NC}"
    if [ "$dumpInLocalCore" = "false" ]; then
        files=$( bsh $1 "ls /tmp/tcpdump_L2L1_bip*" )
        for file in $files 
        do
            bget $1 $file /tmp/
        done
        bsh $1 "rm /tmp/tcpdump_L2L1_bip*"
    fi
    echo -e "\n${YELLOW}Dump files in /tmp/ folder${NC}"
    ls -la /tmp/tcpdump_L2L1_bip*
}

runTcpdump() {
    setFilter
    echo -e "${NC}tcpdump $CAPTURING_TIME_SECONDS seconds. Can be stopped with Ctrl-c. Output is saved to /tmp/tcpdump_L2L1_bip_filtering_$FILTERING.pcap${NC}"
    echo -e "${RED}NOTE!!! Ctrl-c must be pressed only once${NC}"
    evaluateTimeout
    if [ "$dumpInLocalCore" = "false" ]; then
        eval $timeoutCommand bsh $1 "tcpdump -i $2 -s $SNAPLEN -C $FILE_SIZE_MBYTES -W $NUMBER_OF_FILES -w /tmp/tcpdump_L2L1_bip_filtering_$FILTERING_BBNODE_$1.pcap '$filtered_messages'" "$capture_process_mode"
        startJournalObserver
        bsh $1 "pkill -2 tcpdump"
    else
        eval $timeoutCommand "tcpdump -i $2 -s $SNAPLEN -C $FILE_SIZE_MBYTES -W $NUMBER_OF_FILES -w /tmp/tcpdump_L2L1_bip_filtering_$FILTERING.pcap '$filtered_messages'" "$capture_process_mode"
        startJournalObserver
        pkill -2 tcpdump
    fi
    copyDumpFiles $1
}

copyAndRunGulp() {
    if [ "$dumpInLocalCore" = "false" ]; then
        echo -e "${NC}Copy gulp${NC}"
        bput $1 $directory/gulp /usr/sbin/
        bsh $1 "chmod +x /usr/sbin/gulp"
        bsh $1 "ln -s /usr/lib64/libpcap.so.1 /usr/lib64/libpcap.so.0.8" 2> /dev/null
    else
        cp $directory/gulp /usr/sbin/
        chmod +x /usr/sbin/gulp
        ln -s /usr/lib64/libpcap.so.1 /usr/lib64/libpcap.so.0.8 2> /dev/null
    fi
    setFilter
    evaluateTimeout
    echo -e "${NC}gulp $CAPTURING_TIME_SECONDS seconds. Can be stopped with Ctrl-c. Output is saved to /tmp/tcpdump_L2L1_bip_gulp_filtering_$FILTERING.pcap000${NC}"
    echo -e "${RED}NOTE!!! Ctrl-c must be pressed only once${NC}"
    if [ "$dumpInLocalCore" = "false" ]; then
        eval $timeoutCommand bsh $1 "gulp -i $2 -s $SNAPLEN -r $FILE_SIZE_MBYTES -C 1 -W $NUMBER_OF_FILES -o /tmp/ -n tcpdump_L2L1_bip_gulp_filtering_$FILTERING_BBNODE_$1.pcap -f '$filtered_messages'" "$capture_process_mode"
        startJournalObserver
        bsh $1 "pkill -2 gulp"
    else
            #$timeoutCommand gulp -i $2             -r $FILE_SIZE_MBYTES -C 1 -W $NUMBER_OF_FILES -o /tmp/ -n tcpdump_L2L1_bip_gulp_filtering_$FILTERING.pcap -f '$filtered_messages'
        eval $timeoutCommand gulp -i $2 -s $SNAPLEN -r $FILE_SIZE_MBYTES -C 1 -W $NUMBER_OF_FILES -o /tmp/ -n tcpdump_L2L1_bip_gulp_filtering_$FILTERING.pcap "$filtered_messages" "$capture_process_mode"
        startJournalObserver
        pkill -2 gulp
    fi
    copyDumpFiles $1
}

checkMemory() {
    memoryRequired=$(expr $NUMBER_OF_FILES \* $FILE_SIZE_MBYTES \* $MBYTES_TO_KBYTES + $MEMORY_MARGIN_KBYTES)
    if [ "$dumpInLocalCore" = "false" ]; then
        memoryAvailable=$( bsh $1 "df --output=avail /tmp | tail -n 1" )
    else
        memoryAvailable=$( df --output=avail /tmp | tail -n 1 )
    fi
    echo -e "${NC}Memory check, memoryRequired: $memoryRequired kB memoryAvailable $memoryAvailable kB${NC}"
    
    if [ $memoryAvailable -lt $memoryRequired ]; then
        echo -e "\n${RED}Not enough memory, decrease NUMBER_OF_FILES or FILE_SIZE_MBYTES${NC}"
        exit    
    fi
}

removeOldDumpFiles() {
    rm /tmp/tcpdump_L2L1_bip* 2> /dev/null
}

setMtuSize() {
    if [ "$dumpInLocalCore" = "false" ]; then
        mtuLine=$( bsh $1 "ifconfig $2 | grep mtu" )
    else
        mtuLine=$( ifconfig $2 | grep mtu )
    fi
    MTU_SIZE_ORIGINAL=${mtuLine#*mtu }
    echo -e "${NC}Node bsh $1 interface $2 MTU size is $MTU_SIZE_ORIGINAL, required $MTU_SIZE${NC}"
    if [ "$MTU_SIZE_ORIGINAL" -lt "$MTU_SIZE" ]; then
        echo -e "${YELLOW}Change bsh $1 interface $2 MTU size to $MTU_SIZE, original MTU size $MTU_SIZE_ORIGINAL${NC}"
        if [ "$dumpInLocalCore" = "false" ]; then
            bsh $1 "ifconfig $2 mtu $MTU_SIZE up"
        else
            ifconfig $2 mtu $MTU_SIZE up
        fi    
    fi
}

resetMtuSize() {
    if [ "$MTU_SIZE_ORIGINAL" -lt "$MTU_SIZE" ]; then
        echo -e "${YELLOW}Revert bsh $1 interface $2 MTU size to $MTU_SIZE_ORIGINAL${NC}"
        if [ "$MTU_SIZE_ORIGINAL" -lt "$MTU_SIZE" ]; then
            bsh $1 "ifconfig $2 mtu $MTU_SIZE_ORIGINAL up"
        else
            ifconfig $2 mtu $MTU_SIZE_ORIGINAL up
        fi
    fi
}

checkIfDumpHappensInLocalCore() {
    if [[ $1 != $asik_master_xeon_node ]] && [[ $1 != $asib_axm_node ]] && [[ $1 != $asod_xeon_a_node ]]; then
        dumpInLocalCore='false'
    else
        dumpInLocalCore='true'
    fi
    echo -e "${NC}Dump in local core $dumpInLocalCore${NC}"
}

captureData() {
    echo -e "\n${YELLOW}Capture data in node $1, interface $2 ${NC}"
    removeOldDumpFiles
    checkIfDumpHappensInLocalCore $1
    checkMemory $1
    setMtuSize $1 $2
    if [ $USE_GULP = 'true' ]; then
        copyAndRunGulp $1 $2
    else
        runTcpdump $1 $2
    fi
    resetMtuSize $1 $2
}

captureDataInL2rtCore() {
    echo -e "\n${YELLOW}Capture data directly in L2-RT node $1${NC}"
    bsh $1 "echo "write 0x0000F600 0x702" > /sys/kernel/debug/ixgbe/0000:04:00.1/reg_ops"
    bsh $1 "echo "write 0x0000F604 0x704" > /sys/kernel/debug/ixgbe/0000:04:00.1/reg_ops"
    captureData $1 $abil_xeon_loner_interface
    bsh $1 "echo "write 0x0000F600 0x0" > /sys/kernel/debug/ixgbe/0000:04:00.1/reg_ops"
    bsh $1 "echo "write 0x0000F604 0x0" > /sys/kernel/debug/ixgbe/0000:04:00.1/reg_ops"
    #tcpdump -nei ethloner0 -B 2000  -C 100 -W 14  -w /tmp/bipcapture.cap
}

################################## ABIO/ABIN ##################################
enableMirroringInAbioWithAsil() {
    echo -e "\n${YELLOW}Enabling mirroring in ABIO/ABIN with ASIL${NC}"
    if [ "$BB_SLOT_1" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "C1B1(6)" -s 1 -v 304
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "C1B1(6)" -s 1 -v 305
        fi
    fi
    if [ "$BB_SLOT_2" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "C1B2(6)" -s 2 -v 304
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "C1B2(6)" -s 2 -v 305
        fi
    fi
    if [ "$BB_SLOT_3" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "C1B3(6)" -s 3 -v 304
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "C1B3(6)" -s 3 -v 305
        fi
    fi
    if [ "$BB_SLOT_5" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "C2B4(6)" -s 5 -v 304
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "C2B4(6)" -s 5 -v 305
        fi
    fi
    if [ "$BB_SLOT_6" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "C2B5(6)" -s 6 -v 304
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "C2B5(6)" -s 6 -v 305
        fi
    fi
    if [ "$BB_SLOT_7" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "C2B6(6)" -s 7 -v 304
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "C2B6(6)" -s 7 -v 305
        fi
    fi
    if [ "$SYSCOM_MIRRORING" = "true" ]; then
        dbgnac mirror sport 1 dport 2 e b
    fi
}

enableMirroringInAbioWithAsib() {
    echo -e "\n${YELLOW}Enabling mirroring in ABIO/ABIN with ASIB${NC}"
    
    if [ "$BB_SLOT_1" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C1B1(2)" -s 1 -l eths3 -v 304
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C1B1(2)" -s 1 -l eths3 -v 305
        fi
        if [ "$L2RT_MIRRORING" = "true" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C1B1(2)" -s 1 -l eths3 -v 303
        fi
        if [ "$L2HI_MIRRORING" = "true" ]; then
            echo 3 ingress > /var/run/cpss/ports/5/mirroring_port 
            echo 3 ingress > /var/run/cpss/ports/6/mirroring_port
        fi
    fi
    if [ "$BB_SLOT_2" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C1B2(2)" -s 2 -l eths3 -v 304
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C1B2(2)" -s 2 -l eths3 -v 305
        fi
        if [ "$L2RT_MIRRORING" = "true" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C1B2(2)" -s 2 -l eths3 -v 303
        fi
        if [ "$L2HI_MIRRORING" = "true" ]; then
            echo 3 ingress > /var/run/cpss/ports/9/mirroring_port 
            echo 3 ingress > /var/run/cpss/ports/10/mirroring_port
        fi
    fi
    if [ "$BB_SLOT_3" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C1B3(2)" -s 3 -l eths3 -v 304
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C1B3(2)" -s 3 -l eths3 -v 305
        fi
        if [ "$L2RT_MIRRORING" = "true" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C1B3(2)" -s 3 -l eths3 -v 303
        fi
        if [ "$L2HI_MIRRORING" = "true" ]; then
            echo 3 ingress > /var/run/cpss/ports/13/mirroring_port 
            echo 3 ingress > /var/run/cpss/ports/14/mirroring_port
        fi
    fi
    if [ "$BB_SLOT_5" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C2B4(2)" -s 5 -l eths3 -v 304
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C2B4(2)" -s 5 -l eths3 -v 305
        fi
        if [ "$L2RT_MIRRORING" = "true" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C2B4(2)" -s 5 -l eths3 -v 303
        fi
        if [ "$L2HI_MIRRORING" = "true" ]; then
            echo 3 ingress > /var/run/cpss/ports/5/mirroring_port 
            echo 3 ingress > /var/run/cpss/ports/6/mirroring_port
        fi
    fi
    if [ "$BB_SLOT_6" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C2B5(2)" -s 6 -l eths3 -v 304
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C2B5(2)" -s 6 -l eths3 -v 305
        fi
        if [ "$L2RT_MIRRORING" = "true" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C2B5(2)" -s 6 -l eths3 -v 303
        fi
        if [ "$L2HI_MIRRORING" = "true" ]; then
            echo 3 ingress > /var/run/cpss/ports/9/mirroring_port 
            echo 3 ingress > /var/run/cpss/ports/10/mirroring_port
        fi
    fi
    if [ "$BB_SLOT_7" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C2B6(2)" -s 7 -l eths3 -v 304
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C2B6(2)" -s 7 -l eths3 -v 305
        fi
        if [ "$L2RT_MIRRORING" = "true" ]; then
            /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C2B6(2)" -s 7 -l eths3 -v 303
        fi
        if [ "$L2HI_MIRRORING" = "true" ]; then
            echo 3 ingress > /var/run/cpss/ports/13/mirroring_port 
            echo 3 ingress > /var/run/cpss/ports/14/mirroring_port
        fi
    fi

    if [ "$L2HI_MIRRORING" = "true" ]; then
        ncp_l2 -p XGMAC96 -I -senableSwitching.false
        ncp_l2 -p XGMAC96 -i -sdiscardInvalidVlanidPackets.false
        ncp_l2 -p XGMAC96 -i -sdiscardBadLengthPackets.false
    fi

}

################################## ABIL ##################################

enableMirroringInLoner() {
    echo -e "\n${YELLOW}Enabling mirroring in Loner $1${NC}"
    if [[ $controlCardHwType == "ASIK" ]]; then
        if [ "$swBranch" == "5G19B" ] || [ "$swBranch" == "5G20A" ]; then bsh $1 "lr BIPregs_BIP_Stream_blk.rf0[31].BIP_EG_PROTOCOL=0x60100000"; fi
    fi
    
    monitored_ports_mask_initial=$( bsh $1 "cat /sys/class/xlgx/xlgx0/device/monitored_ports_mask" )
    monitoring_port_flag_initial=$( bsh $1 "cat /sys/class/xlgx/xlgx0/device/monitoring_port_flag" )
    echo -e "${NC}monitored_ports_mask_initial $monitored_ports_mask_initial${NC}"
    echo -e "${NC}monitoring_port_flag_initial $monitoring_port_flag_initial${NC}"

    
    if [[ $controlCardHwType == "ASIB" ]] || [[ $controlCardHwType == "ASIL" ]]; then
        low_power_mode_used=$( bsh $1 "cat /sys/class/net/arb0p0/use_low_power_mode" )
        echo -e "${NC}Low power mode used arb0p0 (0=false, 1=true) : $low_power_mode_used${NC}"

        if [ "$low_power_mode_used" == "1" ]; then
            echo -e "${NC}Enable arb0p0 from power saving mode${NC}"
            bsh $1 "echo 0 > /sys/class/net/arb0p0/use_low_power_mode && ip link set arb0p0 up"
        fi
        sleep 2
        bsh $1 "ethtool -s arb0p0 phyad 1"
        if [ "$L2_L1_BIP" == "true" ] || [ "$L2_L1_BIP" == "l1l2" ]; then
            echo -e "${NC}Mirror L1->L2 traffic to arb0p0 with brodcasting${NC}"
            bsh $1 "echo fffffff 0 > /sys/class/bip/bip0/device/multicast_ctrl"
        else
            echo -e "${NC}Disable L1->L2 traffic mirroring to arb0p0 with brodcasting${NC}"
            bsh $1 "echo 0 0 > /sys/class/bip/bip0/device/multicast_ctrl"
        fi
        if [ "$L2_L1_BIP" == "true" ] || [ "$L2_L1_BIP" == "l2l1" ]; then
            echo -e "${NC}Mirror L2->L1 traffic from arb0p1 to arb0p0${NC}"
            monitored_ports_mask_addition="0x2"
            monitoring_port_flag_addition="0x1"
        else
            monitored_ports_mask_addition="0x0"
            monitoring_port_flag_addition="0x0"
        fi
    else
        low_power_mode_used=$( bsh $1 "cat /sys/class/net/arb0p2/use_low_power_mode" )
        echo -e "${NC}Low power mode used arb0p2 (0=false, 1=true) : $low_power_mode_used${NC}"

        if [ "$low_power_mode_used" == "1" ]; then
            echo -e "${NC}Enable arb0p0 and arb0p2 from power saving mode${NC}"
            bsh $1 "echo 0 > /sys/class/net/arb0p0/use_low_power_mode && ip link set arb0p0 up"
            bsh $1 "echo 0 > /sys/class/net/arb0p2/use_low_power_mode && ip link set arb0p2 up"
        fi
        sleep 3
        if [ "$L2_L1_BIP" == "true" ] || [ "$L2_L1_BIP" == "l1l2" ]; then
            echo -e "${NC}Mirror L1->L2 traffic to arb0p0 with phyad configuration${NC}"
            bsh $1 "echo fffffff 0 > /sys/class/bip/bip0/device/multicast_ctrl"
            bsh $1 "ethtool -s arb0p0 phyad 1 speed 10000 autoneg on duplex full"
            echo -e "${NC}bsh $1 ethtool -s arb0p0 phyad 1 speed 10000 autoneg on duplex full${NC}"
        else
            echo -e "${NC}Disable L1->L2 traffic mirroring to arb0p0 with brodcasting${NC}"
            bsh $1 "echo 0 0 > /sys/class/bip/bip0/device/multicast_ctrl"
        fi
        if [ "$L2_L1_BIP" == "true" ] || [ "$L2_L1_BIP" == "l2l1" ]; then
            echo -e "${NC}Mirror L2->L1 traffic from arb0p1 to arb0p2${NC}"
            monitored_ports_mask_addition="0x2"
            monitoring_port_flag_addition="0x4"
        else
            monitored_ports_mask_addition="0x0"
            monitoring_port_flag_addition="0x0"
        fi
    fi
    monitored_ports_mask_combined_dec=$(( $monitored_ports_mask_initial | $monitored_ports_mask_addition ))
    monitoring_port_flag_combined_dec=$(( $monitoring_port_flag_initial | $monitoring_port_flag_addition ))
    monitored_ports_mask_combined_hex=$( printf '0x%x\n' $monitored_ports_mask_combined_dec)
    monitoring_port_flag_combined_hex=$( printf '0x%x\n' $monitoring_port_flag_combined_dec)
    echo -e "${NC}monitored_ports_mask_combined_hex $monitored_ports_mask_combined_hex${NC}"
    echo -e "${NC}monitoring_port_flag_combined_hex $monitoring_port_flag_combined_hex${NC}"
    bsh $1 "echo $monitored_ports_mask_combined_hex > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && echo $monitoring_port_flag_combined_hex > /sys/class/xlgx/xlgx0/device/monitoring_port_flag"
    
}

enableMirroringInLoners() {
    if [ "$BB_SLOT_1" = "true" ] || [ "$BB_SLOT_5" = "true" ]; then enableMirroringInLoner "$abil1_loner_node"; fi
    if [ "$BB_SLOT_2" = "true" ] || [ "$BB_SLOT_6" = "true" ]; then enableMirroringInLoner "$abil2_loner_node"; fi
    if [ "$BB_SLOT_3" = "true" ] || [ "$BB_SLOT_7" = "true" ]; then enableMirroringInLoner "$abil3_loner_node"; fi
}

disableMirroringInLoner() {
    echo -e "${YELLOW}Disable mirroring in Loner $1${NC}"
    if [ "$low_power_mode_used" == "1" ]; then
        if [[ $controlCardHwType == "ASIB" ]] || [[ $controlCardHwType == "ASIL" ]]; then
            bsh $1 "ip link set arb0p0 down && echo 1 > /sys/class/net/arb0p0/use_low_power_mode"
        else
            bsh $1 "ip link set arb0p0 down && echo 1 > /sys/class/net/arb0p0/use_low_power_mode"
            bsh $1 "ip link set arb0p2 down && echo 1 > /sys/class/net/arb0p2/use_low_power_mode"
        fi
    fi
    bsh $1 "echo 0 0 > /sys/class/bip/bip0/device/multicast_ctrl"
    if [[ $controlCardHwType == "ASIK" ]]; then
        if [[ "$swBranch" == "5G19B" ]] || [[ "$swBranch" == "5G20A" ]]; then bsh $1 "lr BIPregs_BIP_Stream_blk.rf0[31].BIP_EG_PROTOCOL=0x60100000"; fi
    fi
    bsh $1 "echo $monitored_ports_mask_initial > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && echo $monitoring_port_flag_initial > /sys/class/xlgx/xlgx0/device/monitoring_port_flag"
}

disableMirroringInLoners() {
    if [ "$BB_SLOT_1" = "true" ] || [ "$BB_SLOT_5" = "true" ]; then disableMirroringInLoner "$abil1_loner_node"; fi
    if [ "$BB_SLOT_2" = "true" ] || [ "$BB_SLOT_6" = "true" ]; then disableMirroringInLoner "$abil2_loner_node"; fi
    if [ "$BB_SLOT_3" = "true" ] || [ "$BB_SLOT_7" = "true" ]; then disableMirroringInLoner "$abil3_loner_node"; fi
}



################################## ASOD ##################################


enableMirroringInAsodAldrin() {
    echo $1 both > /var/run/cpss/ports/$asod_aldrin_lodin_arb0p0_port/mirroring_port
    cat /var/run/cpss/ports/mirror_port_info
}

disableMirroringInAsodAldrin() {
    echo both > /var/run/cpss/ports/$asod_aldrin_lodin_arb0p0_port/disable_mirroring
}

startMirroringInAsod() {
    if [ $MIRRORING_MODE = 'remote' ]; then
        echo -e "${YELLOW}Enable remote mirroring in ASOD${NC}"
        #luaCLI -c "cpss-api call cpssDxChMirrRxAnalyzerDpTcSet devNum 0 analyzerDp CPSS_DP_GREEN_E analyzerTc 7"
        #luaCLI -c "cpss-api call cpssDxChMirrTxAnalyzerDpTcSet devNum 0 analyzerDp CPSS_DP_GREEN_E analyzerTc 7"
        #luaCLI -c "cpss-api call cpssDxChMirrorToAnalyzerForwardingModeSet devNum 0 mode CPSS_DXCH_MIRROR_TO_ANALYZER_FORWARDING_SOURCE_BASED_OVERRIDE_E"
        disableMirroringInAsodAldrin
        echo 1 > /var/run/cpss/ports/$asod_aldrin_eif2_port/enable
        enableMirroringInAsodAldrin $asod_aldrin_eif2_port
        
        ddal -s ddal_sfp_ctrl_set 1 0 0
        
    else
        disableMirroringInAsodAldrin
        enableMirroringInAsodAldrin $asod_aldrin_xeon_a_10ge_1_port
        if [ $MIRRORING_MODE = 'local' ]; then
            captureData $captureNode $captureInterface
            echo -e "\n${YELLOW}Disable mirroring from Aldrin(s)${NC}"
            disableMirroringInAsodAldrin
        fi
    fi
}

################################## ASIL ##################################

setMirroringInAsilMonterey() {
    if [ "$2" = "$enable" ]; then
        command="both"
    else
        command="none"
    fi

    if [ "$BB_SLOT_1" = "true" ] || [ "$BB_SLOT_5" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil1_loner_port $1 $command"
        fi
        if [ "$SYSCOM_MIRRORING" = 'true' ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil1_eth_switch_port $1 $command"
        fi
        if [ "$L2HI_MIRRORING" = 'true' ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil1_master_xeon_port $1 $command"
        fi
        if [ "$L2RT_MIRRORING" = 'true' ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil1_slave_xeon_port $1 $command"
        fi
    fi
    if [ "$BB_SLOT_2" = "true" ] || [ "$BB_SLOT_6" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil2_loner_port $1 $command"
        fi
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil2_eth_switch_port $1 $command"
        fi
        if [ "$L2HI_MIRRORING" = 'true' ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil2_master_xeon_port $1 $command"
        fi
        if [ "$L2RT_MIRRORING" = 'true' ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil2_slave_xeon_port $1 $command"
        fi
    fi
    if [ "$BB_SLOT_3" = "true" ] || [ "$BB_SLOT_7" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil3_loner_port $1 $command"
        fi
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil3_eth_switch_port $1 $command"
        fi
        if [ "$L2HI_MIRRORING" = 'true' ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil3_master_xeon_port $1 $command"
        fi
        if [ "$L2RT_MIRRORING" = 'true' ]; then
            bcicmd -n 3msd -c "/dbg3ms/mirror set $asil_monterey_abil3_slave_xeon_port $1 $command"
        fi
    fi
	bcicmd -n 3msd -c "/dbg3ms/mirror show"
}

enableMirroringInAsilMontereyWithAbio() {
    echo -e "${YELLOW}Enable mirroring in ASIL Monterey with ABIO/ABIN${NC}"
    bcicmd -n 3msd -c "/dbg3ms/port 36 set learning 0 0 1"
    if [ "$L2_L1_BIP" != "false" ]; then
        bcicmd -n 3msd -c "/dbg3ms/vlan add 304 13 untagged"
        bcicmd -n 3msd -c "/dbg3ms/vlan add 305 13 untagged"
        bcicmd -n 3msd -c "/dbg3ms/vlan remove 304 21"
        bcicmd -n 3msd -c "/dbg3ms/vlan remove 305 21"
    fi
}

enableMirroringInAsilMonterey() {
    echo -e "${YELLOW}Enable mirroring in ASIL Monterey${NC}"
    #bcicmd -n 3msd -c "/dbg3ms/vlan add 218 13 untagged"
    #dbgnac set port 2 speed 25000
    #dbgnac enable port 2
    #dbgnac set port 2 loop e t
    #dbgnac mirror sport 0 dport 2 e b
    #dbgnac mirror sport 2 dport 20 e b
    #/usr/bin/netd_uspace_lnk 2 1 25000 1
    #ifconfig nac_eth2 up
    #ifconfig nac_eth2 promisc
   
    setMirroringInAsilMonterey $1 "$enable"
}

disableMirroringInAsilMonterey() {
    echo -e "${YELLOW}Disable mirroring in ASIL Monterey${NC}"
    setMirroringInAsilMonterey $1 "$disable"
}

enableMirroringInAsilNacWithAbio() {
    echo -e "${YELLOW}Enable mirroring in ASIL NAC with ABIO/ABIN${NC}"
    dbgnac set port 2 speed 25000
    dbgnac enable port 2
    dbgnac set port 2 loop e t
    dbgnac mirror sport 0 dport 2 e b
    if [ "$BACKHAUL_MIRRORING" = "true" ]; then
        dbgnac mirror sport 15 dport 2 e b
    fi
    dbgnac mirror sport 2 dport 20 e b
    /usr/bin/netd_uspace_lnk 2 1 25000 1
    ifconfig nac_eth2 up
    ifconfig nac_eth2 promisc
}

enableMirroringInAsilNac() {
    echo -e "${YELLOW}Enable mirroring in ASIL NAC${NC}"
    dbgnac set port $asil_nac_eif2_port speed 10000
    dbgnac enable port $asil_nac_eif2_port
    dbgnac mirror sport $asil_nac_monterey_port dport $asil_nac_eif2_port e b
    dbgnac mirror dump
}

startMirroringInAsil() {
    if [[ "$fsp_unit_id" = "$ABIO_UNIT_ID" ]] || [[ "$fsp_unit_id" = "$ABIN_UNIT_ID" ]]; then
        if [ $MIRRORING_MODE = 'remote' ]; then
            enableMirroringInAbioWithAsil $asil_monterey_sei_port
            echo -e "${YELLOW}Remote mode with ASIL+ABIO/ABIN started${NC}"
        elif [ "$MIRRORING_MODE" = "local_in_l2rt_core" ]; then
            echo -e "\n${RED}MIRRORING_MODE = local_in_l2rt_core is not supported in ASIL+ABIO/ABIN${NC}"
            exit
        else
            enableMirroringInAbioWithAsil $asil_monterey_nac_port
            enableMirroringInAsilMontereyWithAbio
            enableMirroringInAsilNacWithAbio
            if [ $MIRRORING_MODE = 'local' ]; then
                captureData $captureNode $captureInterface
                echo -e "${RED}Disabling mirroring is not supported with ASIL${NC}"
            fi
        fi
    else
        enableMirroringInLoners
        if [ $MIRRORING_MODE = 'remote' ]; then
            enableMirroringInAsilMonterey $asil_monterey_nac_port
            enableMirroringInAsilNac
        elif [ "$MIRRORING_MODE" = "local_in_l2rt_core" ]; then
            setJournalTrigger
            captureDataInL2rtCore $l2rtNode
        else
            enableMirroringInAsilMonterey $capturePort
            if [ $MIRRORING_MODE = 'local' ]; then
                captureData $captureNode $captureInterface
            fi
            echo -e "\n${YELLOW}Disable mirroring${NC}"
            disableMirroringInLoners
            disableMirroringInAsilMonterey $capturePort
        fi
    fi

    
}




################################## ASIB ##################################

setMirroringInAsibMarvell() {

    if [ $2 = $enable ]; then
        dest_port=$1
        file_to_write="mirroring_port"
    else
        dest_port=""
        file_to_write="disable_mirroring"
    fi
    
    if [ "$BB_SLOT_1" = "true" ] || [ "$BB_SLOT_5" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil1_loner_port/$file_to_write
        fi
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil1_eth_switch_port/$file_to_write
        fi
        if [ $L2HI_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil1_master_xeon_port/$file_to_write
        fi
        if [ $L2RT_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil1_slave_xeon_port/$file_to_write
        fi
    fi
    if [ "$BB_SLOT_2" = "true" ] || [ "$BB_SLOT_6" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil2_loner_port/$file_to_write
        fi
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil2_eth_switch_port/$file_to_write
        fi
        if [ $L2HI_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil2_master_xeon_port/$file_to_write
        fi
        if [ $L2RT_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil2_slave_xeon_port/$file_to_write
        fi
    fi
    if [ "$BB_SLOT_3" = "true" ] || [ "$BB_SLOT_7" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil3_loner_port/$file_to_write
        fi
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil3_eth_switch_port/$file_to_write
        fi
        if [ $L2HI_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil3_master_xeon_port/$file_to_write
        fi
        if [ $L2RT_MIRRORING = 'true' ]; then
            echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil3_slave_xeon_port/$file_to_write
        fi
    fi
    if [ $BACKHAUL_MIRRORING = 'true' ]; then
        echo $dest_port both > /var/run/cpss/ports/$asib_marvell_abil1_master_xeon_port/$file_to_write
    fi
    if [ $CPRT_MIRRORING = 'true' ]; then
        echo $dest_port both > /var/run/cpss/ports/$asib_marvell_ncp_mngt_port/$file_to_write
    fi
    
    cat /var/run/cpss/ports/mirror_port_info
}

enableMirroringInAsibMarvell() {
    echo -e "\n${YELLOW}Enable mirroring in ASIB Marvell${NC}"
    setMirroringInAsibMarvell $1 "$enable"
}

disableMirroringInAsibMarvell() {
    echo -e "\n${YELLOW}Disable mirroring in ASIB Marvell${NC}"
    setMirroringInAsibMarvell $1 "$disable"
}

enableNcpMarvellInterface() {
    echo -e "\n${YELLOW}Enabling mirroring in ASIB NCP Marvell interface${NC}"
    ifconfig $asib_ncp_marvell_interface_abil up
    ncp_l2 -p $asib_ncp_marvell_port -I -s defaultVlanId.100
    ncp_l2 -i -p $asib_ncp_marvell_port -v $asib_bip_vlan -a
    ncp_l2 -i -p $asib_ncp_marvell_port -v $asib_bip_nrt_vlan -a
    ncp_l2 -i -p $asib_ncp_marvell_port -v $asib_sycom_vlan_1 -a
    ncp_l2 -i -p $asib_ncp_marvell_port -v $asib_sycom_vlan_2 -a
    ncp_portmirror -p $asib_ncp_marvell_port -d netdriver 
    ##nice -n -19 tcpdump -i eths2 -xx -w trace.pcap
    echo 1 > /var/run/cpss/ports/$asib_marvell_ncp_port/enable
}

enableMirroringInAsibNcp() {
    enableNcpMarvellInterface
    ifconfig $asib_ncp_sei_interface up
    ncp_portmirror -p $asib_ncp_marvell_port -d $asib_ncp_sei_port
}

disableAsibMarvellRemoteMirroring() {
	echo both > /var/run/cpss/ports/$asib_marvell_abil1_loner_port/disable_mirroring 1> /dev/null
	echo both > /var/run/cpss/ports/$asib_marvell_abil1_eth_switch_port/disable_mirroring 1> /dev/null
	echo both > /var/run/cpss/ports/$asib_marvell_abil2_loner_port/disable_mirroring 1> /dev/null
	echo both > /var/run/cpss/ports/$asib_marvell_abil2_eth_switch_port/disable_mirroring 1> /dev/null
	echo both > /var/run/cpss/ports/$asib_marvell_abil3_loner_port/disable_mirroring 1> /dev/null
	echo both > /var/run/cpss/ports/$asib_marvell_abil3_eth_switch_port/disable_mirroring 1> /dev/null
	echo both > /var/run/cpss/ports/$asib_marvell_abil1_slave_xeon_port/disable_mirroring 1> /dev/null
}

enableMirroringInAsibNcpWithAbio() {
    if [ "$SYSCOM_MIRRORING" = "true" ]; then
        echo $asib_marvell_ncp_port both > /var/run/cpss/ports/$asib_marvell_ncp_mngt_port/mirroring_port
    fi
    ncp_portmirror -p xgmac96 -r
    ncp_portmirror -d netdriver -p xgmac96
}

startMirroringInAsib() {
    if [[ "$fsp_unit_id" = "$ABIO_UNIT_ID" ]] || [[ "$fsp_unit_id" = "$ABIN_UNIT_ID" ]]; then
        enableMirroringInAbioWithAsib
        if [ $MIRRORING_MODE = 'remote' ]; then
            echo -e "${YELLOW}Remote mirroring started with ASIB+ABIO/ABIN${NC}"
        elif [ "$MIRRORING_MODE" = "local_in_l2rt_core" ]; then
            echo -e "\n${RED}MIRRORING_MODE = local_in_l2rt_core is not supported in ASIB+ABIO/ABIN${NC}"
            exit
        else
            setJournalTrigger
            enableMirroringInAsibNcpWithAbio
            if [ "$MIRRORING_MODE" = "local" ]; then
                captureData $captureNode $captureInterface
                echo -e "\n${RED}Disable mirroring is not supported in ASIB+ABIO/ABIN${NC}"
            fi
        fi
    else
        if [ $MIRRORING_MODE = 'remote' ]; then
            enableMirroringInLoners
            enableMirroringInAsibMarvell $asib_marvell_ncp_port
            enableMirroringInAsibNcp
        elif [ "$MIRRORING_MODE" = "local_in_l2rt_core" ]; then
            setJournalTrigger
            captureDataInL2rtCore $l2rtNode
        else
            setJournalTrigger
            enableMirroringInLoners
            disableAsibMarvellRemoteMirroring
            enableNcpMarvellInterface
            enableMirroringInAsibMarvell $capturePort
            if [ $MIRRORING_MODE = 'local' ]; then
                captureData $captureNode $captureInterface
                
                echo -e "\n${YELLOW}Disable mirroring${NC}"
                disableMirroringInLoners
                disableMirroringInAsibMarvell $capturePort
            fi
        fi
    fi        
}



################################## ASIK ##################################

setMacLearningAndConfigureStaticMacAddressesToRrc() {
    if [ "$BB_SLOT_1" = "true" ]; then
        dbgrrc enable port $asik_rrc_abil1_loner_port0
        dbgrrc port $asik_rrc_abil1_loner_port0 mac learning $1
        dbgrrc enable port $asik_rrc_abil1_loner_port1
        dbgrrc port $asik_rrc_abil1_loner_port1 mac learning $1
        if [ "$1" = "$disable" ]; then
            dbgrrc add mac $asik_abil_l2ps_mac_slot1_1 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot1_2 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot1_3 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot1_4 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot1_5 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot1_6 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot1_7 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot1_9 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot1_a $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot1_b $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot1_c $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot1_d $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot1_e $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot1_f $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_loner_mac_slot1 $asik_bip_rt_vlan $asik_rrc_eif2_port static
        fi
    fi
    if [ "$BB_SLOT_2" = "true" ]; then
        dbgrrc enable port $asik_rrc_abil2_loner_port0
        dbgrrc port $asik_rrc_abil2_loner_port0 mac learning $1
        dbgrrc enable port $asik_rrc_abil2_loner_port1
        dbgrrc port $asik_rrc_abil2_loner_port1 mac learning $1
        if [ "$1" = "$disable" ]; then
            dbgrrc add mac $asik_abil_l2ps_mac_slot2_1 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot2_2 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot2_3 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot2_4 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot2_5 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot2_6 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot2_7 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot2_9 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot2_a $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot2_b $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot2_c $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot2_d $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot2_e $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot2_f $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_loner_mac_slot2 $asik_bip_rt_vlan $asik_rrc_eif2_port static
        fi
    fi
    if [ "$BB_SLOT_3" = "true" ]; then
        dbgrrc enable port $asik_rrc_abil3_loner_port0
        dbgrrc port $asik_rrc_abil3_loner_port0 mac learning $1
        dbgrrc enable port $asik_rrc_abil3_loner_port1
        dbgrrc port $asik_rrc_abil3_loner_port1 mac learning $1
        if [ "$1" = "$disable" ]; then
            dbgrrc add mac $asik_abil_l2ps_mac_slot3_1 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot3_2 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot3_3 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot3_4 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot3_5 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot3_6 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot3_7 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot3_9 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot3_a $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot3_b $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot3_c $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot3_d $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot3_e $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot3_f $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_loner_mac_slot3 $asik_bip_rt_vlan $asik_rrc_eif2_port static
        fi
    fi
    if [ "$BB_SLOT_5" = "true" ]; then
        dbgrrc enable port $asik_rrc_abil1_loner_port0
        dbgrrc port $asik_rrc_abil1_loner_port0 mac learning $1
        dbgrrc enable port $asik_rrc_abil1_loner_port1
        dbgrrc port $asik_rrc_abil1_loner_port1 mac learning $1
        if [ "$1" = "$disable" ]; then
            dbgrrc add mac $asik_abil_l2ps_mac_slot5_1 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot5_2 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot5_3 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot5_4 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot5_5 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot5_6 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot5_7 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot5_9 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot5_a $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot5_b $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot5_c $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot5_d $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot5_e $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot5_f $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_loner_mac_slot5 $asik_bip_rt_vlan $asik_rrc_eif2_port static
        fi
    fi
    if [ "$BB_SLOT_6" = "true" ]; then
        dbgrrc enable port $asik_rrc_abil2_loner_port0
        dbgrrc port $asik_rrc_abil2_loner_port0 mac learning $1
        dbgrrc enable port $asik_rrc_abil2_loner_port1
        dbgrrc port $asik_rrc_abil2_loner_port1 mac learning $1
        if [ "$1" = "$disable" ]; then
            dbgrrc add mac $asik_abil_l2ps_mac_slot6_1 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot6_2 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot6_3 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot6_4 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot6_5 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot6_6 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot6_7 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot6_9 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot6_a $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot6_b $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot6_c $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot6_d $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot6_e $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot6_f $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_loner_mac_slot6 $asik_bip_rt_vlan $asik_rrc_eif2_port static
        fi
    fi
    if [ "$BB_SLOT_7" = "true" ]; then
        dbgrrc enable port $asik_rrc_abil3_loner_port0
        dbgrrc port $asik_rrc_abil3_loner_port0 mac learning $1
        dbgrrc enable port $asik_rrc_abil3_loner_port1
        dbgrrc port $asik_rrc_abil3_loner_port1 mac learning $1
        if [ "$1" = "$disable" ]; then
            dbgrrc add mac $asik_abil_l2ps_mac_slot7_1 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot7_2 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot7_3 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot7_4 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot7_5 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot7_6 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot7_7 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot7_9 $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot7_a $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot7_b $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot7_c $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot7_d $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot7_e $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_l2ps_mac_slot7_f $asik_bip_rt_vlan $asik_rrc_eif2_port static
            dbgrrc add mac $asik_abil_loner_mac_slot7 $asik_bip_rt_vlan $asik_rrc_eif2_port static
        fi
    fi
}

printRrcDegugInformation() {
    echo -e "\n${YELLOW}Enable mirroring in ASIK RRC${NC}"
    dbgrrc show port $asik_rrc_abil1_loner_port0 r
    dbgrrc show port $asik_rrc_abil1_loner_port1 r
    dbgrrc show port $asik_rrc_abil2_loner_port0 r
    dbgrrc show port $asik_rrc_abil2_loner_port1 r
    dbgrrc show port $asik_rrc_abil3_loner_port0 r
    dbgrrc show port $asik_rrc_abil3_loner_port1 r
    dbgrrc show port $asik_rrc_abil1_eth_switch_port r
    dbgrrc show port $asik_rrc_abil2_eth_switch_port r
    dbgrrc show port $asik_rrc_abil3_eth_switch_port r
    dbgrrc show port $asik_rrc_abil1_master_xeon_port r
    dbgrrc show port $asik_rrc_abil2_master_xeon_port r
    dbgrrc show port $asik_rrc_abil3_master_xeon_port r
    dbgrrc show port $asik_rrc_abil1_slave_xeon_port r
    dbgrrc show port $asik_rrc_abil2_slave_xeon_port r
    dbgrrc show port $asik_rrc_abil3_slave_xeon_port r
    dbgrrc show port $asik_rrc_eif1_port r
    dbgrrc show port $asik_rrc_asik_slave_xeon_port r
    dbgrrc show port $asik_rrc_asik_master_xeon_bip_port r
    sleep 1
    dbgrrc show port $asik_rrc_abil1_loner_port0 r
    dbgrrc show port $asik_rrc_abil1_loner_port1 r
    dbgrrc show port $asik_rrc_abil2_loner_port0 r
    dbgrrc show port $asik_rrc_abil2_loner_port1 r
    dbgrrc show port $asik_rrc_abil3_loner_port0 r
    dbgrrc show port $asik_rrc_abil3_loner_port1 r
    dbgrrc show port $asik_rrc_abil1_eth_switch_port r
    dbgrrc show port $asik_rrc_abil2_eth_switch_port r
    dbgrrc show port $asik_rrc_abil3_eth_switch_port r
    dbgrrc show port $asik_rrc_abil1_master_xeon_port r
    dbgrrc show port $asik_rrc_abil2_master_xeon_port r
    dbgrrc show port $asik_rrc_abil3_master_xeon_port r
    dbgrrc show port $asik_rrc_abil1_slave_xeon_port r
    dbgrrc show port $asik_rrc_abil2_slave_xeon_port r
    dbgrrc show port $asik_rrc_abil3_slave_xeon_port r
    dbgrrc show port $asik_rrc_eif1_port r
    dbgrrc show port $asik_rrc_asik_slave_xeon_port r
    dbgrrc show port $asik_rrc_asik_master_xeon_bip_port r
}

setMirroringInAsikRrc() {
    if [ "$BB_SLOT_1" = "true" ] || [ "$BB_SLOT_5" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil1_loner_port0 dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil1_loner_port0 dport $1 $2 both
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil1_loner_port1 dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil1_loner_port1 dport $1 $2 both
        fi
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil1_eth_switch_port dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil1_eth_switch_port dport $1 $2 both
        fi
        if [ $L2HI_MIRRORING = 'true' ]; then
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil1_master_xeon_port dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil1_master_xeon_port dport $1 $2 both
        fi
        if [ $L2RT_MIRRORING = 'true' ]; then
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil1_slave_xeon_port dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil1_slave_xeon_port dport $1 $2 both
        fi
    fi
    if [ "$BB_SLOT_2" = "true" ] || [ "$BB_SLOT_6" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil2_loner_port0 dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil2_loner_port0 dport $1 $2 both
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil2_loner_port1 dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil2_loner_port1 dport $1 $2 both
        fi
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil2_eth_switch_port dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil2_eth_switch_port dport $1 $2 both
        fi
        if [ $L2HI_MIRRORING = 'true' ]; then
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil2_master_xeon_port dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil2_master_xeon_port dport $1 $2 both
        fi
        if [ $L2RT_MIRRORING = 'true' ]; then
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil2_slave_xeon_port dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil2_slave_xeon_port dport $1 $2 both
        fi
    fi
    if [ "$BB_SLOT_3" = "true" ] || [ "$BB_SLOT_7" = "true" ]; then
        if [ "$L2_L1_BIP" != "false" ]; then
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil3_loner_port0 dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil3_loner_port0 dport $1 $2 both
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil3_loner_port1 dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil3_loner_port1 dport $1 $2 both
        fi
        if [ $SYSCOM_MIRRORING = 'true' ]; then
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil3_eth_switch_port dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil3_eth_switch_port dport $1 $2 both
        fi
        if [ $L2HI_MIRRORING = 'true' ]; then
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil3_master_xeon_port dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil3_master_xeon_port dport $1 $2 both
        fi
        if [ $L2RT_MIRRORING = 'true' ]; then
            echo -e "${NC}dbgrrc mirror sport $asik_rrc_abil3_slave_xeon_port dport $1 $2 both${NC}"
            dbgrrc mirror sport $asik_rrc_abil3_slave_xeon_port dport $1 $2 both
        fi
    fi
    if [ $BACKHAUL_MIRRORING = 'true' ]; then
        echo -e "${NC}dbgrrc mirror sport $asik_rrc_eif1_port dport $1 $2 both${NC}"
        dbgrrc mirror sport $asik_rrc_eif1_port dport $1 $2 both
    fi
    if [ $CPRT_MIRRORING = 'true' ]; then
        echo -e "${NC}dbgrrc mirror sport $asik_rrc_asik_slave_xeon_port dport $1 $2 both${NC}"
        dbgrrc mirror sport $asik_rrc_asik_slave_xeon_port dport $1 $2 both
    fi
}

enableMirroringInAsikRrc() {
    echo -e "\n${YELLOW}Enable mirroring in ASIK RRC${NC}"
    setMacLearningAndConfigureStaticMacAddressesToRrc "$disable"
    setMirroringInAsikRrc $1 "$enable"
    #printRrcDegugInformation
}

disableMirroringInAsikRrc() {
    echo -e "${YELLOW}Disable mirroring in ASIK RRC${NC}"
    setMirroringInAsikRrc $1 "$disable"
    setMacLearningAndConfigureStaticMacAddressesToRrc "$enable"
}

disableAsikRrcRemoteMirroring() {
    dbgrrc mirror sport $asik_rrc_abil1_loner_port0 dport $asik_rrc_eif2_port disable ingress 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil1_loner_port1 dport $asik_rrc_eif2_port disable ingress 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil1_eth_switch_port dport $asik_rrc_eif2_port disable both 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil2_loner_port0 dport $asik_rrc_eif2_port disable ingress 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil2_loner_port1 dport $asik_rrc_eif2_port disable ingress 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil2_eth_switch_port dport $asik_rrc_eif2_port disable both 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil3_loner_port0 dport $asik_rrc_eif2_port disable ingress 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil3_loner_port1 dport $asik_rrc_eif2_port disable ingress 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil3_eth_switch_port dport $asik_rrc_eif2_port disable both 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil1_master_xeon_port dport $asik_rrc_eif2_port disable both 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil2_master_xeon_port dport $asik_rrc_eif2_port disable both 1> /dev/null
    dbgrrc mirror sport $asik_rrc_abil3_master_xeon_port dport $asik_rrc_eif2_port disable both 1> /dev/null
    dbgrrc mirror sport $asik_rrc_eif1_port dport $asik_rrc_eif2_port disable both 1> /dev/null
}

enableEif2PortInAsikRrc() {
    dbgrrc enable port $asik_rrc_eif2_port
    dbgrrc set port $asik_rrc_eif2_port speed 10000
}

startMirroringInAsik() {
    if [ $MIRRORING_MODE = 'remote' ]; then
        enableMirroringInLoners
        enableMirroringInAsikRrc $asik_rrc_eif2_port
        enableEif2PortInAsikRrc
    elif [ "$MIRRORING_MODE" = "local_in_l2rt_core" ]; then
        setJournalTrigger
        captureDataInL2rtCore $l2rtNode
    else
        disableAsikRrcRemoteMirroring
        setJournalTrigger
        enableMirroringInLoners
        enableMirroringInAsikRrc $capturePort
        
        if [ $MIRRORING_MODE = 'local' ]; then
            captureData $captureNode $captureInterface
                    
            echo -e "\n${YELLOW}Disable RRC and Loner mirroring from enabled interface(s)${NC}"
            disableMirroringInLoners
            disableMirroringInAsikRrc $capturePort
        fi
    fi
}


################################## COMMON ##################################

readOptionsFromConfigFile() {
    source $directory/gnbMirroringConfig.sh
    if [ $? -eq 0 ]; then 
        echo -e "\n${YELLOW}Read options from gnbMirroringConfig.sh${NC}"
    else 
        echo -e "\n${RED}Config file (gnbMirroringConfig.sh) not found${NC}"
        exit
    fi
}

printHelp() {
    echo "Usage: ./gnbMirroring.sh [OPTION]"
    echo "Capture traffic in gNB internal interfaces"
    echo "Example: ./gnbMirroring.sh --use_gulp='true' --capturing_time_seconds='infinite' --number_of_files=5 --file_size_mbytes=10"
    echo -e "\nGeneral options:"
    echo "  -h|--help   print help"
    echo "  --mirroring_mode=['local'|'remote'|'manual'|'local_in_l2rt_core']"
    echo -e "\nMirrored BB boards:"
    echo "  --bb_slot_1=['true'|'false']"
    echo "  --bb_slot_2=['true'|'false']"
    echo "  --bb_slot_3=['true'|'false']" 
    echo "  --bb_slot_5=['true'|'false']"
    echo "  --bb_slot_6=['true'|'false']"
    echo "  --bb_slot_7=['true'|'false']" 
    echo -e "\nMirrored interfaces:"
    echo "  --l2_l1_bip=['true'|'false'|'l2l1'|'l1l2']"
    echo "  --syscom_mirroring=['true'|'false']"
    echo "  --backhaul_mirroring=['true'|'false']"
    echo "  --l2hi_mirroring=['true'|'false']"
    echo "  --l2rt_mirroring=['true'|'false']"
    echo "  --cprt_mirroring=['true'|'false']"
    echo -e "\nlocal mode options:"
    echo "  --filtering=['on'|'off']"
    echo "  --filter=[ether[0x18:2]!=<msg_id_1> && ether[0x18:2]!=<msg_id_2>]"
    echo "  --use_gulp=['true'|'false']"
    echo "  --capturing_time_seconds=[<seconds>|'infinite']"
    echo "  --number_of_files=<number_of_files>"
    echo "  --file_size_mbytes=<file_size_in_mbytes>"
    echo "  --snaplen=<bytes_of_data_from_each_packet>"
    echo -e "\ntriggering options:"
    echo "  --wait_for_journal_event=<string_to_stop_capturing>"
    echo "  --bb_node_for_trigger=<bb node for bsh service from where journal is followed>"
    echo -e "\ndebug options:"
    echo "  --xtrace=['on'|'off']"
    echo "  --skip_sw_build_check=['true'|'false']"
}


parseCommandLineOptions() {
    echo -e "\n${YELLOW}Parse command line options${NC}"
    for i in "$@"
    do
    case $i in
        -h|--help)
            printHelp
            exit
        ;;
        --mirroring_mode=*)
            MIRRORING_MODE="${i#*=}"
            shift
        ;;
        --l2_11_bip=*)
            L2_L1_BIP="${i#*=}"
            shift
        ;;
        --syscom_mirroring=*)
            SYSCOM_MIRRORING="${i#*=}"
            shift
        ;;
        --bb_slot_1=*)
            BB_SLOT_1="${i#*=}"
            shift
        ;;
        --bb_slot_2=*)
            BB_SLOT_2="${i#*=}"
            shift
        ;;
        --bb_slot_3=*)
            BB_SLOT_3="${i#*=}"
            shift
        ;;
        --bb_slot_5=*)
            BB_SLOT_5="${i#*=}"
            shift
        ;;
        --bb_slot_6=*)
            BB_SLOT_6="${i#*=}"
            shift
        ;;
        --bb_slot_7=*)
            BB_SLOT_7="${i#*=}"
            shift
        ;;
        --backhaul_mirroring=*)
            BACKHAUL_MIRRORING="${i#*=}"
            shift
        ;;
        --l2hi_mirroring=*)
            L2HI_MIRRORING="${i#*=}"
            shift
        ;;
        --l2rt_mirroring=*)
            L2RT_MIRRORING="${i#*=}"
            shift
        ;;
        --cprt_mirroring=*)
            CPRT_MIRRORING="${i#*=}"
            shift
        ;;
        --filtering=*)
            FILTERING="${i#*=}"
            shift
        ;;
        --filter=*)
            FILTER="${i#*=}"
            shift
        ;;
        --use_gulp=*)
            USE_GULP="${i#*=}"
            shift
        ;;
        --capturing_time_seconds=*)
            CAPTURING_TIME_SECONDS="${i#*=}"
            shift
        ;;
        --number_of_files=*)
            NUMBER_OF_FILES="${i#*=}"
            shift
        ;;
        --file_size_mbytes=*)
            FILE_SIZE_MBYTES="${i#*=}"
            shift
        ;;
        --snaplen=*)
            SNAPLEN="${i#*=}"
            shift
        ;;
        --wait_for_journal_event=*)
            WAIT_FOR_JOURNAL_EVENT="${i#*=}"
            shift
        ;;
        --bb_node_for_trigger=*)
            BB_NODE_FOR_TRIGGER="${i#*=}"
            shift
        ;;
        --xtrace=*)
            XTRACE="${i#*=}"
            shift
        ;;
        --skip_sw_build_check=*)
            SKIP_SW_BUILD_CHECK="${i#*=}"
            shift
        ;;
        *)
            #echo -e "\n${UELLOW}No options given in command line${NC}"
        ;;
    esac
    done
}

printOptions() {
    echo -e "General options"
    echo -e "  MIRRORING_MODE=$MIRRORING_MODE"
    echo -e "Mirrored BB boards"
    echo -e "  BB_SLOT_1=$BB_SLOT_1"
    echo -e "  BB_SLOT_2=$BB_SLOT_2"
    echo -e "  BB_SLOT_3=$BB_SLOT_3"
    echo -e "  BB_SLOT_5=$BB_SLOT_5"
    echo -e "  BB_SLOT_6=$BB_SLOT_6"
    echo -e "  BB_SLOT_7=$BB_SLOT_7"
    echo -e "Mirrored interfaces"
    echo -e "  L2_L1_BIP=$L2_L1_BIP"
    echo -e "  SYSCOM_MIRRORING=$SYSCOM_MIRRORING"
    echo -e "  BACKHAUL_MIRRORING=$BACKHAUL_MIRRORING"
    echo -e "  L2HI_MIRRORING=$L2HI_MIRRORING"
    echo -e "  L2RT_MIRRORING=$L2RT_MIRRORING"
    echo -e "  CPRT_MIRRORING=$CPRT_MIRRORING"
    echo -e "Local mode options"
    echo -e "  FILTERING=$FILTERING"
    echo -e "  FILTER=$FILTER"
    echo -e "  USE_GULP=$USE_GULP"
    echo -e "  CAPTURING_TIME_SECONDS=$CAPTURING_TIME_SECONDS"
    echo -e "  NUMBER_OF_FILES=$NUMBER_OF_FILES"
    echo -e "  FILE_SIZE_MBYTES=$FILE_SIZE_MBYTES"
    echo -e "  SNAPLEN=$SNAPLEN"
    echo -e "Triggering options"
    echo -e "  WAIT_FOR_JOURNAL_EVENT=$WAIT_FOR_JOURNAL_EVENT"
    echo -e "  BB_NODE_FOR_TRIGGER=$BB_NODE_FOR_TRIGGER"
    echo -e "Debug options"
    echo -e "  XTRACE=$XTRACE"
    echo -e "  SKIP_SW_BUILD_CHECK=$SKIP_SW_BUILD_CHECK"

}

checkOptions() {
    echo -e "\n${YELLOW}Check options ${NC}"
    #if [ $MIRRORING_MODE = 'local' ] && [ $BB_SLOT_1 == 'false' ]; then
    #    echo -e "\n${RED}Local mirroring does not work without the first ABIL${NC}"
    #    exit
    #fi
    if [[ "$MIRRORING_MODE" == 'local_in_l2rt_core' ]]; then
        if [[ "$SYSCOM_MIRRORING" = "true" ]] || [[ "$BACKHAUL_MIRRORING" = "true" ]] || [[ "$L2HI_MIRRORING" = "true" ]] || [[ "$L2RT_MIRRORING" = "true" ]] || [[ "$CPRT_MIRRORING" = "true" ]]; then
            echo -e "\n${RED}Only L2_L1_BIP supported in local_in_l2rt_core mode ${NC}"
            exit
        fi
    fi
}

function retrieve_fsp_unit_id {
    if [ "$BB_SLOT_1" = "true" ]; then
        FIRST_SLOT_ID=1
    elif [ "$BB_SLOT_2" = "true" ]; then
        FIRST_SLOT_ID=2
    elif [ "$BB_SLOT_3" = "true" ]; then
        FIRST_SLOT_ID=3
    elif [ "$BB_SLOT_5" = "true" ]; then
        FIRST_SLOT_ID=5
    elif [ "$BB_SLOT_6" = "true" ]; then
        FIRST_SLOT_ID=6
    elif [ "$BB_SLOT_7" = "true" ]; then
        FIRST_SLOT_ID=7
    fi
        
    local -r fsp_unit_id="$(tr -d '\0' < ${DTPATH}/slots/${FIRST_SLOT_ID}/A/board-identity/unit-id)"
    if [ "$fsp_unit_id" == "" ]; then
        echo -e "\n${RED}Can't retrieve FSP unit id $fsp_unit_id ${NC}"
        exit
    fi
    echo $fsp_unit_id
}

function retrieve_fct_board_type {
    local -r board_type="$(tr -d '\0' < ${DTPATH}/board-identity/unit-id)"
    if [ "$board_type" == "" ]; then
        echo -e "\n${RED}Can't retrieve board type $board_type ${NC}"
    fi
    echo $board_type
}

checkSwReleaseAndHW() {
    echo -e "${YELLOW}checkSwReleaseAndHW ${NC}"
    controlCardHwTypeRow=$( ddal -s ddal_sysinfo_module_get_unit_id 0 | grep value )
    controlCardHwType=${controlCardHwTypeRow:7:4}
    
    if [[ "$controlCardHwType" != "ASOE" ]] && [[ "$SKIP_SW_BUILD_CHECK" != "true" ]]; then
        targetBdFile=$( find /ffs/run/ -name TargetBD*.xml )
        echo -e "${YELLOW}TargetBd file: $targetBdFile ${NC}"
        offsetToBranch=${targetBdFile%%"SBTS"*}
        swBranch=${targetBdFile:${#offsetToBranch}:5}
        swReleaseLine=$( grep swReleaseVersionPackageName $targetBdFile )
        swReleaseString=${swReleaseLine#*swReleaseVersionPackageName}
        swReleaseString=${swReleaseString#*\"}
        swReleaseString=${swReleaseString%%\"*}
    fi
    
    fsp_unit_id=""
    echo -e "${YELLOW}Retrieve_fct_board_type ${NC}"
    board_type="$(retrieve_fct_board_type)"

    if [ "$board_type" != "$ASOE_BOARD_TYPE" ]; then
        echo -e "${YELLOW}Retrieve_fsp_unit_id ${NC}"
        fsp_unit_id="$(retrieve_fsp_unit_id)"
    fi
    
    echo -e "\n${YELLOW}Environment: ${NC}"
    echo -e "${NC}SW branch $swBranch ${NC}"
    echo -e "${NC}ReleaseVersionPackageName $swReleaseString${NC}"
    echo -e "${NC}controlCardHwType $controlCardHwType${NC}"
    echo -e "${NC}board_type $board_type${NC}"
    echo -e "${NC}fsp_unit_id $fsp_unit_id${NC}"
    
}

detectHwAndStartMirroring() {
    if [ $controlCardHwType == 'ASIK' ]; then
        if [[ $swBranch = '5G19A' ]] || [[ $swBranch = '5G19B' ]]; then
            l2rtNode=$abil1_master_xeon_node
            captureNode=$abil1_slave_xeon_node
            capturePort=$asik_rrc_abil1_slave_xeon_port
            captureInterface=$abil_xeon_rrc_interface
        else
            if [ "$BB_SLOT_1" = "true" ] || [ "$BB_SLOT_5" = "true" ]; then
                l2rtNode=$abil1_slave_xeon_node
            elif [ "$BB_SLOT_2" = "true" ] || [ "$BB_SLOT_6" = "true" ]; then
                l2rtNode=$abil2_slave_xeon_node
            elif [ "$BB_SLOT_3" = "true" ] || [ "$BB_SLOT_7" = "true" ]; then
                l2rtNode=$abil3_slave_xeon_node
            fi
            #captureNode=$abil1_master_xeon_node
            #capturePort=$asik_rrc_abil1_master_xeon_port
            #captureInterface=$abil_xeon_rrc_interface
            
            #captureNode=$asik_master_xeon_node
            #capturePort=$asik_rrc_asik_master_xeon_port
            #captureInterface=$asik_xeon_rrc_interface
            
            captureNode=$asik_master_xeon_node
            capturePort=$asik_rrc_asik_master_xeon_bip_port
            captureInterface=$asik_xeon_rrc_bip_interface
            
        fi
    elif [ $controlCardHwType == 'ASOD' ]; then
        l2rtNode=$asod_xeon_b_node
        captureNode=$asod_xeon_a_node
        captureInterface=$asod_xeon_a_bip_interface
        capturePort=$asod_aldrin_xeon_a_10ge_1_port
    elif [ $controlCardHwType == 'ASIL' ]; then
        if [[ "$fsp_unit_id" = "$ABIO_UNIT_ID" ]] || [[ "$fsp_unit_id" = "$ABIN_UNIT_ID" ]]; then
            l2rtNode=$abil1_slave_xeon_node
            captureNode=$asil_axm_node
            capturePort=$asil_monterey_nac_port
            captureInterface=$asil_nac_monterey_interface
        else
            if [ "$BB_SLOT_1" = "true" ] || [ "$BB_SLOT_5" = "true" ]; then
                l2rtNode=$abil1_slave_xeon_node
                captureNode=$abil1_master_xeon_node
                capturePort=$asil_monterey_abil1_master_xeon_port
            elif [ "$BB_SLOT_2" = "true" ] || [ "$BB_SLOT_6" = "true" ]; then
                l2rtNode=$abil2_slave_xeon_node
                captureNode=$abil2_master_xeon_node
                capturePort=$asil_monterey_abil2_master_xeon_port
            elif [ "$BB_SLOT_3" = "true" ] || [ "$BB_SLOT_7" = "true" ]; then
                l2rtNode=$abil3_slave_xeon_node
                captureNode=$abil3_master_xeon_node
                capturePort=$asil_monterey_abil3_master_xeon_port
            fi
            captureInterface=$abil_xeon_rrc_interface
            #captureNode=$asil_axm_node
            #capturePort=$asil_monterey_nac_port
            #captureInterface=$asil_nac_monterey_interface
        fi
    elif [ $controlCardHwType == 'ASIB' ]; then
        if [ "$BB_SLOT_1" = "true" ] || [ "$BB_SLOT_5" = "true" ]; then
            l2rtNode=$abil1_slave_xeon_node
        elif [ "$BB_SLOT_2" = "true" ] || [ "$BB_SLOT_6" = "true" ]; then
            l2rtNode=$abil2_slave_xeon_node
        elif [ "$BB_SLOT_3" = "true" ] || [ "$BB_SLOT_7" = "true" ]; then
            l2rtNode=$abil3_slave_xeon_node
        fi
        if [[ "$fsp_unit_id" = "$ABIO_UNIT_ID" ]] || [[ "$fsp_unit_id" = "$ABIN_UNIT_ID" ]]; then
            captureNode=$asib_axm_node
            capturePort=$asib_marvell_ncp_port
            captureInterface=$asib_ncp_marvell_interface_abio
        else
            #captureNode=$abil1_master_xeon_node
            #capturePort=$asib_marvell_abil1_master_xeon_port
            #captureInterface=$abil_xeon_rrc_interface
            captureNode=$asib_axm_node
            capturePort=$asib_marvell_ncp_port
            captureInterface=$asib_ncp_marvell_interface_abil
        fi
    else
        echo -e "${RED}controlCardHwType not supported $controlCardHwType${NC}"
    fi
    echo -e "\n${YELLOW}Mirroring details:${NC}"
    echo -e "${NC}l2rtNode $l2rtNode, used in local_in_l2rt_core mode${NC}"
    echo -e "${NC}captureNode $captureNode${NC}"
    echo -e "${NC}capturePort $capturePort${NC}"
    echo -e "${NC}captureInterface $captureInterface${NC}"
    

    if [ $controlCardHwType == 'ASIB' ]; then 
        echo -e "${YELLOW}Enable mirroring in ASIB${NC}"
        startMirroringInAsib
    elif [[ $controlCardHwType == 'ASOD' ]] || [[ $controlCardHwType == 'ASOE' ]]; then 
        echo -e "${YELLOW}Enable mirroring in ASOD${NC}"
        startMirroringInAsod
    elif [ $controlCardHwType == 'ASIL' ]; then 
        echo -e "${YELLOW}Enable mirroring in ASIL/ABIX${NC}"
        startMirroringInAsil
    elif [ $controlCardHwType == 'ASIK' ]; then 
        echo -e "\n${YELLOW}Enable mirroring in ASIK/ABIL${NC}"
        startMirroringInAsik
    else
        echo -e "${RED}Unknow controlCardHwType $controlCardHwType${NC}"
    fi
}

directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo -e "\n${YELLOW}gnbMirroring.sh $VERSION_STRING${NC}"
readOptionsFromConfigFile
parseCommandLineOptions "$@"
if [ $XTRACE = 'on' ]; then
    set -x
fi
printOptions
checkOptions
checkSwReleaseAndHW
detectHwAndStartMirroring
    
#rm $directory/$GNB_MIRRORING_LOG_FILE 1> /dev/null
#set -x
#set -o xtrace 
#2>&1 | tee $GNB_MIRRORING_LOG_FILE
#2>&1 | tee -a $GNB_MIRRORING_LOG_FILE
#cat /ram/RTCCSConfig.xml | grep -i l2ps


















