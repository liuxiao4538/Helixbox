# luci-app-Helixbox.ipk（OpenWrt 软路由一键加速插件）

把 XboxDownload 原项目的加速原理 + v3 快速测速算法，做成一个带**完整图形界面**的 OpenWrt 插件。装在软路由上，全屋设备免开电脑加速；手机 App 通过 WiFi 局域网当遥控器。

> Helixbox 只是产品命名，与上游无隶属关系。

## 成品（多架构 × 双格式）

运行 `python3 build_packages.py` 生成到 `dist/`：

- `dist/ipk/<架构>/luci-app-helixbox-1.0.0-<架构>.ipk` —— **OpenWrt 24.10 及更早**（opkg）
- `dist/apk/<架构>/luci-app-helixbox-1.0.0-<架构>.apk` —— **OpenWrt 25.12 及更新**（apk-tools，注意 `.PKGINFO` 里是 `arch = noarch`）
- 架构目录：`x86_64`、`aarch64_cortex-a53`、`aarch64_cortex-a72`、`arm_cortex-a7_neon-vfpv4`，另有 `all`（ipk）/ `noarch`（apk）通用包。
- 插件是纯脚本，架构通用；分目录只是方便按机型取用。不确定架构在路由器执行 `uname -m`。
- 也可把 `helixbox/` 放进 OpenWrt 源码 `package/` 用 `make menuconfig` 编译。

## 图形界面在哪

安装后 LuCI 菜单 → **服务 → Helixbox 加速**，两个页面：

1. **设置页**（CBI 表单）：总开关、管理页端口、定时自动测速、三组 CDN IP + 运营商、一键部署/卸载按钮。
2. **运行状态 / 测速页**：开关状态、一键测速按钮、测速结果表（IP/地区/运营商/延迟/10MB 下载量，带进度条）、运营商筛选下拉、点“选用”即下发生效。

手机 App 走同一套 JSON API（`?action=...`），界面不同但功能一致。

## 测速：为什么放路由器，以及为什么这么快

**放哪测**：测速引擎在软路由上跑（`/usr/sbin/helixbox-speedtest`）。理由——
- 软路由就是宽带出口，测的是「出口→CDN」这一段，和游戏机下载走的是同一条路，最准；
- 7×24 在线，可定时自动测、自动换 IP；手机一关 App 就没了，且手机走了 WiFi 多一跳。

**为什么快**（复刻 PC v3 的 `SpeedTestService.cs`）：
1. 阶段一：所有候选 IP（官方 IP 库最多 120 个）**并发 ping**，1 秒超时，收满 10 个通的就掐断其余（≤3 秒）。
2. 阶段二：这 10 个 IP **同时**下载同一个测速文件的随机 10MB 分片（Xbox / PSN / Switch 三 URL 随机选一），用 `curl --resolve` 绑定 IP 但保留域名 Host。
3. **谁先下完谁赢**，赢的瞬间写 winner 文件并 kill 其余请求（≤10 秒）。
4. 结果按运营商标注（来自官方 IP 库的「地区 运营商」），供界面/App 筛选。

对比 exe：exe 是 .NET 在 PC 上跑同样的算法；这里是 shell 在 OpenWrt 上等价实现，逻辑一致。

## 安装

按固件选一种（下面以 x86_64 为例，换成你 `uname -m` 对应的目录）：

```sh
# OpenWrt 24.10 及更早：opkg + ipk
scp dist/ipk/x86_64/luci-app-helixbox-1.0.0-x86_64.ipk root@192.168.1.1:/tmp/
ssh root@192.168.1.1 'opkg update && opkg install /tmp/luci-app-helixbox-1.0.0-x86_64.ipk'

# OpenWrt 25.12 及更新：apk-tools + apk
scp dist/apk/x86_64/luci-app-helixbox-1.0.0-<架构>.apk root@192.168.1.1:/tmp/
ssh root@192.168.1.1 'apk add --allow-untrusted /tmp/luci-app-helixbox-1.0.0-<架构>.apk'

ssh root@192.168.1.1 '/etc/init.d/uhttpd restart'
# 清浏览器缓存后重新登录管理页
```

缺依赖时先 `opkg install lighttpd lighttpd-mod-redirect lighttpd-mod-proxy curl iputils-ping`。

## 使用四步

1. 浏览器开 `http://路由器IP` → 服务 → Helixbox 加速 → 运行状态 → 点**部署**。
2. 部署会把管理页挪到 **:8080**，请用 `http://路由器IP:8080` 重新打开（80 归跳转服务）。
3. 点**一键测速** → 按运营商筛选 → 点最快那行**选用**。
4. Xbox → 网络高级设置 → DNS 手动填路由器 IP。下载完改回自动。

## 命令行（SSH 调试）

```sh
/usr/sbin/helixbox-ctl deploy          # 部署
/usr/sbin/helixbox-ctl speedtest       # v3 并发测速，输出 JSON
/usr/sbin/helixbox-ctl apply_ip primary 116.169.213.43 电信   # 下发 IP
/usr/sbin/helixbox-ctl status          # 状态 JSON
/usr/sbin/helixbox-ctl selfcheck       # 自检跳转
/usr/sbin/helixbox-ctl set_auto 1      # 开定时测速
/usr/sbin/helixbox-ctl undeploy        # 卸载还原
```

## 手机 App 调用

LuCI API（需登录会话或 App 保存的 LuCI 凭据）：

```
http://路由器IP:8080/cgi-bin/luci/admin/services/helixbox/api?action=speedtest
http://路由器IP:8080/cgi-bin/luci/admin/services/helixbox/api?action=apply_ip&group=primary&ip=1.2.3.4&isp=电信
```

可用 action：`status` `start` `stop` `selfcheck` `speedtest` `deploy` `undeploy` `apply_ip` `set_auto`。

## 常见问题

- 部署后管理页打不开 → 用 `:8080`。
- 测速全是 0 → 路由器要能访问 GitHub（更新 IP 库）和三个测速域名；确认装了 `curl`、`iputils-ping`。
- 自检失败 → 确认 lighttpd 在跑（`pgrep lighttpd`）、hosts 劫持已写入、关掉 IPv6 和代理。
- 想恢复 → 点“卸载还原”，所有改动从 `/etc/helixbox.backup/` 恢复。
