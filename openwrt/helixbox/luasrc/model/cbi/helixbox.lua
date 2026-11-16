-- LuCI 设置页（图形化）：开关、端口、自动测速、三组 IP、部署按钮
local m = Map("helixbox", "Helixbox 下载加速",
	"把 Xbox / 微软商店 / PS / NS 下载域名劫持到软路由，302 跳转国内 CDN 加速。" ..
	"<br/>测速引擎跑在路由器上（宽带出口），手机 App 只是遥控器。改配置前自动备份，卸载原样还原。")

local s = m:section(TypedSection, "main", "基本设置")
s.anonymous = true

local enabled = s:option(Flag, "enabled", "启用加速")
enabled.rmempty = false
enabled.description = "总开关：开启后由 lighttpd 接管 80 端口做跳转。"

local port = s:option(Value, "uhttpd_port", "管理页端口")
port.default = 8080; port.datatype = "port"
port.description = "让出 80 端口后，用 http://路由器IP:" .. (port.default or "8080") .. " 打开管理页。"

local auto = s:option(Flag, "auto_test", "定时自动测速")
auto.rmempty = false
auto.description = "开启后按间隔自动用 v3 抢跑算法测速并更新最优 IP。"

local interval = s:option(Value, "test_interval", "测速间隔（小时）")
interval.default = 24; interval.datatype = "uinteger"

local ipv6 = s:option(Flag, "ipv6_block", "屏蔽 IPv6（高级）")
ipv6.rmempty = false
ipv6.description = "Xbox 走 IPv6 会绕过加速；也可在路由器直接关 IPv6。"

local deploy = s:option(Button, "_deploy", "一键部署 / 更新")
deploy.inputtitle = "立即部署"; deploy.inputstyle = "apply"
function deploy.write() luci.sys.call("/usr/sbin/helixbox-ctl deploy >/dev/null 2>&1") end

local undeploy = s:option(Button, "_undeploy", "卸载还原")
undeploy.inputtitle = "卸载并还原"; undeploy.inputstyle = "reset"
function undeploy.write() luci.sys.call("/usr/sbin/helixbox-ctl undeploy >/dev/null 2>&1") end

local groups = m:section(TypedSection, "ipgroup", "国内 CDN IP 与运营商（测速后自动填，也可手动）")
groups.anonymous = false
groups.addremove = false
groups:option(DummyValue, "label", "分组")
local ip = groups:option(Value, "ip", "生效 IP")
local isp = groups:option(Value, "isp", "运营商")
isp.description = "如 电信 / 联通 / 移动，供手机 App 按运营商筛选显示。"

return m
