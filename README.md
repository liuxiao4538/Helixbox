# Helixbox（OpenWrt 插件 + Android 遥控器）

基于开源项目 [skydevil88/XboxDownload](https://github.com/skydevil88/XboxDownload) 的加速原理（把 xboxlive.com 国外下载域名 302 跳转到 `.cn` 国内 CDN）和它的 **v3 快速测速算法**，做的两个衍生产品。Helixbox 只是产品命名。

| 目录 | 产品 | 作用 |
|---|---|---|
| `openwrt/helixbox/` | `luci-app-helixbox` 插件 | 带完整图形界面的 OpenWrt 插件：一键部署加速 + 测速引擎跑在路由器上；多架构、双格式（ipk / apk） |
| `android-app/` | Flutter Android App | 手机通过 WiFi 局域网当遥控器：触发测速、看结果、按运营商筛选、点选下发 |

## 固件版本与架构（重要）

| 固件 | 包管理器 | 安装包 |
|---|---|---|
| OpenWrt **24.10 及更早** | opkg | `dist/ipk/<架构>/luci-app-helixbox_1.0.0_<架构>.ipk` |
| OpenWrt **25.12 及更新** | apk-tools | `dist/apk/<架构>/luci-app-helixbox-1.0.0-r1.apk` |

架构目录：`x86_64`、`aarch64_cortex-a53`、`aarch64_cortex-a72`、`arm_cortex-a7_neon-vfpv4`，另有 `all`（opkg 通用）/ `noarch`（apk 通用）。插件是纯脚本，一份通用包即可跨架构安装；分架构目录是为方便你按机型取用。不确定架构就在路由器执行 `uname -m`。

**手机 APK 由 GitHub Actions 云端编译**：推送 `v*` 标签后，Release 里会自动出现 `Helixbox-v*-android-release.apk` 和 `-debug.apk`。本机无 Flutter/JDK，源码已就绪。

## 测速到底在手机还是路由器？（重要）

**结论：测速引擎放在软路由，手机只当遥控器。**

- 软路由就是宽带出口，测的是「出口 → CDN」，和游戏机下载走的是同一条路，最准；
- 软路由 7×24 在线，可定时自动测、自动换 IP；手机关了 App 就没了，且手机走 WiFi 多一跳、结果偏低。

v3 为什么快：不是逐个排队，而是**两阶段并发抢跑**——先并发 ping 筛出 10 个通的（≤3 秒），再让这 10 个同时下载同一个 10MB 分片，**谁先下完谁赢**，赢的瞬间取消其余（≤10 秒）。插件用 `curl --resolve` + 并发后台进程等价复刻了 .NET 的这套算法（详见 `openwrt/helixbox/README.md`）。

## 三者怎么配合

```
[手机 App] --WiFi 局域网 API--> [Helixbox 插件]
                                   |--v3 并发测速（路由器测，最准）
                                   |--选 IP / 运营商 → 下发
                                   |--劫持域名 + 302 跳转
                                          |
                              Xbox / 商店 / PS / NS 走国内 CDN 下载
```

## 快速开始

1. **装插件**：`cd openwrt/helixbox && python3 build_packages.py` 生成全部包，按固件取 `dist/ipk/<架构>/*.ipk`（24.10）或 `dist/apk/<架构>/*.apk`（25.12）安装。
2. **图形界面**：浏览器 `http://路由器IP` → 服务 → Helixbox 加速 → 点“部署”，之后用 `:8080` 打开；在“运行状态/测速”页一键测速、按运营商筛选、点“选用”。
3. **装 App**：按 `android-app/README.md` 打包 APK，手机连同一 WiFi，在“控制路由器”添加设备（`路由器IP:8080`），即可远程测速/开关/下发。

## 边界与说明

- 这是**非官方**衍生工具，加速效果取决于运营商与 CDN 节点，不保证所有地区/游戏有效。
- 原项目是 .NET + Avalonia 桌面程序；本项目是独立重写，不修改原项目源码。
- V1 范围：插件仅 lighttpd 方案；App 仅 Android；手机端“本机测速”只是无路由器时的降级参考。
- 请遵守当地法律法规与平台服务条款，仅用于个人学习与使用。
