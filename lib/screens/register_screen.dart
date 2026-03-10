import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/responsive_layout.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = [
      _StepData(
        icon: Icons.power_settings_new_rounded,
        title: 'Power on your Patch device',
        description:
            'Ensure your ESP32-based Patch Medical device is powered on and the LED indicator is blinking.',
      ),
      _StepData(
        icon: Icons.wifi_rounded,
        title: 'Connect to device WiFi',
        description:
            'On your phone or computer, connect to the WiFi network named Patch-XXXX (where XXXX is your device ID).',
        code: 'Patch-XXXX',
      ),
      _StepData(
        icon: Icons.open_in_browser_rounded,
        title: 'Open device portal',
        description:
            'Once connected, a setup page will automatically open. If not, navigate to 192.168.4.1 in your browser.',
        code: '192.168.4.1',
      ),
      _StepData(
        icon: Icons.person_add_rounded,
        title: 'Create your account',
        description:
            'Follow the on-screen instructions to create your caregiver account and link it to your device.',
      ),
      _StepData(
        icon: Icons.login_rounded,
        title: 'Return here to login',
        description:
            'Once registration is complete, return to this dashboard and log in with your new credentials.',
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF030712), const Color(0xFF0F172A), const Color(0xFF042F2E)]
                : [const Color(0xFFF0FDFA), const Color(0xFFECFDF5), const Color(0xFFF0F9FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: AppLayout.padding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const SizedBox(height: 8),

                // Header
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D9488), Color(0xFF06B6D4)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.app_registration_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  'Device Registration',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Register through your Patch Medical device',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                ),
                const SizedBox(height: 32),

                // Steps card
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF111827).withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1F2937)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to Register',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      ...steps.asMap().entries.map((entry) {
                        final index = entry.key;
                        final step = entry.value;
                        return _buildStep(context, index + 1, step, isDark,
                            isLast: index == steps.length - 1);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Help note
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.help_outline_rounded,
                          color: Color(0xFF0D9488), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Need help? Contact your healthcare provider or visit our support page.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Secure device-based registration for patient safety',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF94A3B8),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(
      BuildContext context, int number, _StepData step, bool isDark,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(step.icon, color: Colors.white, size: 18),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0D9488).withValues(alpha: 0.5),
                        const Color(0xFF0D9488).withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                if (step.code != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1F2937)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      step.code!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0D9488),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepData {
  final IconData icon;
  final String title;
  final String description;
  final String? code;

  _StepData({
    required this.icon,
    required this.title,
    required this.description,
    this.code,
  });
}
