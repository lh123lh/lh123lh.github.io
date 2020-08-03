---
title: GST使用笔记
copyright: true
permalink: 1
top: 0
date: 2020-07-28 13:45:01
tags: [ZYNQ, Video, 嵌入式开发]
categories:
password:
---
这段时间在Mpsoc平台调试了MIPI 摄像头,在此记录下如何使用gst(gstreamer 1.0)工具直接在DP端口上显示摄像头采集的视频或者通过网络流传输到PC显示.

操作系统: Ubuntu 18.04 LTS
开发板  : MYIR Fx3
开发工具: PetaLinux 2019.1

<!-- more -->

## 1.安装GST-1.0版本

执行以下命令配置rootfs:

```bash
$ petalinux-config -c rootfs:
    Petalinux Package Groups -->
        packagegroup-petalinux-gstreamer -->
            packagegroup-petalinux-gstreamer
```

这样算是勾选了Xilinx集成好的gst工具,但是这套工具默认不会安装x264编解码的插件,还需要另行配置:

**a.确保<Petalinux installed directory>/components/yocto/source/aarch64/layers/core/meta/recipes-multimedia/gstreamer目录下有“gst-plugins-ugly-1.14.4.bb”这个文件**
**b.在<petalinux-project-root>/project-spec/meta-user/recipes-core/images/petalinux-image.bbappend文件中添加以下内容:**

```bash
        IMAGE_INSTALL_append = " gstreamer1.0-plugins-ugly"
```

**c.在<petalinux-project-root>/project-spec/meta-user/conf/layer.conf中添加以下内容:**

```bash
    PACKAGECONFIG_append_pn-gstreamer1.0-plugins-ugly = " x264"
```

**d.在<petalinux-project-root>/project-spec/meta-user/conf/petalinuxbsp.conf中添加以下内容:**

```bash
    LICENSE_FLAGS_WHITELIST_append = "commercial"
```

*如果不添加这个会报错:*

```bash
    gstreamer1.0-libav was skipped: because it has a restricted license not whitelisted in LICENSE_FLAGS_WHITELIST
```

**e.重新运行petalinux-config -c rootfs命令,选择:**

```bash
    $ petalinux-config -c rootfs:
        user packages -->
            gstreamer1.0-plugins-ugly
```

## 2.视频流测试

**小球测试,验证gst功能是否正常:**

```bash
gst-launch-1.0 -v videotestsrc pattern=ball name=left ! fbdevsink  
```

注意:在ZYNQMP平台上,只能用fbdevsink这个sink,使用autovideosink无效.
**通过DP口显示视频流:**

```bash
gst-launch-1.0 v4l2src device=/dev/video1 ! 'video/x-raw,width=1920,height=1080,framerate=30/1' ! queue2 ! videorate ! videoscale ! videoconvert ! fbdevsink
```

**全屏显示:**

```bash
gst-launch-1.0 v4l2src device=/dev/video1 ! 'video/x-raw,width=1920,height=1080,framerate=30/1' ! queue2 ! videorate ! videoscale ! videoconvert ! kmssink bus-id=fd4a0000.zynqmp-display fullscreen-overlay=1  
```

## 3.网络流测试

**zynqMP端:**

```bash
gst-launch-1.0 v4l2src device=/dev/video1 ! video/x-raw,width=1920,height=1080,framerate=5/1 ! videorate ! videoscale ! videoconvert ! x264enc ! h264parse config-interval=-1 ! rtph264pay ! udpsink host=192.168.30.218 port=5600
```

**PC端:**
先在PC上安装[VLC播放器](https://www.videolan.org/)新建一个文件并命名为test.sdp,用文本编辑器打开并填上以下内容:

```bash
m=video 5600 RTP/AVP 96

a=rtpmap:96 H264

a=framerate:15

c=IN IP4 192.168.30.218
```

使用vlc播放器打开这个文件即可接收到zynqMP端发出的网络流

## 4.保存视频流为mp4

**使用以下命令将视频流保存到mp4文件中:**

```bash
gst-launch-1.0 v4l2src device=/dev/video1 ! video/x-raw,width=1920,height=1080,framerate=15/1 ! videoconvert ! x264enc threads=4 sliced-threads=TRUE tune=zerolatency ! matroskamux ! filesink location = output1.mp4
```
