#!/bin/bash

WORKDIR="/tmp"
FLASHDIR="/dev/flash/by-name"
FLASH_BLOCK_SIZE=65536
INSTALLED_UBOOT="u-boot_tmp.uim"
SW_DIR="/ffs/run/swpool/LFS/boot"
FPGA_FILENAME=""
SW_UBOOT_FILENAME=""
SCRIPTNAME=$(basename "$0")
RECONFIG=0
HELP=0
VERIFY=0
BOARD_VERSION_FILE="/proc/device-tree/board-identity/unit-id"
#the first one in the table is name of the board, the last one is the name of the file with u-boot
#between them are number of supported SoCs
soc_for_FCTJ=("FCTJ" "0" "FCT-MC-BW")
soc_for_FCTM=("FCTM" "0" "FCT-MC-BW")
soc_for_FSPJ=("FSPJ" "0" "FSP-MC-BW")
soc_for_ASPB=("ASPB" "0" "1" "ASPB-MC-BW")
soc_for_FCTB=("FCTB" "0" "FCT-MC-BW")
soc_for_FSPD=("FSPD" "0" "FCT-MC-BW")
soc_for_FSPP=("FSPP" "0" "FCT-MC-BW")
soc_for_FCTF=("FCTF" "0" "FCT-MC-BW")
soc_for_FSPM=("FSPM" "0" "FCT-MC-BW")

supported_boards=(soc_for_FCTJ soc_for_FCTM soc_for_FSPJ soc_for_ASPB soc_for_FCTB soc_for_FSPD soc_for_FSPP soc_for_FCTF soc_for_FSPM)

#the first one in the table is name of the board, the last one is the name of the file with FPGA
#between them are number of supported SoCs
FPGA_for_FSPJ=("FSPJ" "0" "FSP-BMUQ-A101-BW")
FPGA_for_FCTB=("FCTB" "0" "FCT-CCSSA2")
FPGA_for_FSPD=("FSPD" "0" "FSP-BMU1")
FPGA_for_FSPP=("FSPP" "0" "FSP-BMUP")
FPGA_for_FCTF=("FCTF" "0" "FCT-CCSSAH")
FPGA_for_FSPM=("FSPM" "0" "FSP-BMUM")

FPGA=(FPGA_for_FSPJ FPGA_for_FCTB FPGA_for_FSPD FPGA_for_FSPP FPGA_for_FCTF FPGA_for_FSPM)

print_to_tty() {
	echo "$@" >&2
}

check_module() {
	module_type=$(sysinfo 2>&1| head -n10 | grep "ID_00_MODULE_ID_\[0\]" | awk -F "'" '{print $2}')
	print_to_tty $module_type
	if [[ $module_type == 'FSMF' || $module_type == 'FSIH' || $module_type == 'FBBC' || $module_type == 'FBIH' ]]; then
		SW_DIR="/ffs/run/boot/"
	fi
}

log() {
	logger -t "${SCRIPTNAME}" -p user.info -- "$*"
	print_to_tty "$@"
}

change_version_fpga(){
	if fsm_fpga_upgrade -f $FPGA_FILENAME; then
		log "Upgrading/downgrading FPGA was successful"
	else
		log "Error, while upgrading/downgrading FPGA"
		exit 255
	fi

	#run reconfig reset when parameter was given
	if (( RECONFIG == 1 )); then
		fsm_fpga_upgrade -reconfig
	fi
}

check_fpga(){
	local version
	local fpga_actual
	local fpga_default
	local tmp
	local allowed
	print_to_tty "Checking FPGA"
	tmp=$(fsm_fpga_upgrade -c $FPGA_FILENAME | grep FPGA)
	allowed="${tmp##*>}"
	if [[ $allowed == *"no"* ]]; then
		log "FPGA update is not allowed"
		exit 255
	fi

	version=$(fsm_fpga_upgrade -c $FPGA_FILENAME | grep version)

	tmp="${version%%, *}"
	fpga_actual="${tmp##*img: }"

	if [[ $fpga_actual != "0x([0-9a-f]{4})" ]]; then
		log "Actual FPGA version read correctly: $fpga_actual"
	else
		log "Error while reading actual FPGA version"
		exit 255
	fi

	tmp="${version%,*}"
	fpga_default="${tmp##*img: }"

	if [[ $fpga_default != "0x([0-9a-f]{4})" ]]; then
		log "FPGA version delivered with SW read correctly: $fpga_default"
	else
		log "Error while reading version delivered with SW"
		exit 255
	fi
	if [[ $fpga_default != "$fpga_actual" ]]; then
		if (( VERIFY == 1 )); then
			log "FPGA versions are different"
		else
			log "FPGA versions are different - performing downgrade/upgrade"
			if (( RECONFIG == 1 )); then
				log "Board will reset after downgrade/upgrade"
			fi
			change_version_fpga
		fi
	else
		log "FPGA versions are the same"
	fi
}

print_help(){
	log "This script should downgrade or upgrade u-boot version on flash"
	log "to the same version, which is in SW load"
	log "OPTIONS"
	log "-r reconfig reset FPGA, used only in K2A"
	log "-v verify board and FPGA are supported "
}

change_version_uboot(){
	if uboot_env del previous_uboot_timestamp previous_linux_timestamp; then
		log "previous_uboot_timestamp and previous_linux_timestamp are deleted"
	else
		log "Error, while deleting timestamps"
		exit 255
	fi

	if update_u-boot.sh -f $SW_UBOOT_FILENAME; then
		log "U-boot downgrade/upgrade is succesfull"
	else
		log "Error, while downgrading/upgrading u-boot"
		exit 255
	fi
}

create_actual_uboot_image(){
	local partition
	local tmp

	tmp=$(ddal -s ddal_boot_get_uboot_id)
	partition="${tmp##*=}"

	case $partition in

		"0")
		log "Partition: 1"
		dd if=$FLASHDIR/boot_loader_1 of=$WORKDIR/$INSTALLED_UBOOT bs=$FLASH_BLOCK_SIZE 2>/dev/null || return 1
		;;

		"2")
		log "U-boot run from uImage"
		dd if=$FLASHDIR/boot_loader_1 of=$WORKDIR/$INSTALLED_UBOOT bs=$FLASH_BLOCK_SIZE 2>/dev/null || return 1
		;;

		"3" | "1")
		log "Partiton: 2"
		dd if=$FLASHDIR/boot_loader_2 of=$WORKDIR/$INSTALLED_UBOOT bs=$FLASH_BLOCK_SIZE 2>/dev/null || return 1
		;;

		*)
		log "Unknown partition"
		exit 255

	esac
}

get_uboot_version(){
	local build_version=""
	local retval=0
	local location

	location="$1"

	if test -f "$location"; then
		build_version=$(what "$location")
	else
		retval=1
	fi

	if [[ $build_version == "UNKNOWN" ]]; then
		retval=1
	fi

	echo "$build_version"
	return $retval
}

check_support_and_find_uboot_and_fpga(){
	local actual_board
	local actual_soc
	local tmp

	actual_board=$(tr -d '\0' <$BOARD_VERSION_FILE)
	tmp=$(ddal -s ddal_id_get_soc_id)
	actual_soc="${tmp##*=}"

	declare -n y
	for y in "${supported_boards[@]}"; do
		if [[ "${y[0]}" == "$actual_board" ]]; then
			unset "y[0]"
			for x in "${y[@]}"; do
				if [[ $x == "$actual_soc" ]]; then
					SW_UBOOT_FILENAME=${y[-1]}
					SW_UBOOT_FILENAME=$(ls $SW_DIR/$SW_UBOOT_FILENAME*.bin)
					break
				fi
			done
		fi
	done

	for y in "${FPGA[@]}"; do
		if [[ "${y[0]}" == "$actual_board" ]]; then
			unset "y[0]"
			for x in "${y[@]}"; do
				if [[ $x == "$actual_soc" ]]; then
					FPGA_FILENAME=${y[-1]}
					FPGA_FILENAME=$(ls $SW_DIR/"$FPGA_FILENAME"*.bin)
					break
				fi
			done
		fi
	done

	if [[ $FPGA_FILENAME != "" ]]; then
		log "Script supports change FPGA on board"
	else
		log "Script does not support change FPGA on board"
	fi

	if [[ $SW_UBOOT_FILENAME != "" ]]; then
		log "Script supports change u-boot version on board"
	else
		log "Script does not support change u-boot version on board"
		exit 255
	fi

}

get_and_compare_uboot_versions(){
	local installed_uboot_version
	local sw_uboot_version

	if create_actual_uboot_image; then
		log "Creating actual u-boot image was successful"
	else
		log "Error, while creating actual u-boot image"
		exit 255
	fi

	if installed_uboot_version=$(get_uboot_version "$WORKDIR/$INSTALLED_UBOOT"); then
		log "Actual installed u-boot on flash version: $installed_uboot_version"
	else
		log "Error, while getting actual u-boot version"
		exit 255
	fi

	if sw_uboot_version=$(get_uboot_version $SW_UBOOT_FILENAME); then
		log "SW u-boot version: $sw_uboot_version"
	else
		log "Error, while getting sw u-boot version"
		exit 255
	fi

	if [[ "$sw_uboot_version" != "$installed_uboot_version" ]]; then
		if (( VERIFY == 1 )); then
			log "U-boot versions are different"
		else
			log "U-boot versions are different - performing upgrade/downgrade"
			change_version_uboot
		fi
	else
		log "Downgrade/upgrade is not neccessary, u-boot versions are the same"
	fi
}

__main(){
	while getopts "hrv" name; do

		case $name in
			h)
				HELP=1
				;;
			r)
				RECONFIG=1
				;;
			v)
				VERIFY=1
				;;
			*)
				log "Bad option!"
				exit 255
				;;
		 esac
	done

	#display help when parameter was given
	if (( HELP == 1 )); then
			print_help
			exit 0
	fi
	check_module
	check_support_and_find_uboot_and_fpga
	get_and_compare_uboot_versions
	if [[ $FPGA_FILENAME != "" ]]; then
		check_fpga
	fi
}

__main "$@"
