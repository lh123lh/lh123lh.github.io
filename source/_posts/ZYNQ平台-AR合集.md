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