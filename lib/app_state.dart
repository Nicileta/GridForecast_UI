// ================================================================
// FIȘIER: app_state.dart
// ROL:    Starea globală a aplicației (Provider pattern)
//
// TOOLS: provider ^6.1.1, shared_preferences ^2.2.2
//
// Conține:
//   • limba selectată (en/ro/ru/fr)
//   • tema (light/dark)
//   • unitatea de măsură (MW/kW)
//   • configurația centralei
//   • persistența setărilor pe disk (SharedPreferences)
// ================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {

  // ── LIMBĂ ────────────────────────────────────────────────────
  String _language = 'en';
  String get language => _language;

  // ── TEMĂ ─────────────────────────────────────────────────────
  bool _darkMode = false;
  bool get darkMode => _darkMode;

  // ── UNITATE DE MĂSURĂ ────────────────────────────────────────
  String _unit = 'MW'; // MW sau kW
  String get unit => _unit;

  // ── CONFIGURAȚIE CENTRALĂ ────────────────────────────────────
  String _plantType  = 'Solar PV';
  double _capacity   = 500;
  double _units      = 4;
  double _efficiency = 82;
  List<Map<String, dynamic>> _plantGroups = [];

  String get plantType  => _plantType;
  double get capacity   => _capacity;
  double get units      => _units;
  double get efficiency => _efficiency;
  List<Map<String, dynamic>> get plantGroups => _plantGroups;

  int get totalCapacity  => (_capacity * _units).round();
  int get expectedOutput => (_capacity * _units * _efficiency / 100).round();

  // ── SETĂRI GRAFIC ────────────────────────────────────────────
  bool _showConfidenceBand = true;
  bool _showDataPoints     = false;
  bool _showGrid           = true;
  String _chartType        = 'line'; // line / area

  bool   get showConfidenceBand => _showConfidenceBand;
  bool   get showDataPoints     => _showDataPoints;
  bool   get showGrid           => _showGrid;
  String get chartType          => _chartType;

  // ── INIT ─────────────────────────────────────────────────────
  AppState() { _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _language  = p.getString('language')  ?? 'en';
    _darkMode  = p.getBool('darkMode')    ?? false;
    _unit      = p.getString('unit')      ?? 'MW';
    if (_unit == 'GW') _unit = 'MW';
    _plantType = p.getString('plantType') ?? 'Solar PV';
    _capacity  = p.getDouble('capacity')  ?? 500;
    _units     = p.getDouble('units')     ?? 4;
    _efficiency= p.getDouble('efficiency')?? 82;
    _showConfidenceBand = p.getBool('showConfidenceBand') ?? true;
    _showDataPoints     = p.getBool('showDataPoints')     ?? false;
    _showGrid           = p.getBool('showGrid')           ?? true;
    _chartType          = p.getString('chartType')        ?? 'line';
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('language',  _language);
    await p.setBool('darkMode',    _darkMode);
    await p.setString('unit',      _unit);
    await p.setString('plantType', _plantType);
    await p.setDouble('capacity',  _capacity);
    await p.setDouble('units',     _units);
    await p.setDouble('efficiency',_efficiency);
    await p.setBool('showConfidenceBand', _showConfidenceBand);
    await p.setBool('showDataPoints',     _showDataPoints);
    await p.setBool('showGrid',           _showGrid);
    await p.setString('chartType',        _chartType);
  }

  // ── SETTERS ──────────────────────────────────────────────────
  void setLanguage(String v)  { _language  = v; notifyListeners(); _save(); }
  void setDarkMode(bool v)    { _darkMode  = v; notifyListeners(); _save(); }
  void setUnit(String v)      { _unit      = v == 'GW' ? 'MW' : v; notifyListeners(); _save(); }
  void setPlantType(String v) { _plantType = v; notifyListeners(); _save(); }
  void setCapacity(double v)  { _capacity  = v; notifyListeners(); _save(); }
  void setUnits(double v)     { _units     = v; notifyListeners(); _save(); }
  void setEfficiency(double v){ _efficiency= v; notifyListeners(); _save(); }

  void addPlantGroup() {
    _plantGroups = [..._plantGroups, {
      'type': _plantType, 'capacity': _capacity, 'units': _units,
    }];
    notifyListeners();
  }

  void removePlantGroup(int i) {
    _plantGroups = [..._plantGroups]..removeAt(i);
    notifyListeners();
  }

  void setShowConfidenceBand(bool v){ _showConfidenceBand = v; notifyListeners(); _save(); }
  void setShowDataPoints(bool v)    { _showDataPoints     = v; notifyListeners(); _save(); }
  void setShowGrid(bool v)          { _showGrid           = v; notifyListeners(); _save(); }
  void setChartType(String v)       { _chartType          = v; notifyListeners(); _save(); }
}

// ── TRADUCER ─────────────────────────────────────────────────────
class Tr {
  static const _strings = <String, Map<String, String>>{
    'en': {
      'appName':        'GridForecast',
      'forecast':       'Forecast',
      'historical':     'Historical',
      'contact':        'Contact',
      'settings':       'Settings',
      'plantConfig':    'Plant Configuration',
      'plantType':      'Plant type',
      'capacity':       'Installed capacity',
      'numUnits':       'Number of units',
      'efficiency':     'Efficiency',
      'addPlant':       'Add plant group',
      'computedOutput': 'Computed output',
      'totalCap':       'Total capacity',
      'expectedOut':    'Expected output',
      'loadFactor':     'Load factor',
      'avgDaily':       'Avg daily output',
      'peakForecast':   'Peak forecast',
      'minForecast':    'Min forecast',
      'confidence':     'Confidence',
      'productionForecast': 'Production forecast',
      'forecastOutput': 'Forecast output',
      'confBand':       'Confidence band',
      'histComparison': 'Historical output comparison',
      'actualOutput':   'Actual output',
      'expectedBaseline': 'Expected baseline',
      'dailyDeviation': 'Daily deviation (%)',
      'getInTouch':     'Get in touch',
      'contactDesc':    'Interested in deploying GridForecast for your energy portfolio?',
      'emailUs':        'Email us',
      'callUs':         'Call us',
      'bookDemo':       'Book a demo',
      'slack':          'Slack channel',
      'sendMessage':    'Send message',
      'yourName':       'Your name',
      'emailAddr':      'Email address',
      'interestArea':   'Interest area...',
      'aboutProject':   'Tell us about your project...',
      'sent':           'Sent ✓',
      'appearance':     'Appearance',
      'darkMode':       'Dark mode',
      'language':       'Language',
      'units':          'Display units',
      'chartSettings':  'Chart settings',
      'showConfBand':   'Show confidence band',
      'showDataPts':    'Show data points',
      'showGrid':       'Show grid lines',
      'chartType':      'Chart style',
'line':           'Line',
      'area':           'Area',
      'about':          'About',
      'version':        'Version 1.0.0',
      'builtWith':      'Built with Flutter',
      'warnings':       'Warnings',
      'warningsDesc':   'Estimated potential production issues based on weather forecasts.',
      'deviationForecast': 'Deviation forecast (%)',
      'potentialDeviation': 'Potential output deviation detected',
      'weatherAffected': 'Weather conditions may affect production on this date.',
    },
    'ro': {
      'appName':        'GridForecast',
      'forecast':       'Prognoză',
      'historical':     'Istoric',
      'contact':        'Contact',
      'settings':       'Setări',
      'plantConfig':    'Configurare Centrală',
      'plantType':      'Tip centrală',
      'capacity':       'Capacitate instalată',
      'numUnits':       'Număr unități',
      'efficiency':     'Eficiență',
      'addPlant':       'Adaugă grup',
      'computedOutput': 'Output calculat',
      'totalCap':       'Capacitate totală',
      'expectedOut':    'Output estimat',
      'loadFactor':     'Factor sarcină',
      'avgDaily':       'Output mediu zilnic',
      'peakForecast':   'Vârf prognoză',
      'minForecast':    'Minim prognoză',
      'confidence':     'Încredere',
      'productionForecast': 'Prognoză producție',
      'forecastOutput': 'Output prognoză',
      'confBand':       'Bandă încredere',
      'histComparison': 'Comparație istorică',
      'actualOutput':   'Output real',
      'expectedBaseline': 'Referință estimată',
      'dailyDeviation': 'Deviație zilnică (%)',
      'getInTouch':     'Contactează-ne',
      'contactDesc':    'Interesat de GridForecast pentru portofoliul tău?',
      'emailUs':        'Email',
      'callUs':         'Telefon',
      'bookDemo':       'Rezervă demo',
      'slack':          'Canal Slack',
      'sendMessage':    'Trimite mesaj',
      'yourName':       'Numele tău',
      'emailAddr':      'Adresă email',
      'interestArea':   'Domeniu de interes...',
      'aboutProject':   'Spune-ne despre proiectul tău...',
      'sent':           'Trimis ✓',
      'appearance':     'Aspect',
      'darkMode':       'Mod întunecat',
      'language':       'Limbă',
      'units':          'Unități afișare',
      'chartSettings':  'Setări grafic',
      'showConfBand':   'Afișează banda de încredere',
      'showDataPts':    'Afișează puncte de date',
      'showGrid':       'Afișează linii grilă',
      'chartType':      'Stil grafic',
'line':           'Linie',
      'area':           'Arie',
      'about':          'Despre',
      'version':        'Versiune 1.0.0',
      'builtWith':      'Construit cu Flutter',
      'warnings':       'Avertismente',
      'warningsDesc':   'Problemele potențiale de producție estimate bazate pe prognoza meteorologică.',
      'deviationForecast': 'Prognoză deviație (%)',
      'potentialDeviation': 'Deviere de producție detectată',
      'weatherAffected': 'Condițiile meteo pot afecta producția în această dată.',
    },
    'de': {
      'appName':        'GridForecast',
      'forecast':       'Prognose',
      'historical':     'Historisch',
      'contact':        'Kontakt',
      'settings':       'Einstellungen',
      'plantConfig':    'Anlagenkonfiguration',
      'plantType':      'Anlagentyp',
      'capacity':       'Installierte Leistung',
      'numUnits':       'Anzahl Einheiten',
      'efficiency':     'Wirkungsgrad',
      'addPlant':       'Gruppe hinzufügen',
      'computedOutput': 'Berechnete Leistung',
      'totalCap':       'Gesamtkapazität',
      'expectedOut':    'Erwartete Leistung',
      'loadFactor':     'Lastfaktor',
      'avgDaily':       'Ø Tagesleistung',
      'peakForecast':   'Spitzenprognose',
      'minForecast':    'Mindestprognose',
      'confidence':     'Konfidenz',
      'productionForecast': 'Erzeugungsprognose',
      'forecastOutput': 'Prognoseleistung',
      'confBand':       'Konfidenzband',
      'histComparison': 'Historischer Vergleich',
      'actualOutput':   'Tatsächliche Leistung',
      'expectedBaseline': 'Erwartete Baseline',
      'dailyDeviation': 'Tägliche Abweichung (%)',
      'getInTouch':     'Kontakt aufnehmen',
      'contactDesc':    'Interesse an GridForecast für Ihr Energieportfolio?',
      'emailUs':        'E-Mail',
      'callUs':         'Anrufen',
      'bookDemo':       'Demo buchen',
      'slack':          'Slack-Kanal',
      'sendMessage':    'Nachricht senden',
      'yourName':       'Ihr Name',
      'emailAddr':      'E-Mail-Adresse',
      'interestArea':   'Interessensbereich...',
      'aboutProject':   'Erzählen Sie uns von Ihrem Projekt...',
      'sent':           'Gesendet ✓',
      'appearance':     'Erscheinungsbild',
      'darkMode':       'Dunkelmodus',
      'language':       'Sprache',
      'units':          'Anzeigeeinheiten',
      'chartSettings':  'Diagrammeinstellungen',
      'showConfBand':   'Konfidenzband anzeigen',
      'showDataPts':    'Datenpunkte anzeigen',
      'showGrid':       'Gitterlinien anzeigen',
      'chartType':      'Diagrammstil',
'line':           'Linie',
      'area':           'Fläche',
      'about':          'Über',
      'version':        'Version 1.0.0',
      'builtWith':      'Erstellt mit Flutter',
      'warnings':       'Warnungen',
      'warningsDesc':   'Geschätzte mögliche Produktionsprobleme basierend auf Wettervorhersagen.',
      'deviationForecast': 'Abweichungsprognose (%)',
      'potentialDeviation': 'Mögliche Produktionsabweichung erkannt',
      'weatherAffected': 'Wetterbedingungen können die Produktion an diesem Tag beeinträchtigen.',
    },
    'ru': {
      'appName':        'GridForecast',
      'forecast':       'Прогноз',
      'historical':     'Исторические данные',
      'contact':        'Контакты',
      'settings':       'Настройки',
      'plantConfig':    'Конфигурация установки',
      'plantType':      'Тип установки',
      'capacity':       'Установленная мощность',
      'numUnits':       'Количество единиц',
      'efficiency':     'Эффективность',
      'addPlant':       'Добавить группу установки',
      'computedOutput': 'Рассчитанная выработка',
      'totalCap':       'Общая мощность',
      'expectedOut':    'Ожидаемая выработка',
      'loadFactor':     'Коэффициент загрузки',
      'avgDaily':       'Среднесуточная выработка',
      'peakForecast':   'Пиковый прогноз',
      'minForecast':    'Минимум прогноза',
      'confidence':     'Доверие',
      'productionForecast': 'Прогноз производства',
      'forecastOutput': 'Прогнозируемая выработка',
      'confBand':       'Полоса доверия',
      'histComparison': 'Сравнение с историей',
      'actualOutput':   'Фактическая выработка',
      'expectedBaseline': 'Ожидаемая база',
      'dailyDeviation': 'Отклонение за день (%)',
      'getInTouch':     'Свяжитесь с нами',
      'contactDesc':    'Заинтересованы в развёртывании GridForecast для вашего портфеля энергоресурсов?',
      'emailUs':        'Напишите нам',
      'callUs':         'Позвоните нам',
      'bookDemo':       'Заказать демо',
      'slack':          'Канал Slack',
      'sendMessage':    'Отправить сообщение',
      'yourName':       'Ваше имя',
      'emailAddr':      'Электронная почта',
      'interestArea':   'Область интересов...',
      'aboutProject':   'Расскажите о вашем проекте...',
      'sent':           'Отправлено ✓',
      'appearance':     'Внешний вид',
      'darkMode':       'Тёмная тема',
      'language':       'Язык',
      'units':          'Единицы отображения',
      'chartSettings':  'Настройки графика',
      'showConfBand':   'Показывать полосу доверия',
      'showDataPts':    'Показывать точки данных',
      'showGrid':       'Показывать сетку',
      'chartType':      'Тип графика',
'line':           'Линия',
      'area':           'Область',
      'about':          'О приложении',
      'version':        'Версия 1.0.0',
      'builtWith':      'Создано с помощью Flutter',
      'warnings':       'Предупреждения',
      'warningsDesc':   'Оцененные потенциальные проблемы с производством на основе прогноза погоды.',
      'deviationForecast': 'Прогноз отклонения (%)',
      'potentialDeviation': 'Обнаружено отклонение от производства',
      'weatherAffected': 'Погодные условия могут повлиять на производство в этот день.',
    },
    'fr': {
      'appName':        'GridForecast',
      'forecast':       'Prévision',
      'historical':     'Historique',
      'contact':        'Contact',
      'settings':       'Paramètres',
      'plantConfig':    'Configuration Centrale',
      'plantType':      'Type de centrale',
      'capacity':       'Capacité installée',
      'numUnits':       'Nombre d\'unités',
      'efficiency':     'Efficacité',
      'addPlant':       'Ajouter groupe',
      'computedOutput': 'Production calculée',
      'totalCap':       'Capacité totale',
      'expectedOut':    'Production estimée',
      'loadFactor':     'Facteur de charge',
      'avgDaily':       'Production journalière',
      'peakForecast':   'Pic de prévision',
      'minForecast':    'Min de prévision',
      'confidence':     'Confiance',
      'productionForecast': 'Prévision de production',
      'forecastOutput': 'Production prévue',
      'confBand':       'Bande de confiance',
      'histComparison': 'Comparaison historique',
      'actualOutput':   'Production réelle',
      'expectedBaseline': 'Référence attendue',
      'dailyDeviation': 'Écart journalier (%)',
      'getInTouch':     'Nous contacter',
      'contactDesc':    'Intéressé par GridForecast pour votre portefeuille?',
      'emailUs':        'Email',
      'callUs':         'Téléphone',
      'bookDemo':       'Réserver démo',
      'slack':          'Canal Slack',
      'sendMessage':    'Envoyer message',
      'yourName':       'Votre nom',
      'emailAddr':      'Adresse email',
      'interestArea':   'Domaine d\'intérêt...',
      'aboutProject':   'Parlez-nous de votre projet...',
      'sent':           'Envoyé ✓',
      'appearance':     'Apparence',
      'darkMode':       'Mode sombre',
      'language':       'Langue',
      'units':          'Unités d\'affichage',
      'chartSettings':  'Paramètres graphique',
      'showConfBand':   'Bande de confiance',
      'showDataPts':    'Points de données',
      'showGrid':       'Lignes de grille',
      'chartType':      'Style graphique',
      'line':           'Ligne',
      'area':           'Aire',
'about':          'À propos',
       'version':        'Version 1.0.0',
       'builtWith':      'Construit avec Flutter',
       'warnings':       'Avertissements',
       'warningsDesc':   'Problèmes de production potentiels estimés basés sur les prévisions météorologiques.',
       'deviationForecast': 'Prévision d\'écart (%)',
     },
  };

  static String t(String key, String lang) =>
      _strings[lang]?[key] ?? _strings['en']![key] ?? key;
}