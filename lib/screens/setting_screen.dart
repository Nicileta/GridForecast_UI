import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _langNames = {
    'en': '🇬🇧  English', 'ro': '🇷🇴  Română',
    'ru': '🇷🇺  Русский', 'fr': '🇫🇷  Français',
  };

  @override
  Widget build(BuildContext context) {
    final s    = context.watch<AppState>();
    final dark = s.darkMode;
    final lang = s.language;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── APPEARANCE ──────────────────────────────────
              _SectionHeader(Tr.t('appearance', lang), dark),

              _SettingCard(dark: dark, children: [
                _ToggleRow(
                  icon: Icons.dark_mode_outlined,
                  label: Tr.t('darkMode', lang),
                  value: dark, dark: dark,
                  onChanged: context.read<AppState>().setDarkMode,
                ),
                _Divider(dark),
                // Language picker
                _LabelRow(
                  icon: Icons.language,
                  label: Tr.t('language', lang),
                  dark: dark,
                ),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8,
                  children: _langNames.entries.map((e) {
                    final active = s.language == e.key;
                    return GestureDetector(
                      onTap: () => context.read<AppState>().setLanguage(e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? AppTheme.green
                              : AppTheme.bg2Of(dark),
                          borderRadius: BorderRadius.circular(AppTheme.r),
                          border: Border.all(
                              color: active
                                  ? AppTheme.green
                                  : AppTheme.border2Of(dark)),
                        ),
                        child: Text(e.value,
                            style: AppTheme.label(dark).copyWith(
                              fontSize: 13,
                              color: active
                                  ? Colors.white
                                  : AppTheme.txOf(dark),
                              fontWeight: active
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            )),
                      ),
                    );
                  }).toList(),
                ),
                _Divider(dark),
                // Units picker
                _LabelRow(
                    icon: Icons.straighten, label: Tr.t('units', lang),
                    dark: dark),
                const SizedBox(height: 10),
                Row(children: ['MW', 'kW'].map((u) {
                  final active = s.unit == u;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => context.read<AppState>().setUnit(u),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? AppTheme.green : AppTheme.bg2Of(dark),
                          borderRadius: BorderRadius.circular(AppTheme.r),
                          border: Border.all(
                              color: active
                                  ? AppTheme.green
                                  : AppTheme.border2Of(dark)),
                        ),
                        child: Text(u,
                            style: AppTheme.label(dark).copyWith(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: active ? Colors.white : AppTheme.txOf(dark),
                            )),
                      ),
                    ),
                  );
                }).toList()),
              ]),

              const SizedBox(height: 20),

              // ── CHART SETTINGS ───────────────────────────────
              _SectionHeader(Tr.t('chartSettings', lang), dark),

              _SettingCard(dark: dark, children: [
                _ToggleRow(
                  icon: Icons.blur_on,
                  label: Tr.t('showConfBand', lang),
                  value: s.showConfidenceBand, dark: dark,
                  onChanged: context.read<AppState>().setShowConfidenceBand,
                ),
                _Divider(dark),
                _ToggleRow(
                  icon: Icons.scatter_plot,
                  label: Tr.t('showDataPts', lang),
                  value: s.showDataPoints, dark: dark,
                  onChanged: context.read<AppState>().setShowDataPoints,
                ),
                _Divider(dark),
                _ToggleRow(
                  icon: Icons.grid_on,
                  label: Tr.t('showGrid', lang),
                  value: s.showGrid, dark: dark,
                  onChanged: context.read<AppState>().setShowGrid,
                ),
                _Divider(dark),
                _LabelRow(icon: Icons.show_chart,
                    label: Tr.t('chartType', lang), dark: dark),
                const SizedBox(height: 10),
                Row(children: [
                  ['line', Icons.show_chart, Tr.t('line', lang)],
                  ['area', Icons.area_chart, Tr.t('area', lang)],
                ].map((item) {
                  final key   = item[0] as String;
                  final icon  = item[1] as IconData;
                  final label = item[2] as String;
                  final active = s.chartType == key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          context.read<AppState>().setChartType(key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? AppTheme.green : AppTheme.bg2Of(dark),
                          borderRadius: BorderRadius.circular(AppTheme.r),
                          border: Border.all(
                              color: active
                                  ? AppTheme.green
                                  : AppTheme.border2Of(dark)),
                        ),
                        child: Row(children: [
                          Icon(icon, size: 15,
                              color: active ? Colors.white : AppTheme.tx2Of(dark)),
                          const SizedBox(width: 6),
                          Text(label, style: AppTheme.label(dark).copyWith(
                            fontSize: 13, fontWeight: FontWeight.w500,
                            color: active ? Colors.white : AppTheme.txOf(dark),
                          )),
                        ]),
                      ),
                    ),
                  );
                }).toList()),
              ]),

              const SizedBox(height: 20),

              // ── ABOUT ────────────────────────────────────────
              _SectionHeader(Tr.t('about', lang), dark),
              _SettingCard(dark: dark, children: [
                _InfoRow(Icons.info_outline,
                    Tr.t('version', lang), dark),
                _Divider(dark),
                _InfoRow(Icons.flutter_dash,
                    Tr.t('builtWith', lang), dark),
                _Divider(dark),
                // Removed trademark/copyright line as requested
              ]),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ── HELPERS ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text; final bool dark;
  const _SectionHeader(this.text, this.dark);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text.toUpperCase(),
        style: AppTheme.sectionLabel(dark)),
  );
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children; final bool dark;
  const _SettingCard({required this.children, required this.dark});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: AppTheme.card(dark),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children),
  );
}

class _ToggleRow extends StatelessWidget {
  final IconData icon; final String label;
  final bool value, dark; final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.icon, required this.label,
    required this.value, required this.dark, required this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(icon, size: 18, color: AppTheme.tx2Of(dark)),
      const SizedBox(width: 12),
      Expanded(child: Text(label,
          style: AppTheme.label(dark).copyWith(fontSize: 14))),
      Switch(
        value: value, onChanged: onChanged,
        activeThumbColor: AppTheme.green,
      ),
    ]),
  );
}

class _LabelRow extends StatelessWidget {
  final IconData icon; final String label; final bool dark;
  const _LabelRow({required this.icon, required this.label, required this.dark});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Row(children: [
      Icon(icon, size: 18, color: AppTheme.tx2Of(dark)),
      const SizedBox(width: 12),
      Text(label, style: AppTheme.label(dark).copyWith(fontSize: 14)),
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String label; final bool dark;
  const _InfoRow(this.icon, this.label, this.dark);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Icon(icon, size: 18, color: AppTheme.green),
      const SizedBox(width: 12),
      Text(label, style: AppTheme.label(dark).copyWith(fontSize: 14)),
    ]),
  );
}

class _Divider extends StatelessWidget {
  final bool dark;
  const _Divider(this.dark);
  @override
  Widget build(BuildContext context) =>
      Divider(color: AppTheme.borderOf(dark), height: 1);
}