---
title: ZYNQ移植ubuntu18.04
date: 2019-03-11 09:30:04
declare: true
tags: [ZYNQ,ubuntu 移植,嵌入式开发]
---
由于工作原因，需要在xilinx zynq7000系列的SOC上移植ubuntu 18.04，在此，记录移植过程。

操作系统: Ubuntu 18.04 LTS
开发板  : MYIR Z-turn Board

<!-- more -->

## 1.下载根文件系统
首先创建工作路径:
```bash
$ mkdir -p ~/ubuntu_rootfs
$ cd ~/ubuntu_rootfs
$ mkdir -p tmp
```

下载根文件系统,这里我用的是官方的下载地址,如果下载速度很慢,也可以从[清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/)下载对应版本.由于我们的开发板是arm平台,所以下载 [ubuntu-base-18.04-core-armhf.tar.gz](https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cdimage/ubuntu-base/releases/18.04.4/release/ubuntu-base-18.04-base-armhf.tar.gz).
***注意:下载完成后一定要用root权限解压,且务必解压到linux的分区,否则最终生成的版本在使用过程中会出现各种问题!!!***

```bash
$ sudo su
$ tar -xvf ubuntu-base-18.04-core-armhf.tar.gz -C ~/ubuntu_rootfs/tmp
```
解压后得到:
```bash
$ ls tmp/
bin   dev  home  media  opt   root  sbin  sys  var
boot  etc  lib   mnt    proc  run   srv   tmp  usr
```

<br/>

## 2.安装qemu-user-static工具
关于QEMU可参考百度百科的简介:[QEMU](https://baike.baidu.com/item/QEMU/1311178?fr=aladdin).

```bash
$ apt-get install qemu-user-static
```
拷贝qemu-arm-static到刚刚解压出来的目录
```bash
$ cp $(which qemu-arm-static) ~/ubuntu_rootfs/tmp/usr/bin
```

<br/>

## 3.网络配置
修改根文件系统的软件源

```bash
$ cd ~/ubuntu_rootfs/tmp
$ sudo gedit etc/apt/source.list
```

我这里用的是清华大学的软件源
```bash
# deb cdrom:[Ubuntu 18.04 LTS _Xenial Xerus_ - Release amd64 (20160420.1)]/ xenial main restricted
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial main restricted
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-updates main restricted
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial universe
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-updates universe
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-updates multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-backports main restricted universe multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-security main restricted
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-security universe
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ xenial-security multiverse
```

为了制作成功的根文件系统能够联网,可以直接拷贝本机的dns配置文件到根文件系统的相应位置
```bash
$ sudo cp /etc/resolv.conf etc/resolv.conf
```

<br/>

## 4.挂在根文件系统并chroot
我的挂载过程使用shell脚本实现的,具体内容如下:
```bash
#!/bin/bash
function mnt() {
    echo "MOUNTING"
    sudo mount -t proc /proc ${2}proc
    sudo mount -t sysfs /sys ${2}sys
    sudo mount -o bind /dev ${2}dev
    sudo mount -o bind /dev/pts ${2}dev/pts        
    sudo chroot ${2}
}
function umnt(){
    echo "UNMOUNTING"
    sudo umount ${2}proc
    sudo umount ${2}sys
    sudo umount ${2}dev/pts
    sudo umount ${2}dev
}
if [ "$1" == "-m" ] && [ -n "$2" ] ;
then
    mnt $1 $2
elif [ "$1" == "-u" ] && [ -n "$2" ];
then
    umnt $1 $2
else
    echo ""
    echo "Either 1'st, 2'nd or bothparameters were missing"
    echo ""
    echo "1'st parameter can be one ofthese: -m(mount) OR -u(umount)"
    echo "2'nd parameter is the full pathof rootfs directory(with trailing '/')"
    echo ""
    echo "For example: mount -m/media/sdcard/"
    echo ""
    echo 1st parameter : ${1}
    echo 2nd parameter : ${2}
fi
```

挂载步骤:
```bash
$ sudo ./mount.sh -m ~/ubuntu_rootfs/tmp/
```

卸载步骤:
```bash
$ sudo ./mount.sh -u ~/ubuntu_rootfs/tmp/
```

<br/>

## 5.安装软件
首先需要更新软件源:
```bash
$ apt-get update
```

由于ubuntu core只包含最基础的软件,所以需要自行安装常用的软件
```bash
$ apt-get install python3 wireless-tools vim sudo net-tools iputils-ping iproute2
$ apt-get -y install udev
```

还需要安装图形操作界面,我安装的是xfce4:
```bash
$ apt-get install xinit //startx
$ apt-get install xdm //环境管理器
$ apt-get install xfce4 //桌面环境
```
恢复Xfce4的默认配置
```bash
$ rm ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
```

安装包管理器 网卡管理模块
```bash
$ apt-get install synaptic
$ apt-get install ifupdown
```

添加中文支持
```bash
$ apt-get install language-pack-zh-hant language-pack-zh-hans
$ apt install -y --force-yes --no-install-recommends fonts-wqy-microhei
$ apt install -y --force-yes --no-install-recommends ttf-wqy-zenhei
然后
$ dpkg-reconfigure locales
选zh UTF-8
$ locale-gen en_US.UTF-8
```

安装Chrome
```bash
$ apt-get install chromium-browser chromium-browser-l10n
遇到chrome unlock keyring
$ apt install seahorse
终端输入 seahorse 然后点击Default lock,设置旧密码后,新密码不输入直接确认,可以解决此问题
```


图形界面的开启与关闭
```bash
取消自启
$ update-rc.d -f gdm remove

恢复自启
$ update-rc.d gdm defaults
```

<br/>

## 6.用户配置
首先设置root密码:
```bash
$ passwd root
```

添加用户:
```bash
$ adduser ubuntu
```

给新添加的用户分配权限:
```bash 
$ vi /etc/sudoers
在"root ALL=(ALL) ALL"这一行下面添加:
ubuntu ALL=(ALL) ALL
```

<br/>

## 7.配置串口
必须配置串口,否则挂载文件系统后,超级终端会没有输出
```bash
$ vi /etc/init/ttyPS0.conf
```
这个文件将在启动时通过UART端口生成一个控制台,我们需要将该文件的内容修改为如下所示:
```bash
start on stopped rc or RUNLEVEL=[12345]
stop on runlevel [!12345]

respawn
exec /sbin/getty -L 115200 ttyPS0 vt102
```
我们还需要编辑 /etc/fstab 文件，以便在启动时挂载我们的根文件系统.我们的 /etc/fstab 文件应如下所示:
```bash
/dev/mmc.blk0p2 / ext4    relatime,errors=remount-ro  0   1
```

以上操作全部完成后,退出文件系统:
```bash
$ exit
```

卸载根文件系统:
```bash
$ sudo ./mount.sh -u ~/ubuntu_rootfs/tmp/
```
