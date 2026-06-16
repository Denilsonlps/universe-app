class AppNotification {
  final String id, icon, title, body, time;
  final String? route;
  final bool unread;
  const AppNotification({
    required this.id, required this.icon, required this.title,
    required this.body, required this.time,
    this.route, this.unread = true,
  });

  Map<String, dynamic> toMap() => {
        'icon': icon, 'title': title, 'body': body, 'time': time,
        'route': route, 'unread': unread,
      };

  factory AppNotification.fromMap(String id, Map<String, dynamic> m) => AppNotification(
        id: id, icon: m['icon'] ?? 'bell', title: m['title'] ?? '',
        body: m['body'] ?? '', time: m['time'] ?? '',
        route: m['route'], unread: m['unread'] ?? true);
}
