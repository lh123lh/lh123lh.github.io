---
title: ZYNQ平台_AR合集
copyright: true
permalink: 1
top: 0
date: 2020-08-13 13:59:09
tags: [ZYNQ, 嵌入式开发]
categories:
password:
---
在使用zynq/zynqMP平台的时候会遇到形形色色的问题, 在翻阅大量的资料后可能就会找到解决办法, 在此将这些问题以及解决方案记录下来以备后用.

<!-- more -->

## 问题1
**在vivado中使用HardWare Manager调试芯片会导致开发板上运行的Linux系统出现各种问题,例如死机、无法启动等等**

### 解决方案
```
1.如果是手动编译的源码,可以在bootargs里添加以下配置: clk_ignore_unused cpuidle.off=1
2.如果是使用Petalinux, 只需要在内核配置中取消勾选以下选项即可:
CPU Power Management --> 
    CPU Idle --->
        [ ] CPU idle PM support
```
注:参考自Xilinx [AR#69143](https://www.xilinx.com/support/answers/69143.html)

## 问题2
**用PetaLinux 2018.3版本编译的启动文件在启动时会报错:"MMC:   sdhci_transfer_data: Error detected in status(0x208000)!",之后系统无法正常启动**

### 解决方案
```
这个问题实际上官方之前已经发现，并且在petalinux2017.4之后的版本进行了修复[AR#69780](https://www.xilinx.com/support/answers/69780.html?tdsourcetag=s_pcqq_aiomsg)，但是修复并没有完全解决问题。在版本修复之前，问题的来源是在petalinux-config设置主SD为1后，并没有能够成功修改uboot的启动指令，故给出了AR69780中的解决方案，但是解决方案并不完美。

只需在project-spec/meta-user/recipes-bsp/u-boot/files/platform-top.h 文件的末尾加入下面的代码:
/*   fix codes  */
#ifdef CONFIG_BOOTCOMMAND
#undef CONFIG_BOOTCOMMAND
#define CONFIG_BOOTCOMMAND	"mmc dev ${sdbootdev}; run default_bootcmd"
#endif
```
