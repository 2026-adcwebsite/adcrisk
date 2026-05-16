import '../../core/app_export.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'high_risk' | 'sync' | 'reminder' | 'info'
  final String iconName;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.type,
    required this.iconName,
  });

  static NotificationModel fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: map['isRead'] as bool,
      type: map['type'] as String,
      iconName: map['iconName'] as String,
    );
  }
}

final List<Map<String, dynamic>> _notificationMaps = [
  {
    'id': 'notif_001',
    'title': 'Rrezik i lartë i detektuar',
    'message':
        'Formulari TK-2026-0839 ka identifikuar rreziqe elektrike të larta. Kërkohet rishikim nga mbikëqyrësi.',
    'timestamp': '2026-05-16T07:20:00',
    'isRead': false,
    'type': 'high_risk',
    'iconName': 'warning',
  },
  {
    'id': 'notif_002',
    'title': 'Sinkronizim i suksesshëm',
    'message':
        '3 formularë janë sinkronizuar me serverin. Të gjitha të dhënat janë të përditësuara.',
    'timestamp': '2026-05-16T06:45:00',
    'isRead': false,
    'type': 'sync',
    'iconName': 'cloud_done',
  },
  {
    'id': 'notif_003',
    'title': 'Rrezik i lartë — Rast TK-2026-0819',
    'message':
        'Punonjësi Arta Hoxha ka raportuar kushte atmosferike ekstreme në Selitë. Puna është ndaluar.',
    'timestamp': '2026-05-16T05:30:00',
    'isRead': true,
    'type': 'high_risk',
    'iconName': 'warning',
  },
  {
    'id': 'notif_004',
    'title': 'Kujtesë: Formulari i paplotësuar',
    'message':
        'Keni 1 rast aktiv pa vlerësim rreziku. Plotësoni formularin para fillimit të punës.',
    'timestamp': '2026-05-15T16:00:00',
    'isRead': true,
    'type': 'reminder',
    'iconName': 'assignment',
  },
  {
    'id': 'notif_005',
    'title': 'Raport javor i disponueshëm',
    'message':
        'Raporti i javës 19 (12-16 Maj 2026) është gati për eksportim. 24 vlerësime të kryera.',
    'timestamp': '2026-05-15T08:00:00',
    'isRead': true,
    'type': 'info',
    'iconName': 'analytics',
  },
  {
    'id': 'notif_006',
    'title': 'Sinkronizim i dështuar',
    'message':
        '2 formularë nuk mund të sinkronizohen për shkak të lidhjes së dobët. Do të riprovohet automatikisht.',
    'timestamp': '2026-05-14T18:30:00',
    'isRead': true,
    'type': 'sync',
    'iconName': 'cloud_off',
  },
  {
    'id': 'notif_007',
    'title': 'Ekipi i ri i caktuar',
    'message':
        'Jeni caktuar në ekipin e Durrësit për javën e ardhshme. Kontaktoni mbikëqyrësin Gentian Duka.',
    'timestamp': '2026-05-13T14:15:00',
    'isRead': true,
    'type': 'info',
    'iconName': 'group',
  },
];

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // TODO: Replace with Riverpod/Bloc for production state management
  late List<NotificationModel> _notifications;
  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void initState() {
    super.initState();
    _notifications = _notificationMaps.map(NotificationModel.fromMap).toList();
  }

  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map(
            (n) => NotificationModel(
              id: n.id,
              title: n.title,
              message: n.message,
              timestamp: n.timestamp,
              isRead: true,
              type: n.type,
              iconName: n.iconName,
            ),
          )
          .toList();
    });
  }

  void _markRead(String id) {
    setState(() {
      _notifications = _notifications
          .map(
            (n) => n.id == id
                ? NotificationModel(
                    id: n.id,
                    title: n.title,
                    message: n.message,
                    timestamp: n.timestamp,
                    isRead: true,
                    type: n.type,
                    iconName: n.iconName,
                  )
                : n,
          )
          .toList();
    });
  }

  List<NotificationModel> _todayNotifs() {
    final today = DateTime.now();
    return _notifications.where((n) {
      return n.timestamp.year == today.year &&
          n.timestamp.month == today.month &&
          n.timestamp.day == today.day;
    }).toList();
  }

  List<NotificationModel> _earlierNotifs() {
    final today = DateTime.now();
    return _notifications.where((n) {
      return !(n.timestamp.year == today.year &&
          n.timestamp.month == today.month &&
          n.timestamp.day == today.day);
    }).toList();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m më parë';
    if (diff.inHours < 24) return '${diff.inHours}h më parë';
    return '${diff.inDays}d më parë';
  }

  @override
  Widget build(BuildContext context) {
    final todayList = _todayNotifs();
    final earlierList = _earlierNotifs();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _notifications.isEmpty
                  ? EmptyStateWidget(
                      iconName: 'notifications',
                      title: 'Nuk ka njoftime',
                      message:
                          'Njoftimet e reja do të shfaqen këtu kur të ketë aktivitet.',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      children: [
                        if (todayList.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Sot',
                            todayList.where((n) => !n.isRead).length,
                          ),
                          ...todayList.asMap().entries.map(
                            (e) => TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(
                                milliseconds: 240 + e.key * 60,
                              ),
                              curve: Curves.easeOutCubic,
                              builder: (context, val, child) => Opacity(
                                opacity: val,
                                child: Transform.translate(
                                  offset: Offset(0, 12 * (1 - val)),
                                  child: child,
                                ),
                              ),
                              child: _NotificationCard(
                                notification: e.value,
                                timeAgo: _timeAgo(e.value.timestamp),
                                onTap: () => _markRead(e.value.id),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (earlierList.isNotEmpty) ...[
                          _buildSectionHeader('Prima', 0),
                          ...earlierList.asMap().entries.map(
                            (e) => TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(
                                milliseconds: 280 + e.key * 50,
                              ),
                              curve: Curves.easeOutCubic,
                              builder: (context, val, child) =>
                                  Opacity(opacity: val, child: child),
                              child: _NotificationCard(
                                notification: e.value,
                                timeAgo: _timeAgo(e.value.timestamp),
                                onTap: () => _markRead(e.value.id),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppNavigation(
        currentIndex: 2,
        onDestinationSelected: (i) => _handleNavigation(context, i),
        isSupervisor: true,
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    final routes = [
      AppRoutes.riskAssessmentFormScreen,
      AppRoutes.submissionHistoryScreen,
      AppRoutes.notificationsScreen,
      AppRoutes.supervisorDashboardScreen,
      AppRoutes.reportsExportScreen,
    ];
    if (index < routes.length) {
      Navigator.pushNamedAndRemoveUntil(context, routes[index], (r) => false);
    }
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(bottom: BorderSide(color: AppTheme.outlineDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Njoftime',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceText,
                  ),
                ),
                if (_unreadCount > 0)
                  Text(
                    '$_unreadCount të palexuara',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      color: AppTheme.primary,
                    ),
                  )
                else
                  Text(
                    'Të gjitha të lexuara',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      color: AppTheme.mutedText,
                    ),
                  ),
              ],
            ),
          ),
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllRead,
              icon: CustomIconWidget(
                iconName: 'done_all',
                color: AppTheme.primary,
                size: 18,
              ),
              label: Text(
                'Lexo të gjitha',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String label, int unreadCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedText,
              letterSpacing: 0.8,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '$unreadCount',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          Expanded(child: Divider(color: AppTheme.outlineDark, height: 1)),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final String timeAgo;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.timeAgo,
    required this.onTap,
  });

  Color _getTypeColor() {
    switch (notification.type) {
      case 'high_risk':
        return AppTheme.errorColor;
      case 'sync':
        return notification.iconName == 'cloud_off'
            ? AppTheme.warning
            : AppTheme.success;
      case 'reminder':
        return AppTheme.warning;
      default:
        return AppTheme.primary;
    }
  }

  Color _getTypeBg() {
    switch (notification.type) {
      case 'high_risk':
        return const Color(0xFF2D0A0A);
      case 'sync':
        return notification.iconName == 'cloud_off'
            ? AppTheme.warningContainer
            : AppTheme.successContainer;
      case 'reminder':
        return AppTheme.warningContainer;
      default:
        return AppTheme.primaryMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();
    final typeBg = _getTypeBg();
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isUnread
            ? AppTheme.surfaceDark
            : AppTheme.surfaceDark.withAlpha(180),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread ? typeColor.withAlpha(80) : AppTheme.outlineDark,
          width: isUnread ? 1.5 : 1,
        ),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: typeColor.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: AppTheme.primaryMuted,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: typeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: notification.iconName,
                    color: typeColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 13,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isUnread
                                  ? AppTheme.onSurfaceText
                                  : AppTheme.mutedText,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8, top: 2),
                            decoration: BoxDecoration(
                              color: typeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        color: AppTheme.mutedText,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeAgo,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 11,
                        color: AppTheme.mutedText.withAlpha(160),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
