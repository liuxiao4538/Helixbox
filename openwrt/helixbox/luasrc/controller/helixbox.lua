-- LuCI 控制器：注册图形化菜单 + 提供 JSON API 给网页/手机 App
module("luci.controller.helixbox", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/helixbox") then return end

	entry({"admin", "services", "helixbox"}, cbi("helixbox"), "Helixbox 加速", 60)
	entry({"admin", "services", "helixbox", "status"}, template("helixbox/status"), "运行状态 / 测速", 1)

	local api = entry({"admin", "services", "helixbox", "api"}, call("api_action"), nil)
	api.leaf = true
end

local ALLOWED = { status=true, start=true, stop=true, selfcheck=true,
                  speedtest=true, deploy=true, undeploy=true,
                  apply_ip=true, set_auto=true }

function api_action()
	local http = luci.http
	local action = http.formvalue("action") or "status"
	http.prepare_content("application/json; charset=utf-8")

	if not ALLOWED[action] then
		http.write('{"ok":false,"msg":"不允许的操作"}'); return
	end

	-- apply_ip 需要额外参数，做白名单校验防注入
	local cmd = "/usr/sbin/helixbox-ctl " .. action
	if action == "apply_ip" then
		local group = http.formvalue("group") or ""
		local ip = http.formvalue("ip") or ""
		local isp = http.formvalue("isp") or ""
		if not group:match("^%w+$") or not ip:match("^[%d%.]+$") or not isp:match("^[\128-\255%w%. ]*$") then
			http.write('{"ok":false,"msg":"参数非法"}'); return
		end
		cmd = cmd .. " " .. group .. " " .. ip
		if isp ~= "" then cmd = cmd .. ' "' .. isp .. '"' end
	elseif action == "set_auto" then
		local v = http.formvalue("value") == "1" and "1" or "0"
		cmd = cmd .. " " .. v
	end

	local handle = io.popen(cmd .. " 2>/dev/null")
	local result = ""
	if handle then result = handle:read("*a") or ""; handle:close() end

	local last = ""
	for line in result:gmatch("[^\r\n]+") do
		if line:match("^%s*{") then last = line end
	end
	http.write(last ~= "" and last or '{"ok":false,"msg":"脚本无返回"}')
end
