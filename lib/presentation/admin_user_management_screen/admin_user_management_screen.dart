import '../../core/app_export.dart';
import '../../services/supabase_service.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await SupabaseService.instance.getAllUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  void _showAddUserDialog() {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'worker';
    bool isCreating = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Shto User të Ri',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceText,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDialogField(nameCtrl, 'Emri i Plotë', 'person'),
                const SizedBox(height: 12),
                _buildDialogField(
                  emailCtrl,
                  'Email',
                  'email_outlined',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildDialogField(
                  passCtrl,
                  'Fjalëkalimi',
                  'lock_outlined',
                  obscure: true,
                ),
                const SizedBox(height: 12),
                Text(
                  'Roli',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariantDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.outlineDark),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedRole,
                      dropdownColor: AppTheme.surfaceDark,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        color: AppTheme.onSurfaceText,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'worker',
                          child: Text('Punonjës'),
                        ),
                        DropdownMenuItem(
                          value: 'supervisor',
                          child: Text('Supervisor'),
                        ),
                        DropdownMenuItem(
                          value: 'manager',
                          child: Text('Manager'),
                        ),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (v) =>
                          setDialogState(() => selectedRole = v ?? 'worker'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Anulo',
                style: GoogleFonts.ibmPlexSans(color: AppTheme.mutedText),
              ),
            ),
            FilledButton(
              onPressed: isCreating
                  ? null
                  : () async {
                      if (nameCtrl.text.isEmpty ||
                          emailCtrl.text.isEmpty ||
                          passCtrl.text.isEmpty) {
                        return;
                      }
                      setDialogState(() => isCreating = true);
                      final result = await SupabaseService.instance.createUser(
                        email: emailCtrl.text.trim(),
                        password: passCtrl.text,
                        fullName: nameCtrl.text.trim(),
                        role: selectedRole,
                      );
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      if (result['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Useri u krijua me sukses!',
                              style: GoogleFonts.ibmPlexSans(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                        _loadUsers();
                      } else {
                        final errMsg =
                            result['error']?.toString() ??
                            'Gabim gjatë krijimit të userit.';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              errMsg,
                              style: GoogleFonts.ibmPlexSans(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: AppTheme.errorColor,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isCreating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Krijo',
                      style: GoogleFonts.ibmPlexSans(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(
    TextEditingController ctrl,
    String label,
    String icon, {
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: GoogleFonts.ibmPlexSans(
        fontSize: 14,
        color: AppTheme.onSurfaceText,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: CustomIconWidget(
            iconName: icon,
            color: AppTheme.mutedText,
            size: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      color: AppTheme.primary,
                      backgroundColor: AppTheme.surfaceDark,
                      child: _users.isEmpty ? _buildEmpty() : _buildUserList(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        backgroundColor: AppTheme.primary,
        icon: CustomIconWidget(
          iconName: 'person_add',
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          'Shto User',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(bottom: BorderSide(color: AppTheme.outlineDark)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.onSurfaceText,
              size: 22,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menaxhimi i Userëve',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceText,
                  ),
                ),
                Text(
                  '${_users.length} user total',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'group_outlined',
            color: AppTheme.mutedText,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Nuk ka userë',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 16,
              color: AppTheme.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _buildUserCard(_users[i]),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final name = user['full_name'] ?? '—';
    final email = user['email'] ?? '—';
    final role = user['role'] ?? 'worker';
    final isActive = user['is_active'] ?? true;

    Color roleColor;
    String roleLabel;
    switch (role) {
      case 'admin':
        roleColor = AppTheme.errorColor;
        roleLabel = 'Admin';
        break;
      case 'manager':
        roleColor = AppTheme.warning;
        roleLabel = 'Manager';
        break;
      case 'supervisor':
        roleColor = AppTheme.secondary;
        roleLabel = 'Supervisor';
        break;
      default:
        roleColor = AppTheme.primary;
        roleLabel = 'Punonjës';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineDark),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: roleColor.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: roleColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: roleColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: roleColor.withAlpha(80)),
                ),
                child: Text(
                  roleLabel,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: roleColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.success.withAlpha(30)
                      : AppTheme.mutedText.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isActive ? 'Aktiv' : 'Joaktiv',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 10,
                    color: isActive ? AppTheme.success : AppTheme.mutedText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
