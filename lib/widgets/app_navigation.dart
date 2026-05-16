import '../core/app_export.dart';

class AppNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final bool isSupervisor;

  const AppNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.isSupervisor = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 600) {
      return _buildNavigationRail(context);
    }
    return _buildBottomNav(context);
  }

  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: AppTheme.surfaceDark,
      indicatorColor: AppTheme.primaryMuted,
      elevation: 0,
      height: 64,
      destinations: _buildDestinations(),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: AppTheme.surfaceDark,
      indicatorColor: AppTheme.primaryMuted,
      labelType: NavigationRailLabelType.all,
      destinations: _buildDestinations()
          .map(
            (d) => NavigationRailDestination(
              icon: d.icon,
              selectedIcon: d.selectedIcon,
              label: Text(d.label),
            ),
          )
          .toList(),
    );
  }

  List<NavigationDestination> _buildDestinations() {
    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: CustomIconWidget(
          iconName: 'assignment_outlined',
          color: AppTheme.mutedText,
          size: 24,
        ),
        selectedIcon: CustomIconWidget(
          iconName: 'assignment',
          color: AppTheme.primary,
          size: 24,
        ),
        label: 'Vlerësim',
      ),
      NavigationDestination(
        icon: CustomIconWidget(
          iconName: 'history',
          color: AppTheme.mutedText,
          size: 24,
        ),
        selectedIcon: CustomIconWidget(
          iconName: 'history',
          color: AppTheme.primary,
          size: 24,
        ),
        label: 'Histori',
      ),
      NavigationDestination(
        icon: CustomIconWidget(
          iconName: 'notifications_outlined',
          color: AppTheme.mutedText,
          size: 24,
        ),
        selectedIcon: CustomIconWidget(
          iconName: 'notifications',
          color: AppTheme.primary,
          size: 24,
        ),
        label: 'Njoftime',
      ),
    ];

    if (isSupervisor) {
      destinations.addAll([
        NavigationDestination(
          icon: CustomIconWidget(
            iconName: 'dashboard_outlined',
            color: AppTheme.mutedText,
            size: 24,
          ),
          selectedIcon: CustomIconWidget(
            iconName: 'dashboard',
            color: AppTheme.primary,
            size: 24,
          ),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: CustomIconWidget(
            iconName: 'analytics_outlined',
            color: AppTheme.mutedText,
            size: 24,
          ),
          selectedIcon: CustomIconWidget(
            iconName: 'analytics',
            color: AppTheme.primary,
            size: 24,
          ),
          label: 'Analitika',
        ),
      ]);
    }

    return destinations;
  }
}
