--必须在这个位置定义PROJECT和VERSION变量
--PROJECT：ascii string类型，可以随便定义，只要不使用,就行
--VERSION：ascii string类型，如果使用Luat物联云平台固件升级的功能，必须按照"X.X.X"定义，X表示1位数字；否则可随便定义
PROJECT = "RKL Library DEMO"
VERSION = "0.0.1"
--加载日志功能模块，并且设置日志输出等级
--如果关闭调用log模块接口输出的日志，等级设置为log.LOG_SILENT即可
require "log"
LOG_LEVEL =log.LOGLEVEL_TRACE -- log.LOGLEVEL_WARN LOGLEVEL_TRACE
--log.openTrace(false)
--[[
如果使用UART输出日志，打开这行注释的代码"--log.openTrace(true,1,115200)"即可，根据自己的需求修改此接口的参数
如果要彻底关闭脚本中的输出日志（包括调用log模块接口和Lua标准print接口输出的日志），执行log.openTrace(false,第二个参数跟调用openTrace接口打开日志的第二个参数相同)，例如：
1、没有调用过sys.opntrace配置日志输出端口或者最后一次是调用log.openTrace(true,nil,921600)配置日志输出端口，此时要关闭输出日志，直接调用log.openTrace(false)即可
2、最后一次是调用log.openTrace(true,1,115200)配置日志输出端口，此时要关闭输出日志，直接调用log.openTrace(false,1)即可
]]
--log.openTrace(true,1,115200)

require "rtos"
require "sys"
require "net"
require "misc"
require "console"

--每1分钟查询一次GSM信号强度
--每1分钟查询一次基站信息
net.startQueryAll(60000, 60000)


require "netLed"
pmd.ldoset(2,pmd.LDO_VLCD)
netLed.setup(true,pio.P0_1,pio.P0_4)
--网络指示灯功能模块中，默认配置了各种工作状态下指示灯的闪烁规律，参考netLed.lua中ledBlinkTime配置的默认值
--如果默认值满足不了需求，此处调用netLed.updateBlinkTime去配置闪烁时长
--LTE指示灯功能模块中，配置的是注册上4G网络，灯就常亮，其余任何状态灯都会熄灭


--**************************************************************
--            以下为RKL Library DEMO 关键代码
--**************************************************************

--打开控制台服务，如果不开启则无法通过串口工具执行ping参数
console.setup(1, 115200) 

require "RKL_pubip" --公网IP获取   [RKL Library]
require "RKL_ping"  --UDPPing服务  [RKL Library]

--在串口工具上连接到开发板的串口1执行以下命令即可测试开发板到指定服务器
--的网络连接质量.
-- 开始测试命令:  print(RKL_ping.Start("你的服务器IP",4000,32)) 
-- 停止测试命令:  print(RKL_ping.Stop()) 

--RKL_ping.Start("10.0.0.1",4000,1024) --开始PING
--RKL_ping.Stop()  --关闭PING

--执行 RKL_pubip.getip() --则可以获取自身的公网IP地址
--**************************************************************



--启动系统框架
sys.init(0, 0)
sys.run()
