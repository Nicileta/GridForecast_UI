import 'package:flutter/material.dart';
import '../theme.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _msgCtrl     = TextEditingController();
  String _interest   = '';
  bool   _sent       = false;

  final _interests = [
    'Solar portfolio forecasting',
    'Wind farm management',
    'Multi-plant dashboard',
    'API integration',
    'Enterprise licensing',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              // Header
              Text('Get in touch',
                  style: AppTheme.label.copyWith(
                      fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(
                'Interested in deploying GridForecast for your energy portfolio? Reach out below.',
                textAlign: TextAlign.center,
                style: AppTheme.small.copyWith(fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 20),

              // Contact options grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.4,
                children: const [
                  _ContactOpt(icon: Icons.mail_outline,      title: 'Email us',    sub: 'info@gridforecast.io'),
                  _ContactOpt(icon: Icons.phone_outlined,    title: 'Call us',     sub: '+1 (800) 555-GRID'),
                  _ContactOpt(icon: Icons.calendar_today,    title: 'Book a demo', sub: '30-min walkthrough'),
                  _ContactOpt(icon: Icons.chat_bubble_outline, title: 'Slack',     sub: 'Community support'),
                ],
              ),
              const SizedBox(height: 20),

              // Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SEND A MESSAGE',
                        style: AppTheme.small.copyWith(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            letterSpacing: 0.6)),
                    const SizedBox(height: 12),

                    _FormField(controller: _nameCtrl,  hint: 'Your name'),
                    const SizedBox(height: 10),
                    _FormField(controller: _emailCtrl, hint: 'Email address'),
                    const SizedBox(height: 10),

                    // Interest dropdown
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      decoration: BoxDecoration(
                        color: AppTheme.bg2,
                        border: Border.all(color: AppTheme.border2),
                        borderRadius: BorderRadius.circular(AppTheme.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _interest.isEmpty ? null : _interest,
                          hint: Text('Interest area...',
                              style: AppTheme.label.copyWith(
                                  fontSize: 13, color: AppTheme.txm)),
                          isExpanded: true,
                          style: AppTheme.label.copyWith(fontSize: 13),
                          items: _interests.map((e) =>
                              DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _interest = v ?? ''),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Message
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.bg2,
                        border: Border.all(color: AppTheme.border2),
                        borderRadius: BorderRadius.circular(AppTheme.r),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        maxLines: 4,
                        style: AppTheme.label.copyWith(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Tell us about your project...',
                          contentPadding: EdgeInsets.all(11),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sent ? null : () {
                          setState(() => _sent = true);
                          Future.delayed(const Duration(seconds: 3), () {
                            if (mounted) setState(() => _sent = false);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _sent ? AppTheme.greenDarker : AppTheme.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _sent ? 'Sent ✓' : 'Send message',
                          style: AppTheme.label.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
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

class _ContactOpt extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  const _ContactOpt({required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(AppTheme.rl),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.green, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTheme.label.copyWith(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(sub,   style: AppTheme.small.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _FormField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        border: Border.all(color: AppTheme.border2),
        borderRadius: BorderRadius.circular(AppTheme.r),
      ),
      child: TextField(
        controller: controller,
        style: AppTheme.label.copyWith(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.label.copyWith(fontSize: 13, color: AppTheme.txm),
          contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          border: InputBorder.none,
        ),
      ),
    );
  }
}