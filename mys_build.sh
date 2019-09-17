#!/bin/bash

# var
pwd_path=$(pwd)
uboot_dir=${pwd_path}/MYiR-iMX-uboot
uboot_config=mys_imx6ull_14x14_emmc_defconfig
uboot_file=${uboot_dir}/u-boot.imx

uboot_test_dir=${pwd_path}/uboot_test
output=output
verbose=1

kernel_dir=${pwd_path}/MYiR-iMX-Linux
kernel_config=mys_imx6_defconfig
kernel_config_file=${kernel_dir}/arch/arm/configs/${kernel_config}
kernel_file=${kernel_dir}/arch/arm/boot/zImage

dtbs_file=${kernel_dir}/arch/arm/boot/dts/mys-imx6ull-14x14-evk-emmc.dtb

boot_script=${pwd_path}/boot.script.NFS
boot_scr=${pwd_path}/boot.scr

debian_rootfs_tar=${pwd_path}/debian9.8_root.tar 

sd_dev=/dev/sdb
mount_p=/mnt/sdb

nfs_rootfs=${pwd_path}/nfs_rootfs
 


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
function uboot_test_distclean()
{
	pushd ${uboot_test_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} distclean O=${output} V=${verbose}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper O=${output} V=${verbose}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} distclean
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
	echo_g "uboot distclean OK!"
	popd
}

function uboot_test_build()
{
	pushd ${uboot_test_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  ${uboot_config} O=${output} V=${verbose}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  O=${output} V=${verbose} -j1 
	echo_g "build uboot OK!"
	popd
}

# kernel build
function kernel_distclean()
{
	pushd ${kernel_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} distclean
	echo_g "kernel distclean OK!"
	popd
}

function kernel_config()
{
	pushd ${kernel_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  ${kernel_config}
	popd
}

function kernel_menuconfig()
{
	kernel_config
	pushd ${kernel_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} menuconfig && sync && cp .config ${kernel_config_file}
	popd
}

function kernel_build()
{
	kernel_config
	pushd ${kernel_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  ${multi_thread} zImage
	echo_g "build zImage OK!"
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  ${multi_thread} dtbs
	echo_g "build dtbs OK! "
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  ${multi_thread} modules
	echo_g "build modules OK!"
	popd
}

#==============
function xxxxxxxx()
{
	ARCH=arm CROSS_COMPILE=/datadisk/tools/gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf- make  modules
}

# boot.src build
function boot_src_buuild()
{
	${uboot_dir}/tools/mkimage -A arm -T script -O linux -d ${boot_script} ${boot_scr}
}


# sd card build
function sdcard_build()	
{
	sudo dd if=${uboot_file} of=${sd_dev}  bs=1k seek=1
	
	sudo mount ${sd_dev}1 ${mount_p}1
	sudo mount ${sd_dev}2 ${mount_p}2
	
	sudo rm -rf ${mount_p}1/* ${mount_p}2/* 
	
	sudo mkdir ${mount_p}1/boot
	sudo cp ${boot_scr} ${mount_p}1/
	echo_g "copy ${boot_scr} OK!"
	sudo cp -rf ${kernel_file} ${mount_p}1/boot/
	echo_g "copy ${kernel_file} OK!"
	sudo cp -rf ${dtbs_file} ${mount_p}1/boot/
	echo_g "copy ${dtbs_file} OK!"	
	
	sudo mkdir -p ${mount_p}2/usr
	
	pushd ${kernel_dir}
	sudo make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules_install INSTALL_MOD_PATH=${mount_p}2
	echo_g "install modules OK!"
	sudo make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} headers_install INSTALL_HDR_PATH=${mount_p}2/usr
	echo_g "install headers OK!"
	
	sudo tar xvf ${debian_rootfs_tar} -C ${mount_p}2
	
	sync
	popd	
	sudo umount ${sd_dev}{1,2}
	echo_g "build zImage OK! press any key to continue!"
}

function sdcard_burn_uboot()	
{
	sudo dd if=${uboot_file} of=${sd_dev}  bs=1k seek=1
}

function nfs_rootfs_build()	
{
	sudo rm ${nfs_rootfs}
	sync
	sudo mkdir ${nfs_rootfs}
	sudo tar xvf ${debian_rootfs_tar} -C ${nfs_rootfs}
	echo_g "build ${nfs_rootfs} OK!"
	sudo cp -rf ${kernel_file} ${nfs_rootfs}/boot/
	echo_g "copy ${kernel_file} OK!"
	sudo cp -rf ${dtbs_file} ${nfs_rootfs}/boot/
	echo_g "copy ${dtbs_file} OK!"	
	
	sudo mkdir -p ${nfs_rootfs}/usr
	
	pushd ${kernel_dir}
	sudo make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules_install INSTALL_MOD_PATH=${nfs_rootfs}/
	echo_g "install modules OK!"
	sudo make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} headers_install INSTALL_HDR_PATH=${nfs_rootfs}/usr
	echo_g "install headers OK!"
	sync
	popd	
	echo_g "build zImage OK! press any key to continue!"
}

function kernel_modules_rebuild()	
{
	sudo cp -rf ${kernel_file} ${nfs_rootfs}/boot/
	echo_g "copy ${kernel_file} OK!"
	
	sudo mkdir -p ${nfs_rootfs}/usr
	
	sudo rm -rf ${nfs_rootfs}/lib/modules
	
	pushd ${kernel_dir}
	sudo make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules_install INSTALL_MOD_PATH=${nfs_rootfs}/
	echo_g "install modules OK!"
	sudo make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} headers_install INSTALL_HDR_PATH=${nfs_rootfs}/usr
	echo_g "install headers OK!"
	popd	
	echo_g "build zImage OK! press any key to continue!"
}


function all_sdcard_rebuild()
{
	uboot_distclean
	uboot_build
	kernel_distclean
	kernel_build
	boot_src_buuild
	sdcard_build
 }

function all_nfs_rootfs_rebuild()
{
	uboot_distclean
	uboot_build
	kernel_distclean
	kernel_config
	kernel_build
	boot_src_buuild
	nfs_rootfs_build
}
 
function all_nfs_rootfs_not_uboot_rebuild()
{
	# uboot_distclean
	# uboot_build
	kernel_distclean
	kernel_config
	kernel_build
	# boot_src_buuild
	nfs_rootfs_build
}

function all_modules_kernel_rebuild()
{
	kernel_distclean
	kernel_config
	kernel_build
	kernel_modules_rebuild
}

function driver_build()
{
	pushd ${pwd_path}/driver
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} clean
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
#	cp robe_device.ko ${nfs_rootfs}/lib/modules/4.1.15+/
#	cp robe_driver.ko ${nfs_rootfs}/lib/modules/4.1.15+/
	cp robe_driver.ko ${nfs_rootfs}/root/
	popd
}

function app_build_for_arm()
{
	pushd ${pwd_path}/application
	make arm
	cp robe_app_arm ${nfs_rootfs}
	popd
}

function app_build_for_x86_64_and_run()
{
	pushd ${pwd_path}/application
	make x86_64
	echo "====================run"
	./robe_app_86_64
	echo "====================end"
	popd
}

function DTS_build_and_copy_to_nfs()
{
	kernel_config
	pushd ${kernel_dir}
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}  ${multi_thread} dtbs
	echo_g "build dtbs OK! "
	sudo cp -rf ${dtbs_file} ${nfs_rootfs}/boot/
	echo_g "copy ${dtbs_file} OK!"	
	popd
}

# ================
# uboot_distclean
# uboot_build
# kernel_distclean
# kernel_config
# kernel_menuconfig
# kernel_build
# boot_src_buuild
# sdcard_build
# nfs_rootfs_build
# all_sdcard_rebuild
# all_nfs_rootfs_rebuild
# kernel_modules_rebuild

# =================================================USER INTERFACES
# onekey build menu. CLI UI
function menu()
{
	echo_w [1] uboot_distclean
	echo_w [2] uboot_build
	echo_w [21] uboot_distclean
	echo_w [22] uboot_build
	echo_w [3] kernel_distclean
	echo_w [4] kernel_build 
	echo_w [5] boot_src_buuild
	echo_w [6] sdcard_build
	echo_w [61] sdcard_burn_uboot
	echo_w [7] all_sdcard_rebuild
	echo_w [8] nfs_rootfs_build
	echo_w [9] all_nfs_rootfs_rebuild
	#==============
	echo_w [a] kernel_menuconfig
	echo_w [b] all_nfs_rootfs_not_uboot_rebuild
	echo_w [c] all_modules_kernel_rebuild
	echo_w [d] driver_build
	echo_w [e] app_build_for_arm
	echo_w [f] app_build_for_x86_64_and_run
	echo_w [g] DTS_build_and_copy_to_nfs
}

function do_something()
{
	menu
	read -p "please select: " ANSWER
	if [[ $ANSWER == "1" ]]; then uboot_distclean;fi
	if [[ $ANSWER == "2" ]]; then uboot_build;fi
	if [[ $ANSWER == "21" ]]; then uboot_test_distclean;fi
	if [[ $ANSWER == "22" ]]; then uboot_test_build;fi
	if [[ $ANSWER == "3" ]]; then kernel_distclean;fi
	if [[ $ANSWER == "4" ]]; then kernel_build;fi
	if [[ $ANSWER == "5" ]]; then boot_src_buuild;fi
	if [[ $ANSWER == "6" ]]; then sdcard_build ;fi
	if [[ $ANSWER == "61" ]]; then sdcard_burn_uboot ;fi
	if [[ $ANSWER == "7" ]]; then all_sdcard_rebuild;fi
	if [[ $ANSWER == "8" ]]; then nfs_rootfs_build;fi
	if [[ $ANSWER == "9" ]]; then all_nfs_rootfs_rebuild;fi
	#================
	if [[ $ANSWER == "a" ]]; then kernel_menuconfig;fi
	if [[ $ANSWER == "b" ]]; then all_nfs_rootfs_not_uboot_rebuild;fi
	if [[ $ANSWER == "c" ]]; then all_modules_kernel_rebuild;fi
	if [[ $ANSWER == "d" ]]; then driver_build;fi
	if [[ $ANSWER == "e" ]]; then app_build_for_arm;fi
	if [[ $ANSWER == "f" ]]; then app_build_for_x86_64_and_run;fi
	if [[ $ANSWER == "g" ]]; then DTS_build_and_copy_to_nfs;fi
}

do_something

