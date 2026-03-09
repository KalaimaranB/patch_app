import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Help & Support',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find answers to common questions or get in touch with our team',
            style: TextStyle(
              fontSize: 14,
              color:
                  isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),

          // Contact options
          Row(
            children: [
              Expanded(
                child: _ContactCard(
                  icon: Icons.email_outlined,
                  title: 'Email Support',
                  subtitle: 'Get help via email',
                  color: const Color(0xFF0D9488),
                  isDark: isDark,
                  onTap: () => _launchUrl('mailto:support@patchmedical.com'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Live Chat',
                  subtitle: 'Chat with support',
                  color: const Color(0xFF06B6D4),
                  isDark: isDark,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.menu_book_rounded,
            title: 'Documentation',
            subtitle: 'Read the docs',
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
            onTap: () {},
            fullWidth: true,
          ),
          const SizedBox(height: 28),

          // FAQ
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          ..._faqs.map((faq) => _FaqCard(faq: faq, isDark: isDark)),
          const SizedBox(height: 28),

          // Still need help
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0D9488).withValues(alpha: isDark ? 0.15 : 0.08),
                  const Color(0xFF06B6D4).withValues(alpha: isDark ? 0.1 : 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF0D9488).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Still need help?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Our support team is available Monday-Friday, 9am-5pm PST',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      _launchUrl('mailto:support@patchmedical.com'),
                  icon: const Icon(Icons.email_outlined, size: 18),
                  label: const Text('Contact Support'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  final bool fullWidth;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
          ),
        ),
        child: fullWidth
            ? Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
    );
  }
}

class _FaqCard extends StatefulWidget {
  final _FaqData faq;
  final bool isDark;

  const _FaqCard({required this.faq, required this.isDark});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark
              ? const Color(0xFF1F2937)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark
                            ? Colors.white
                            : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.faq.answer,
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqData {
  final String question;
  final String answer;
  const _FaqData(this.question, this.answer);
}

const _faqs = [
  _FaqData(
    'How do I connect my Patch device?',
    'Power on your ESP32-based Patch device, connect to its WiFi network (Patch-XXXX), and follow the setup wizard at 192.168.4.1 to register and link your device.',
  ),
  _FaqData(
    'What data does the dashboard show?',
    'The dashboard displays an overview of your patient\'s medical activity, including today\'s dosage count, weekly totals, active devices, and the most recent dosage events.',
  ),
  _FaqData(
    'How do I view dosage history?',
    'Navigate to the Dosage History tab to see a chronological list of all medication administrations. You can filter by date range and view charts showing successful vs. failed dosages.',
  ),
  _FaqData(
    'Can I delete my data?',
    'Yes. Go to Settings and you\'ll find options to either wipe just your medical data or delete your entire account. Both actions are permanent and cannot be undone.',
  ),
  _FaqData(
    'Is my data secure?',
    'Yes. All data is stored securely in our cloud infrastructure with encryption at rest and in transit. Access is restricted to authenticated caregivers only.',
  ),
  _FaqData(
    'How do I change between dark and light mode?',
    'Go to Settings > Appearance and toggle the Dark Mode switch. Your preference is saved automatically and persists between sessions.',
  ),
];
