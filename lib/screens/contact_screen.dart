import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl   = TextEditingController();
  String _interest = '';
  bool   _sent     = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final dark  = state.darkMode;
    final lang  = state.language;

    final interests = [
      'Solar portfolio forecasting', 'Wind farm management',
      'Multi-plant dashboard', 'API integration', 'Enterprise licensing',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(children: [
            Text(Tr.t('getInTouch', lang),
                style: AppTheme.label(dark).copyWith(
                    fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(Tr.t('contactDesc', lang),
                textAlign: TextAlign.center,
                style: AppTheme.small(dark).copyWith(fontSize: 13, height: 1.6)),
            const SizedBox(height: 20),

            // Contact options grid
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12, mainAxisSpacing: 12,
              childAspectRatio: 2.6,
              children: [
                _ContactOpt(Icons.mail_outline,    Tr.t('emailUs', lang),  'info@gridforecast.io', dark),
                _ContactOpt(Icons.phone_outlined,  Tr.t('callUs', lang),   '+1 (800) 555-GRID', dark),
                _ContactOpt(Icons.calendar_today,  Tr.t('bookDemo', lang), '30-min walkthrough', dark),
                _ContactOpt(Icons.chat_bubble_outline, Tr.t('slack', lang), 'Community support', dark),
              ],
            ),
            const SizedBox(height: 20),

            // Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.card(dark),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Tr.t('sendMessage', lang).toUpperCase(),
                      style: AppTheme.small(dark).copyWith(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          letterSpacing: 0.6)),
                  const SizedBox(height: 12),
                  _FormField(_nameCtrl,  Tr.t('yourName', lang),  dark),
                  const SizedBox(height: 10),
                  _FormField(_emailCtrl, Tr.t('emailAddr', lang), dark),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    decoration: BoxDecoration(
                      color: AppTheme.bg2Of(dark),
                      border: Border.all(color: AppTheme.border2Of(dark)),
                      borderRadius: BorderRadius.circular(AppTheme.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _interest.isEmpty ? null : _interest,
                        hint: Text(Tr.t('interestArea', lang),
                            style: AppTheme.label(dark)
                                .copyWith(fontSize: 13, color: AppTheme.txmOf(dark))),
                        isExpanded: true,
                        dropdownColor: AppTheme.bgOf(dark),
                        style: AppTheme.label(dark).copyWith(fontSize: 13),
                        items: interests.map((e) =>
                            DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => _interest = v ?? ''),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bg2Of(dark),
                      border: Border.all(color: AppTheme.border2Of(dark)),
                      borderRadius: BorderRadius.circular(AppTheme.r),
                    ),
                    child: TextField(
                      controller: _msgCtrl, maxLines: 4,
                      style: AppTheme.label(dark).copyWith(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: Tr.t('aboutProject', lang),
                        hintStyle: AppTheme.label(dark)
                            .copyWith(fontSize: 13, color: AppTheme.txmOf(dark)),
                        contentPadding: const EdgeInsets.all(11),
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
                        backgroundColor: _sent
                            ? AppTheme.greenDarker
                            : AppTheme.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.r)),
                        elevation: 0,
                      ),
                      child: Text(
                        _sent ? Tr.t('sent', lang) : Tr.t('sendMessage', lang),
                        style: AppTheme.label(dark).copyWith(
                            fontSize: 13, fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ContactOpt extends StatelessWidget {
  final IconData icon; final String title, sub; final bool dark;
  const _ContactOpt(this.icon, this.title, this.sub, this.dark);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppTheme.bgOf(dark),
      border: Border.all(color: AppTheme.borderOf(dark)),
      borderRadius: BorderRadius.circular(AppTheme.rl),
    ),
    child: Row(children: [
      Icon(icon, color: AppTheme.green, size: 20),
      const SizedBox(width: 10),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: AppTheme.label(dark)
              .copyWith(fontSize: 12, fontWeight: FontWeight.w500)),
          Text(sub, style: AppTheme.small(dark).copyWith(fontSize: 10)),
        ],
      )),
    ]),
  );
}

class _FormField extends StatelessWidget {
  final TextEditingController ctrl; final String hint; final bool dark;
  const _FormField(this.ctrl, this.hint, this.dark);
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.bg2Of(dark),
      border: Border.all(color: AppTheme.border2Of(dark)),
      borderRadius: BorderRadius.circular(AppTheme.r),
    ),
    child: TextField(
      controller: ctrl,
      style: AppTheme.label(dark).copyWith(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTheme.label(dark)
            .copyWith(fontSize: 13, color: AppTheme.txmOf(dark)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        border: InputBorder.none,
      ),
    ),
  );
}