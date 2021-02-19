
--***************************************************************************
--           [RKL Library]    LUAT 第三方开源库     
--           [RKL Library]    LUAT Third-party open source library        
--===========================================================================
--   
--   [Unit name]:RKL_pubip.lua
--[Introduction]:Get public IP address.
--    [Function]:RKL_pubip.getip();
--      [Device]:Air724UG(RDA8910)
--        [Core]:Luat_4G_RDA_8910 V0022
--      [Author]:Reverseking  (QQ:441673604) 
--     [License]:MIT
--   
--     [History]:[+]New or Add. [-]Remove. [*]Modify. [#]BUG Fixed.
--               [+] Created the file at                2021-02-19 15:03:20. 
--     
--***************************************************************************

--*************************nginx服务器端直接配置*************************
-- 
-- 编辑/etc/nginx/nginx.conf 文件，添加以下代码保存后重启.
-- 即可在浏览器上使用http://domain/get_ip访问并获取自身公网IP地址.

--    location /get_ip {
--        default_type text/plain;
--        return 200 "$remote_addr\n";
--    }
--
--**********************************************************************

require"http"
module(...,package.seeall)


local IP_SERVICE_URL = "myip.fireflysoft.net" 

local SelfPublicIP ="0.0.0.0" --公网IP地址


--获取自身公网IP地址,外部不能直接调用
local function GetIPFuntion(result,prompt,head,body)
    if result and prompt == "200" and body then
        SelfPublicIP = body
        log.info("RKL_pubip","Self Ip Address:", SelfPublicIP)
    else
        log.warn("RKL_pubip", "Failed to obtain public IP address.")   
    end 


end

--获取自身公网IP地址外部调用函数
function getip()
	return  SelfPublicIP
end

--IP网络准备就绪后获取自身公网IP地址 
sys.subscribe("IP_READY_IND", function()
    http.request("GET",IP_SERVICE_URL,nil,nil,nil,nil,GetIPFuntion) --获取公网IP
end)
log.info("RKL_pubip", "[Public IP] module loaded.")   





