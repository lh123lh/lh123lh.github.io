---
title: ZYNQ 7000 CAN调试记录
copyright: true
permalink: 1
top: 0
date: 2019-03-26 08:50:36
tags:
    - 嵌入式开发
    - Linux
    - ZYNQ
categories:
password:
---

在zynq 7000平台CAN调试过程中,遇到了一些问题,在参阅xilinx Wiki后,顺利调通,故将调试过程记录下来以备后用

操作系统: Ubuntu 16.04 LTS
开发板  : MYIR Z-turn Board

<!-- more -->

## 1.说明
CAN是控制器局域网络(Controller Area Network, CAN)的简称,是由以研发和生产汽车电子产品著称的德国BOSCH公司开发的,并最终成为国际标准（ISO 11898）,是国际上应用最广泛的现场总线之一.详情请参考[百科](https://baike.baidu.com/item/CAN%E6%80%BB%E7%BA%BF/297754?fr=aladdin)

## 2.linux kernel和devicetree的配置
### 2.1 Linux kernel配置
在linux kernel中,Xilinx CAN 驱动默认是disable状态,按照下图打开对应选项即可:
![avatar](../../../../images/Xilinx_CAN_Kernel_config.png)

### 2.2 Devicetree配置
通过查阅相关文档,Xilinx CAN driver在Devicetree中的配置如下:
```bash
zynq_can_0: can@e0008000 {
    compatible = "xlnx,zynq-can-1.0";
    clocks = <&clkc 19>, <&clkc 36>;
    clock-names = "can_clk", "pclk";
    reg = <0xe0008000 0x1000>;
    interrupts = <0 28 4>;
    interrupt-parent = <&intc>;
    tx-fifo-depth = <0x40>;
    rx-fifo-depth = <0x40>;
};
```

## 3.canutils和iproute2的编译以及使用
### 3.1 canutils工具的交叉编译
下载源码:
[libsocketcan-0.0.11.tar.gz](https://public.pengutronix.de/software/libsocketcan/libsocketcan-0.0.11.tar.bz2)
[canutils-4.0.6.tar.gz](https://public.pengutronix.de/software/socket-can/canutils/v4.0/canutils-4.0.6.tar.bz2)

交叉编译libsocketcan:
```bash
$ cd libsocketcan-0.0.11
$ ./configure CC=arm-linux-gnueabihf-gcc --host=arm-linux-gnueabihf --prefix=$(pwd)/install
$ make -j4
$ make install
```

交叉编译canutils:
```bash
$ cd canutils-4.0.6
$ ./configure CC=arm-linux-gnueabihf-gcc --host=arm-linux-gnueabihf --prefix=$(pwd)/install libsocketcan_LIBS=-lsocketcan LDFLAGS="-L/home/Codes/libsocketcan-0.0.11/install/lib/" libsocketcan_CFLAGS="-I/home/Codeslibsocketcan-0.0.11/install/include/"
$ make -j4
$ make install
```

### 3.2 iproute2工具的交叉编译

下载源码:
[iproute2-4.9.0.tar.gz](https://mirrors.edge.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.9.0.tar.gz)

首先修改源码根目录下的Makefile:
```bash
将CC那一行改为:
CC := arm-linux-gnueabihf-gcc
```

交叉编译:
```bash
$ make -j4
```
编译过程可能会出错,但是我们需要用到的ip工具已编译出来,其它工具并不需要,所以忽略错误即可

### 3.3测试CAN的功能
以下调试过程摘抄自[Xilinx Wiki](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842496/Linux+CAN+driver),经过验证,此方法可行
```bash
1. Set bit-timing
Can supports bitrates upto 1Mb/s. Xilinx CAN h/w and driver supports these bit rates
Note: Triple sampling is not supported by Xilinx CAN H/W. 
$ ./ip link set can0 type can bitrate 200000
or
$ ./canconfig can0 bitrate 200000
2. Bring up the device
$ ./ip link set can0 up
or
$ ./canconfig can0 start
3. Bring down the device
$ ./ip link set can0 down
or
$ ./canconfig can0 stop
4. Transmit and receive packets with standard id number
$ ./cansend can0 -i 0x14 <bytes>
$ ./candump can0
5. Transmit and receive packets with extended id number (--loop argument here)
$ ./cansend can0 -i 0x333 <bytes>
$ ./candump can0
6. Loopback mode
$ ./canconfig can0 ctrlmode loopback on 
7. Checking link state (checking bitrate/errors/packets)
$ ./ip -d -s link show can0
8. Checking net device state
$ ifconfig can0
9. Getting statistics via proc
$ cat /proc/net/can/stats
10. Socket CAN core uses several filter lists to deliver received CAN frames to CAN protocol modules. These
receive lists, their filters and the count of filter matches can be checked in the appropriate receive list. All entries contain the
device and a protocol module identifier:
$ cat /proc/net/can/rcvlist_all
rcvlist_all - list for unfiltered entries (no filter operations)
rcvlist_eff - list for single extended frame (EFF) entries
rcvlist_err - list for error message frames masks
rcvlist_fil - list for mask/value filters
rcvlist_inv - list for mask/value filters (inverse semantic)
rcvlist_sff - list for single standard frame (SFF) entries
```