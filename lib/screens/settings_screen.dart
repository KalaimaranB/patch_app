import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../providers/theme_provider.dart';
import '../services/supabase_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;
  bool _nameEdited = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final userData = ref.read(currentUserProvider);
    userData.whenData((user) {
      if (user?.profile?.preferredName != null) {
        _nameController.text = user!.profile!.preferredName!;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      await SupabaseService.updateProfile(
        userId: user.id,
        preferredName: _nameController.text.trim(),
      );
      ref.read(currentUserProvider.notifier).refresh();
      setState(() {
        _success = 'Profile updated successfully!';
        _nameEdited = false;
      });
    } catch (e) {
      setState(() => _error = 'Failed to update profile');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showWipeDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DangerDialog(
        title: 'Wipe Medical Data',
        message:
            'This will permanently delete all your medical data including dosage history and device information. This action cannot be undone.',
        confirmLabel: 'Wipe All Data',
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await SupabaseService.wipeMedicalData(
            SupabaseService.currentUser!.id);
        ref.invalidate(dashboardDataProvider);
        ref.invalidate(devicesProvider);
        ref.invalidate(dosageHistoryProvider);
        if (mounted) {
          setState(() {
            _success = 'Medical data wiped successfully';
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = 'Failed to wipe data';
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DangerDialog(
        title: 'Delete Account',
        message:
            'This will permanently delete your account and all associated data. This action cannot be undone.',
        confirmLabel: 'Delete My Account',
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await SupabaseService.deleteAccount(
            SupabaseService.currentUser!.id);
        if (mounted) context.go('/account-deleted');
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = 'Failed to delete account';
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    await SupabaseService.signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userData = ref.watch(currentUserProvider);
    final themeNotifier = ref.watch(themeProvider);
    final themeCtrl = ref.read(themeProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your account preferences and notifications',
            style: TextStyle(
              fontSize: 14,
              color:
                  isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),

          // Status messages
          if (_error != null) ...[
            _StatusBanner(
                message: _error!, isError: true, isDark: isDark),
            const SizedBox(height: 12),
          ],
          if (_success != null) ...[
            _StatusBanner(
                message: _success!, isError: false, isDark: isDark),
            const SizedBox(height: 12),
          ],

          // Profile section
          _SectionCard(
            title: 'Profile',
            isDark: isDark,
            children: [
              // Email
              userData.whenOrNull(
                    data: (user) => _InfoRow(
                      label: 'Email',
                      value: user?.email ?? 'N/A',
                      hint: 'Email cannot be changed',
                      isDark: isDark,
                    ),
                  ) ??
                  const SizedBox.shrink(),
              const SizedBox(height: 16),
              // Preferred name
              Text(
                'Preferred Name',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() => _nameEdited = true),
                      decoration: const InputDecoration(
                        hintText: 'Enter your preferred name',
                      ),
                    ),
                  ),
                  if (_nameEdited) ...[
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveName,
                      child: const Text('Save'),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Appearance
          _SectionCard(
            title: 'Appearance',
            isDark: isDark,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      themeNotifier == ThemeMode.dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: const Color(0xFF8B5CF6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Switch between light and dark theme',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: themeNotifier == ThemeMode.dark,
                    onChanged: (_) => themeCtrl.toggleTheme(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Danger zone
          _SectionCard(
            title: 'Danger Zone',
            isDark: isDark,
            borderColor: const Color(0xFFEF4444).withValues(alpha: 0.3),
            children: [
              _DangerButton(
                icon: Icons.delete_sweep_rounded,
                label: 'Wipe My Data',
                description: 'Permanently delete all your medical data',
                onTap: _showWipeDialog,
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              Divider(
                color: isDark
                    ? const Color(0xFF1F2937)
                    : const Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 14),
              _DangerButton(
                icon: Icons.person_remove_rounded,
                label: 'Delete My Account and All My Data',
                description: 'This action cannot be undone',
                onTap: _showDeleteDialog,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side:
                    const BorderSide(color: Color(0xFFEF4444), width: 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;
  final Color? borderColor;

  const _SectionCard({
    required this.title,
    required this.isDark,
    required this.children,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ??
              (isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  final bool isDark;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.hint,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          hint,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}

class _DangerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final bool isDark;

  const _DangerButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFEF4444), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFFEF4444).withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final bool isError;
  final bool isDark;

  const _StatusBanner({
    required this.message,
    required this.isError,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isError ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool isDark;

  const _DangerDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          isDark ? const Color(0xFF1F2937) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.warning_rounded,
              color: Color(0xFFEF4444), size: 24),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
