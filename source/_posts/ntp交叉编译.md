---
title: 在arm平台移植ntp
tags: 
    - 嵌入式开发
    - Linux
date: 2019-03-13 17:28:00
---

由于工作需求,需要在zynq平台使用ntp相关程序,在ntp的移植过程中遇到了一些坑,在此纪录下来

操作系统: Ubuntu 16.04 LTS
开发板  : MYIR Z-turn Board

<!-- more -->

## 1.说明
网络时间协议Network Time Protocol(NTP) 是一种确保时钟保持准确的方法。如果可以访问互联网，只需安装ntp的客户端软件到互联网上的公共ntp服务器自动修正时间即可.具体说明可参考百科[NTP](https://baike.baidu.com/item/NTP/1100433).

## 2.准备工作
由于ntp在依赖openssl库,所以在交叉编译ntp之前需要先交叉编译openssl.
***注意:新版本的ntp依赖1.1.1版本的openssl!!!***
### 2.1下载源码
[ntp-4.2.8p13.tar.gz](http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.8p13.tar.gz)
[openssl-1.1.1b.tar.gz](https://www.openssl.org/source/openssl-1.1.1b.tar.gz)

### 2.2解压源码
```bash
$ mkdir -p ~/work && cd ~/work
$ tar -xvf ntp-4.2.8p13.tar.gz
$ tar -xvf openssl-1.1.1b.tar.gz
```

## 3.移植步骤
### 3.1 交叉编译openssl
```bash
$ cd openssl-1.1.1b/
$ ./config no-asm -shared --prefix=$(pwd)/install
```

上述步骤只是生成了Makefile,还没有设置交叉编译工具链,需要手动设置.
用编辑器打开Magefile,搜索"-m64",总共找到两处,删除之.搜索"CROSS_COMPILE=",改为"CROSS_COMPILE=arm-linux-gnueabihf-".
接着进行编译:
```bash
$ make -j4
```
耐心等待一段时候后就还完成编译,继续:
```bash
$ make install
```

一段时间后就会完成.此时在当前目录下就会产生一个 install 文件夹,编译出来的产物全部在里面了.
openssl交叉编译完成.

### 3.2 交叉编译ntp
由于ntp依赖于openssl,所以先简单粗暴的将相关头文件复制到ntp源码的include文件夹下:
```bash
$ cp -rf ~/work/openssl-1.1.1b/install/include/* ~/work/ntp-4.2.8p13/include
```
接下来进行ntp的交叉编译:
```bash
$ cd ~/work/ntp-4.2.8p13/
$ ./configure CC=arm-linux-gnueabihf-gcc LDFLAGS=-L/home/liuheng/Desktop/openssl-1.1.1b/install/lib --host=arm-linux-gnueabihf --prefix=$(pwd)/install  --with-yielding-select=yes
$ make -j4
$ make install
```

耐心等待一段时间后,编译完成,编译的产物在生成的 install/ 文件夹里
