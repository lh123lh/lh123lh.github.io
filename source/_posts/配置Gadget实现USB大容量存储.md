---
title: 配置Gadget实现USB大容量存储
copyright: true
date: 2020-06-15 15:33:23
tags: [ZYNQ,ubuntu 移植,嵌入式开发]
---
在开发板上USB端口默认都是HOST模式,但是很多用户需要将USB配置成Peripheral模式(模拟U盘),在此记录配置过程.

操作系统: Ubuntu 18.04 LTS
开发板  : MYIR Z-turn Board

<!-- more -->

## 1.内核配置

```bash
$ make menuconfig:
    Device Drivers
    USB support
        <*> ChipIdea Highspeed Dual Role Controller
        <*> ChipIdea device controller
        <*> USB Gadget Support
            <M> USB functions configurable through configfs
                [*] Mass storage
            <M> USB Gadget precomposed configurations
                <M> Mass Storage Gadget
```

## 2.设备树配置

```bash
    usb_0: usb@e0002000 {
         compatible = "xlnx,zynq-usb-2.20.a", "chipidea,usb2";
         clocks = <&clkc 28>;
         dr_mode = "peripheral";
         interrupt-parent = <&intc>;
         interrupts = <0 21 4>;
         reg = <0xe0002000 0x1000>;
         usb-phy = <&usb_phy0>;
     };
```

## 3.编译

```bash
$ make uImage
$ make dtb
$ make modules:
    需要用到这几个模块: libcomposite.ko usb_f_mass_storage.ko g_mass_storage.ko
```

## 4.使用

```bash
$ insmod libcomposite.ko
$ insmod usb_f_mass_storage.ko
$ insmod g_mass_storage.ko file=/dev/mmcblk0 removable=1
```

输出以下信息则表示配置成功:
```bash
Mass Storage Function, version: 2009/09/11
LUN: removable file: (no medium)
LUN: removable file: /dev/mmcblk0
Number of LUNs=1
g_mass_storage gadget: Mass Storage Gadget, version: 2009/09/11
g_mass_storage gadget: userspace failed to provide iSerialNumber
g_mass_storage gadget: g_mass_storage ready
```

驱动加载成功后即可将开发板的USB口与电脑连接查看效果.
