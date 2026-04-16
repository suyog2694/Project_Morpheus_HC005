class ApiConfig {
  // ── Change this to your server's IP address ──
  // Android emulator → 10.0.2.2 maps to host machine's localhost
  // Physical device  → use the machine's LAN IP (e.g. 192.168.x.x)
  static const String _host = '10.0.2.2';
  static const int _port = 8000;

  static const String baseUrl = 'http://$_host:$_port/api';
}
