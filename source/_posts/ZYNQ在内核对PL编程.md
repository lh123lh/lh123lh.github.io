---
title: ZYNQ在内核对PL编程
copyright: true
top: 0
date: 2019-04-08 16:53:51
tags:
    - 嵌入式开发
    - Linux
    - ZYNQ
categories:
password:
---

在zynq7000系列处理器上对PL编程有三种方式:
1.使用fsbl,将bitstream集成到boot.bin中
2.使用uboot命令
3.在linux内核中使用devcfg驱动

前两种方式很常用,也很简单,所以本文只介绍第三种方式

操作系统: Ubuntu 16.04 LTS
开发板  : MYIR Z-turn Board
内核版本: 4.14

<!-- more -->

## 1.将比特流应转换为二进制
注:这部分内容引用自[Xilinx AR#46913](https://china.xilinx.com/support/answers/46913.html)
使用SDK里的bootgen工具可完成此操作,BootGen 工具使用“BIF”输入文件,它可描述引导映像的结构.

### BIF 文件示例:
    the_ROM_image:
    {
        [bootloader]<fsbl_name>.elf
        <pl_bitstream_name>.bit
        <u-boot_name>.elf
    }

在SDK中打开shell,执行以下命令即可将bitstream转换为bin:
```
$ bootgen -image fsbl.bif -w -process_bitstream bin
```
完成后即可在bitstream所在目录找到对应的bin文件

## 2.配置linux kernel
### 在menuconfig中依次选择以下选项:
    Device Drivers → FPGA Configuration Framework
    Device Drivers → FPGA Configuration Framework → FPGA Bridge Framwork
    Device Drivers → FPGA Configuration Framework → FPGA Region
    Device Drivers → Device Tree overlays → Device Tree Overlays ConfigFS interface

具体配置详情可参见[Xilinx wiki](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841645/Solution+Zynq+PL+Programming+With+FPGA+Manager)

## 3.对PL编程

### 3.1 使用sysfs接口
```
$ mkdir -p /lib/firmware/
$ cp design_1_wrapper.bit.bin /lib/firmware
$ echo 8 > /sys/class/fpga_manager/fpga0/flags
$ echo design_1_wrapper.bit.bin > /sys/class/fpga_manager/fpga0/firmware
```

### 3.2 使用fpgautil工具
[fpgautil](https://xilinx-wiki.atlassian.net/wiki/download/attachments/18841847/fpgautil.c?version=2&modificationDate=1549947129137&cacheVersion=1&api=v2)是xilinx官方为MPSOC提供的工具,但是在zynq7000上也可以使用.
```
$ fpgautil -b ./design_1_wrapper.bit.bin
```