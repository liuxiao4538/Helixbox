# Helixbox · Android 遥控器（Flutter）

手机通过 **WiFi 局域网** 连接软路由上的 Helixbox 插件，做三件事：**让路由器测速并查看结果** → **按运营商筛选挑 IP** → **点选下发 / 远程开关**。

**测速在路由器上跑**（宽带出口，和游戏机下载同一条路，最准），手机只当遥控器。右上角图标可切“本机测速”，但那多走一跳 WiFi、仅作参考。本身不加速下载，需配合 `openwrt/helixbox/` 的插件使用。

## 一、环境准备（一次性）

1. 安装 [Flutter SDK](https://docs.flutter.dev/get-started/install/windows)（3.x，含 Dart 3）。
2. 安装 Android Studio，装好 **Android SDK**（Platform 34）与 **JDK 17**。
3. 配环境变量：`ANDROID_HOME`/`ANDROID_SDK_ROOT` 指向 SDK 目录；`java -version` 能跑。
4. 验证：`flutter doctor`，确保 Android 那几项都是勾。

> 本机当前未安装 Flutter，源码已就绪，打包需在有 Flutter 的环境执行以下步骤。

## 二、补齐平台目录（重要）

本仓库只提供了核心源码与关键原生配置。首次构建前，先用 Flutter 生成完整原生骨架（已存在的文件不会被覆盖）：

```bash
cd android-app
flutter create . --org com.example --project-name xboxdownload_controller
flutter pub get
```

> `flutter create .` 会补齐 `MainActivity`、`gradlew`、图标等标准文件；我们已写的 `lib/`、`pubspec.yaml`、`AndroidManifest.xml` 会保留。

## 三、打包 APK

```bash
# 调试版（可直接装手机测试）
flutter build apk --debug
# 输出：build/app/outputs/flutter-apk/app-debug.apk

# 正式版（release）
flutter build apk --release
# 输出：build/app/outputs/flutter-apk/app-release.apk
```

## 四、安装到手机

```bash
adb devices                       # 确认手机已开启“USB调试”
adb install build/app/outputs/flutter-apk/app-release.apk
```
也可直接把 apk 传到手机点开安装（需在系统设置允许“安装未知来源应用”）。

## 五、签名（正式发布才需要）

V1 的 `app/build.gradle` 里 release 用的是 `signingConfigs.debug`，能装能测，但**不能上架商店**。正式签名步骤：

1. 生成 keystore：
   ```bash
   keytool -genkey -v -keystore ~/xboxdownload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias xd
   ```
2. 在 `android/key.properties` 写入（此文件不要提交）：
   ```properties
   storePassword=你的库密码
   keyPassword=你的密钥密码
   keyAlias=xd
   storeFile=C:/Users/你的用户名/xboxdownload-key.jks
   ```
3. 在 `android/app/build.gradle` 顶部读取该文件并配置 `signingConfigs.release`，再把 release 的 `signingConfig` 改成它。

## 六、常见报错

| 报错 | 解决 |
|---|---|
| `cmdline-tools not found` / `SDK not found` | Android Studio 里装 Android SDK Command-line Tools，配好 `ANDROID_HOME` |
| `Gradle build failed` / 版本冲突 | `flutter clean && flutter pub get` 后重编；确认 gradle-8.5 可下载 |
| `CocoaPods not installed` | 仅 iOS 需要；本项目 V1 只做 Android，可忽略 |
| 手机装不上 | 检查 `minSdkVersion 21`（Android 5.0+）；关闭“Play 保护”对未知应用的拦截 |
| App 连不上路由器 | 手机与路由器同一 WiFi；管理页端口是 8080；LuCI 账号密码正确；路由器防火墙没拦 8080 |

## 七、边界

- V1 仅 Android；iOS 需 Xcode + 开发者证书/TestFlight，且本地 DNS 劫持在 iOS 上不可行（我们的 App 也不依赖它）。
- 本专家只做本地打包，不做应用商店上架与资质审核。
