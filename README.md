RKL Library 开源库  
============

&emsp;&emsp;

#### 一、简介
  RKL Library开源库是建立在合宙Air724U(展锐8910芯片)模块openLuat:[Luat_4G_RDA_8910](https://github.com/openLuat/Luat_4G_RDA_8910)基础库下，专门为Luat 4G物联网设备提供调用的Lua库，使用它可以节省开发时间简化开发流程。


#### 二、如何使用DEMO
#####1.首先克隆库到你的本地：
```
git clone https://github.com/codegame/RKL.git
```
#####2.完成后大概的结构是：
```

RKL 
  |----RKLlib
  |         |---lmath.lua
  |         |---RKL_ping.lua
  |         |---RKL_pubip.lua
  |
  |----Demo
  |       |---pubip_udpping
  |                       |----main.lua
  |
  |----Tools
  |         |---commtools.rar
  |
  |
  |----README.md

```
#####3.使用固件下载工具LuatTools把RKLlib目录和Demo\pubip_udpping\main.lua添加到项目管理里烧写。

#####4.使用串口工具调试工具commtools.rar设置好串口号和波特率为115200打开后输入ping命令即可观察到网络连接质量。
Ping开始：
`
 print(RKL_ping.Start("你的服务器IP",4000,32)) 
`

Ping停止：
`
 print(RKL_ping.Stop()) 
`

&emsp;&emsp;
#### 三、如何使用到我的项目
把库文件夹RKLlib拷贝到你的项目目录下，然后在你的项目代码中调用相应需要的API函数。同时在进行烧写的时候添加RKLlib整个目录即可。

&emsp;&emsp;


#### 四、固件下载工具

> [LuatTools v2](http://openluat-luatcommunity.oss-cn-hangzhou.aliyuncs.com/attachment/20200808182655634_Luatools_v2.exe)

&emsp;&emsp;
