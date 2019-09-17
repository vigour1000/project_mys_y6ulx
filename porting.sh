#!/bin/bash

# var
pwd_path=$(pwd)
uboot_dir=${pwd_path}/u-boot-2019.04
uboot_config=mx6ull_14x14_evk_defconfig
uboot_file=${uboot_dir}/u-boot-dtb.imx
# uboot_file=${uboot_dir}/u-boot.imx

output=output
verbose=2

robe_uboot_config=robe_mys_y6ulx_defconfig
robe_uboot_config_backup=${uboot_dir}/configs/${robe_uboot_config}
boot_script=${uboot_dir}/../boot.script.SDCARD
boot_scr=${uboot_dir}/../boot.scr
robe_output=
robe_verbose=2

sd_dev=/dev/sdb



# linux-4.19.57
linux_dir=${pwd_path}/linux-4.19.57
robe_linux_config=robe_mys_y6ull_defconfig
robe_output1=
robe_verbose1=2
robe_linux_config_backup=${linux_dir}/arch/arm/configs/${robe_linux_config}

robe_linux_image=${linux_dir}/arch/arm/boot/zImage




# env
ARCH=arm
# CROSS_COMPILE=${pwd_path}/gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
CROSS_COMPILE=${pwd_path}/gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
# CROSS_COMPILE=${pwd_path}/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
export ARCH CROSS_COMPILE

# setting
multi_thread=-j6

# BSP function
# notice
function echo_g()
{
	echo -ne "\e[32m"
	echo -n $*
	echo -e "\e[0m"
}

function echo_r()
{
	echo -ne "\e[31m"
	echo -n $*
	echo -e "\e[0m"
}

function echo_w()
{
	echo -ne "\e[0m"
	echo -n $*
	echo -e "\e[0m"
}

function echo_g_n()
{
	echo -ne "\e[32m"
	echo -n $*
	echo -ne "\e[0m"
}

function echo_r_n()
{
	echo -ne "\e[31m"
	echo -n $*
	echo -ne "\e[0m"
}

function echo_w_n()
{
	echo -ne "\e[0m"
	echo -n $*
	echo -ne "\e[0m"
}

function notice_pause_g()
{
	echo_g_n $*
	echo_g_n " press ENTER to continue!"
	read
}

function notice_pause_r()
{
	echo_r_n $*
	echo_r_n " press ENTER to continue!"
	read
}

function notice_pause_w()
{
	echo_w_n $*
	echo_w_n " press ENTER to continue!"
	read
}

# uboot build
function uboot_distclean()
{
	pushd ${uboot_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} distclean
	echo_g "uboot distclean OK!"
	popd
}

function uboot_build()
{
	pushd ${uboot_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  ${uboot_config}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  ${multi_thread}
	echo_g "build uboot OK!"
	popd
}

# uboot test build
function uboot_distclean_output_verbose()
{
	pushd ${uboot_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} distclean O=${output} V=${verbose}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper O=${output} V=${verbose}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} distclean
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
	echo_g "uboot distclean OK!"
	popd
}

function uboot_build_output_verbose()
{
	pushd ${uboot_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  ${uboot_config} O=${output} V=${verbose}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  O=${output} V=${verbose} ${multi_thread} 
	echo_g "build uboot OK!"
	popd
}

# robe porting uboot build =========================================================================
function robe_uboot_clean_output_verbose()
{
	pushd ${uboot_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} clean O=${robe_output} V=${robe_verbose}
	echo_g "robe uboot clean OK!"
	popd
}

function robe_uboot_mrproper_output_verbose()
{
	pushd ${uboot_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper O=${robe_output} V=${robe_verbose}
	echo_g "robe uboot mrproper OK!"
	popd
}

function robe_uboot_distclean_output_verbose()
{
	pushd ${uboot_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} distclean O=${robe_output} V=${robe_verbose}
	echo_g "robe uboot distclean OK!"
	popd
}

function robe_uboot_config_output_verbose()
{
	pushd ${uboot_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  ${robe_uboot_config}  O=${robe_output} V=${robe_verbose} && \
	echo_g "robe uboot config OK!"
	popd
}

function robe_uboot_menuconfig_output_verbose()
{
	pushd ${uboot_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} menuconfig O=${robe_output} V=${robe_verbose} && \
	echo_g "robe uboot menuconfig OK!"
	rm -rf defconfig
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} savedefconfig O=${robe_output} V=${robe_verbose}
	popd
}

function robe_uboot_config_backup_output_verbose()
{
	pushd ${uboot_dir}
	cp defconfig ${robe_uboot_config_backup} && \
	echo_g "robe defconfig backup OK!"
	popd
}

function robe_uboot_build_output_verbose()
{
	pushd ${uboot_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  O=${robe_output} V=${robe_verbose} ${multi_thread}  && \
	echo_g "robe uboot build OK!"
	popd
}

function robe_uboot_make_boot_scr_output_verbose()
{
	${uboot_dir}/tools/mkimage -A arm -T script -O linux -d ${boot_script} ${boot_scr}
	echo_g "robe boot.scr make OK!"
}

function robe_sdcard_burn_uboot()	
{
	sudo dd if=${uboot_file} of=${sd_dev}  bs=1k seek=1
}

# robe porting linux build =========================================================================
function robe_linux_distclean_output_verbose()
{
	pushd ${linux_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} distclean O=${robe_output1} V=${robe_verbose1}
	echo_g "robe linux distclean OK!"
	popd
}

function robe_linux_config_output_verbose()
{
	pushd ${linux_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  ${robe_linux_config}  O=${robe_output1} V=${robe_verbose1} && \
	echo_g "robe linux config OK!"
	popd
}

function robe_linux_menuconfig_output_verbose()
{
	pushd ${linux_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} menuconfig O=${robe_output1} V=${robe_verbose1} && \
	echo_g "robe linux menuconfig OK!"
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} savedefconfig O=${robe_output1} V=${robe_verbose1}
	popd
}

function robe_linux_config_backup_output_verbose()
{
	pushd ${linux_dir}
	cp defconfig ${robe_linux_config_backup} && \
	echo_g "robe defconfig backup OK!"
	popd
}

function robe_linux_build_output_verbose()
{
	pushd ${linux_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  O=${robe_output1} V=${robe_verbose1} ${multi_thread}  && \
	echo_g "robe linux build OK!"
	popd
}

function robe_linux_dts_build_output_verbose()
{
	pushd ${linux_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  O=${robe_output1} V=${robe_verbose1} ${multi_thread} dtbs && \
	echo_g "robe linux dts build OK!"
	popd
}

function robe_linux_modules_build_output_verbose()
{
	pushd ${linux_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  O=${robe_output1} V=${robe_verbose1} ${multi_thread} modules && \
	echo_g "robe linux dts build OK!"
	popd
}

# ================
# uboot_distclean
# uboot_build
# uboot_test_distclean
# uboot_test_build
# robe_uboot_clean_output_verbose
# robe_uboot_mrproper_output_verbose
# robe_uboot_distclean_output_verbose
# robe_uboot_config_output_verbose
# robe_uboot_menuconfig_output_verbose
# robe_uboot_config_backup_output_verbose
# robe_uboot_build_output_verbose
# robe_uboot_make_boot_scr_output_verbose
# robe_sdcard_burn_uboot
# robe_linux_distclean_output_verbose
# robe_linux_config_output_verbose
# robe_linux_menuconfig_output_verbose
# robe_linux_config_backup_output_verbose
# robe_linux_build_output_verbose
# robe_linux_dts_build_output_verbose





# =================================================USER INTERFACES
# onekey build menu. CLI UI
function menu()
{
	echo_w [1] uboot_distclean
	echo_w [2] uboot_build
	echo_w [3] uboot_distclean_output_verbose
	echo_w [4] uboot_build_output_verbose
	echo_w
	echo_w [5] robe_uboot_clean_output_verbose
	echo_w [6] robe_uboot_mrproper_output_verbose
	echo_w [7] robe_uboot_distclean_output_verbose
	echo_w [8] robe_uboot_config_output_verbose
	echo_w [9] robe_uboot_menuconfig_output_verbose
	echo_w [91] robe_uboot_config_backup_output_verbose
	echo_w [a] robe_uboot_build_output_verbose
	echo_w [a1] robe_uboot_make_boot_scr_output_verbose
	echo_w [b] robe_sdcard_burn_uboot
	echo_w
	echo_w [c] robe_linux_distclean_output_verbose
	echo_w [d] robe_linux_config_output_verbose
	echo_w [e] robe_linux_menuconfig_output_verbose
	echo_w [f] robe_linux_config_backup_output_verbose
	echo_w [g] robe_linux_build_output_verbose
	echo_w [h] robe_linux_dts_build_output_verbose
}

function do_something()
{
	menu
	read -p "please select: " ANSWER
	if [[ $ANSWER == "1" ]]; then uboot_distclean;fi
	if [[ $ANSWER == "2" ]]; then uboot_build;fi
	if [[ $ANSWER == "3" ]]; then uboot_distclean_output_verbose;fi
	if [[ $ANSWER == "4" ]]; then uboot_build_output_verbose;fi
	
	if [[ $ANSWER == "5" ]]; then robe_uboot_clean_output_verbose;fi
	if [[ $ANSWER == "6" ]]; then robe_uboot_mrproper_output_verbose;fi
	if [[ $ANSWER == "7" ]]; then robe_uboot_distclean_output_verbose;fi
	if [[ $ANSWER == "8" ]]; then robe_uboot_config_output_verbose;fi
	if [[ $ANSWER == "9" ]]; then robe_uboot_menuconfig_output_verbose;fi
	if [[ $ANSWER == "91" ]]; then robe_uboot_config_backup_output_verbose;fi
	if [[ $ANSWER == "a" ]]; then robe_uboot_build_output_verbose;fi
	if [[ $ANSWER == "a1" ]]; then robe_uboot_make_boot_scr_output_verbose;fi
	if [[ $ANSWER == "b" ]]; then robe_sdcard_burn_uboot;fi
	
	if [[ $ANSWER == "c" ]]; then robe_linux_distclean_output_verbose;fi
	if [[ $ANSWER == "d" ]]; then robe_linux_config_output_verbose;fi
	if [[ $ANSWER == "e" ]]; then robe_linux_menuconfig_output_verbose;fi
	if [[ $ANSWER == "f" ]]; then robe_linux_config_backup_output_verbose;fi
	if [[ $ANSWER == "g" ]]; then robe_linux_build_output_verbose;fi
	if [[ $ANSWER == "h" ]]; then robe_linux_dts_build_output_verbose;fi
	
	
}

do_something




