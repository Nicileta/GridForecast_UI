import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'theme.dart';
import 'screens/forecast_screen.dart';
import 'screens/historical_screen.dart';
import 'screens/warnings_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/setting_screen.dart';
import 'widgets/sidebar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  // Tab definitions
  static const _tabIcons  = [Icons.show_chart, Icons.history, Icons.warning_amber_outlined, Icons.mail_outline, Icons.settings_outlined];

  List<String> _tabLabels(String lang) => [
    Tr.t('forecast', lang), Tr.t('historical', lang),
    Tr.t('warnings', lang), Tr.t('contact', lang),  
    Tr.t('settings', lang),
  ];

  Widget _screen(int i, AppState s) {
    switch (i) {
      case 0: return const ForecastScreen();
      case 1: return const HistoricalScreen();
      case 2: return const WarningsScreen();
      case 3: return const ContactScreen();
      case 4: return const SettingsScreen();
      default: return const ForecastScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppState>();
    final dark   = state.darkMode;
    final lang   = state.language;
    final labels = _tabLabels(lang);

    // Responsive breakpoint — mobile < 600px
    final width   = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      backgroundColor: AppTheme.bg2Of(dark),
      // ── MOBILE: bottom nav bar ──────────────────────────────
      bottomNavigationBar: isMobile ? NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: AppTheme.bgOf(dark),
        surfaceTintColor: Colors.transparent,
        destinations: List.generate(5, (i) => NavigationDestination(
          icon: Icon(_tabIcons[i]),
          label: labels[i],
        )),
      ) : null,

      body: Column(
        children: [
          // ── TOPBAR ──────────────────────────────────────────
          _TopBar(
            tab: _tab,
            labels: labels,
            icons: _tabIcons,
            isMobile: isMobile,
            dark: dark,
            lang: lang,
            onTabChanged: (i) => setState(() => _tab = i),
          ),

          Expanded(
            child: isMobile
                // MOBILE: full-width content, no sidebar
                ? _screen(_tab, state)
                // DESKTOP/TABLET: sidebar + content
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
// Sidebar only on Forecast/Historical/Warnings tabs (desktop)
                       if (_tab == 0 || _tab == 1 || _tab == 2)
                         Sidebar(dark: dark, lang: lang),
                       Expanded(
                         child: IndexedStack(
                           index: _tab,
                           children: List.generate(5, (i) => _screen(i, state)),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── TOPBAR ─────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final int tab;
  final List<String> labels;
  final List<IconData> icons;
  final bool isMobile, dark;
  final String lang;
  final ValueChanged<int> onTabChanged;

  const _TopBar({
    required this.tab, required this.labels, required this.icons,
    required this.isMobile, required this.dark, required this.lang,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.bgOf(dark),
        border: Border(bottom: BorderSide(color: AppTheme.borderOf(dark))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Logo
          const Icon(Icons.bolt, color: AppTheme.green, size: 20),
          const SizedBox(width: 7),
          Text(Tr.t('appName', lang),
              style: AppTheme.label(dark).copyWith(
                  fontSize: 15, fontWeight: FontWeight.w600)),

          const Spacer(),

          // Desktop nav tabs (hidden on mobile — uses bottom nav)
          if (!isMobile)
            Row(
              children: List.generate(labels.length, (i) {
                final active = tab == i;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(99),
                    onTap: () => onTabChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? AppTheme.bg2Of(dark) : Colors.transparent,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                            color: active
                                ? AppTheme.border2Of(dark)
                                : Colors.transparent),
                      ),
                      child: Row(children: [
                        Icon(icons[i], size: 14,
                            color: active
                                ? AppTheme.txOf(dark)
                                : AppTheme.tx2Of(dark)),
                        const SizedBox(width: 5),
                        Text(labels[i],
                            style: AppTheme.label(dark).copyWith(
                              fontSize: 13,
                              fontWeight: active
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              color: active
                                  ? AppTheme.txOf(dark)
                                  : AppTheme.tx2Of(dark),
                            )),
                      ]),
                    ),
                  ),
                );
              }),
            ),

          // Language flag picker (always visible)
          const SizedBox(width: 8),
          _LangPicker(dark: dark),
        ],
      ),
    );
  }
}

// ── LANGUAGE PICKER ────────────────────────────────────────────────
class _LangPicker extends StatelessWidget {
  final bool dark;
  const _LangPicker({required this.dark});

  static const _langs = {
    'en': '🇬🇧', 'ro': '🇷🇴', 'ru': '🇷🇺', 'fr': '🇫🇷',
  };

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PopupMenuButton<String>(
      onSelected: state.setLanguage,
      tooltip: 'Language',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border2Of(dark)),
          borderRadius: BorderRadius.circular(AppTheme.r),
          color: AppTheme.bgOf(dark),
        ),
        child: Row(children: [
          Text(_langs[state.language] ?? '🌐',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(state.language.toUpperCase(),
              style: AppTheme.label(dark)
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 2),
          Icon(Icons.arrow_drop_down,
              size: 16, color: AppTheme.tx2Of(dark)),
        ]),
      ),
      itemBuilder: (_) => _langs.entries.map((e) => PopupMenuItem(
        value: e.key,
        child: Row(children: [
          Text(e.value, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text(e.key.toUpperCase(),
              style: AppTheme.label(dark)
                  .copyWith(fontWeight: FontWeight.w500)),
        ]),
      )).toList(),
    );
  }
}