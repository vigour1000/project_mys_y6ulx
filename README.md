
================= mys_y6ulx development instrction ==================


米尔 mys_y6ull 开发板代码，本 Repositories 所有代码适用于米尔 mys_y6ull 开发板。

运行环境：host: intel x86_64  ubuntu 18.04 lts ，target：米尔 mys_y6ull 开发板 / soc：NXP imx6ull,arm cortex a7 



================================ 目录结构 ===========================

目录中的可执行文件 mys_build.sh 是一键编译打包工具集，需要在 root 用户下使用

目录 driver 是自己写的驱动代码，有一些实例代码，主要是自己实验代码，包括调试过程的代码

目录 gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf 内是 linaro 的交叉编译工具集 for armhf 的

目录 MYiR-iMX-Linux 是米尔开发板内核源码

目录 MYiR-iMX-uboot 是米尔开发板 bootloader 源码

目录 application 是应用程序，主要是测试驱动的应用程序

目录 nfs_rootfs 是米尔开发板使用 nfs 启动的跟目录

目录 sdcard 包含完整的 SD 启动需要的所有文件，含 uboot,boot.scr,kernel,linux_headers,modules,rootfs. 这个目录下的文件主要是烧录 SD 卡启动板子用到的，和 nfs 目录是二选一，或者用 sd 启动或者用 nfs 启动

目录 debian9.8_root 是根文件系统，armhf 架构的根目录文件系统

目录 note_robe 是自己源码分析文件

目录 u-boot-2019.04 是 uboot 官网的源码，移植到米尔 mys_y6ulx 开发板



============================== 使用方法 ==============================

clone本目录后，即可使用一键编译工具生成米尔 mys_y6ull 开发板运行需要的所有文件，可以烧录 SD 卡启动，还可以 nfs 启动。

一键编译工具集也可以编译 application 目录中的应用程序代码，

一键编译工具集也可以编译 driver 目录中的驱动程序(armhf架构下的驱动)。



