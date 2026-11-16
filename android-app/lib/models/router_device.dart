/// 一台装了 OpenWrt 插件的路由器（手机通过局域网控制它）
class RouterDevice {
  final String name;
  final String host; // 例：192.168.1.1 或 http://192.168.1.1:8080
  String? username; // LuCI 登录用户名（可选，匿名也可访问时留空）
  String? password;

  RouterDevice({
    required this.name,
    required this.host,
    this.username,
    this.password,
  });

  /// 规范化地址：确保以 http:// 开头、去掉末尾斜杠
  String get baseUrl {
    var h = host.trim();
    if (!h.startsWith('http://') && !h.startsWith('https://')) {
      h = 'http://$h';
    }
    return h.replaceAll(RegExp(r'/+$'), '');
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'host': host,
        'username': username,
        'password': password,
      };

  factory RouterDevice.fromJson(Map<String, dynamic> j) => RouterDevice(
        name: j['name'] as String,
        host: j['host'] as String,
        username: j['username'] as String?,
        password: j['password'] as String?,
      );
}
