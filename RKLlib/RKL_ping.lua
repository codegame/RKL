
--***************************************************************************
--           [RKL Library]    LUAT 第三方开源库     
--           [RKL Library]    LUAT Third-party open source library             
--===========================================================================
--   
--   [Unit name]:RKL_ping.lua
--[Introduction]:PING implementation based on UDP protocol, used to detect 
--               internal network connection quality.
--    [Function]:RKL_ping.start(host,port,size) size=8~1024; RKL_ping.stop();
--      [Device]:Air724UG(RDA8910)
--        [Core]:Luat_4G_RDA_8910 V0022
--      [Author]:Reverseking  (QQ:441673604) 
--     [License]:MIT
--   
--     [History]:[+]New or Add. [-]Remove. [*]Modify. [#]BUG Fixed.
--               [+] Created the file at                2021-02-19 17:38:10.  
--     
--***************************************************************************
 
--***************************UDPPING Linux服务端搭建********************************
-- 
--                             系统[CentOS 7]
--   1.安装socat服务软件,安装命令: yum install socat 或 apt install socat
--   2.打开防火墙端口,设置命令：
--    sudo firewall-cmd --zone=public --add-port=4000/udp --permanent
--    sudo firewall-cmd --reload
--   3.开启UDP PING 服务,运行命令:
--    sudo socat -v UDP-LISTEN:4000,fork PIPE 2>/dev/null&
--   4.以上配置为4000端口，可以自行设置成其它。
--   5.PC端测试,使用udpping.py python脚本测试 udpping.py xxx.xxx.xxx.xxx 4000 LEN=32
--     其中xxx.xxx.xxx.xxx 为服务器IP地址,4000为端口号，LEN=32为包长度,范围在8~8192,
--     也就是单个PING包最大8k字节,超过可能会出错.
-- 
--*********************************************************************************

require"socket"
require "rtos"
require"lmath" --外置math库

module(...,package.seeall)

local BaseStr ={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P",
                "Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f",
                "g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v",
                "w","x","y","z","1","2","3","4","5","6","7","8","9","0","$","#"}

local PING_Host = "10.0.0.1" --PING服务端域名或IP地址string类型
local PING_Port = 4000 --PING服务端端口,string或者number类型
local PING_Size = 32 --包大小单位字节number类型

local PingCount = 0
local Udpsocket =0

--随机字符串函数,len为返回字符串长度number类型
local function Randomstr(len)
    local _RetStr =""
     for i=1,len,1 do
      local _rand= lmath.random(1,64)
      _RetStr =_RetStr..BaseStr[_rand]
     end
    return _RetStr
end


--PING服务状态机
local StatemachineIdx ="Stop" --默认状态
local Statemachine = {  
    
    ["Start"] = function() 
        log.info("RKL_ping", "Start.")
        StatemachineIdx ="Stop" 
        PingCount = 0
        if Udpsocket~=0 then
            Udpsocket:close() 
        end
        Udpsocket = socket.udp()
        local result =  Udpsocket:connect(PING_Host,PING_Port,5) --连接服务端5秒超时
        if result  then
            log.info("RKL_ping",string.format( "UDPping %s via port %d with %d bytes of payload", PING_Host,PING_Port,PING_Size )) 
            StatemachineIdx ="Ping" 
        else
            log.warn("RKL_ping", "connect fail!") 
        end

    end,  

    ["Ping"] = function() 
        local _Data = Randomstr(PING_Size)
        PingCount = PingCount + 1
        local _Time = rtos.tick() 
        result = Udpsocket:send(_Data)
        if result  then
            result, recv  = Udpsocket:recv(3000)
            _Time =  (rtos.tick() - _Time) * 5
            if result and recv==_Data  then
                log.info("RKL_ping",string.format("Reply from %s seq=%d time=%d ms size=%d Byte",PING_Host,PingCount, _Time,PING_Size)) 
            else
                log.info("RKL_ping", "Request timed out") 
            end 
        else
            log.info("RKL_ping", "Request timed out") 
        end       

    end,

    ["Stop"] = function()  
       -- log.info("RKL_ping", "idle")
  
    end  
}

--对外提供PING服务启动函数
--host:服务端域名或IP地址string类型
--port:服务端端口string或者number类型
--size包大小单位字节number类型
--函数返回 boolean true=成功 false=失败
function Start(host,port,size)
    local _status = false
    StatemachineIdx ="Stop"  
    if host ~=nil and port ~=nil then
       PING_Host = host
       PING_Port = port
       if size==nil or size < 8  or size > 1024 then
         PING_Size = 32
       else
         PING_Size = size
       end
       StatemachineIdx ="Start"   
       _status = true
    else
        log.warn("RKL_ping", "Parameter error.")    
    end
    return _status
end

--对外提供PING服务停止函数
--函数返回永远为true=成功
function Stop()
    StatemachineIdx ="Stop" 
    return true
end

--任务函数，采用状态机实现PING服务
local function PingTask(host,port,size)
    if host ~=nil and port ~=nil then
        Start(host,port,size)
    end
   while true do
    if not socket.isReady() then sys.waitUntil("IP_READY_IND") end --等待网络就绪

    local StatemachineProc = Statemachine[StatemachineIdx]
    if StatemachineProc then 
         StatemachineProc()  --状态机处理
    end
    sys.wait(1000) --延迟1秒执行服务
  end  
  
end


--启动PING任务
sys.taskInit(PingTask)   
log.info("RKL_ping", "[UDP Ping] module loaded.")    

 

