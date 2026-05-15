⚡ GridForecast

Single-page power plant energy forecast dashboard built with Flutter Web.


📋 Overview
GridForecast is a prototype UI dashboard for monitoring and forecasting energy output from power plants. It allows engineers and energy managers to configure plant technical specs, visualize production forecasts, compare historical data, and get in contact with the team.

✨ Features
FeatureDescription🏭 Plant ConfigurationDefine plant type, installed capacity (MW), number of units, and efficiency (%)➕ Multi-plant supportAdd multiple plant groups and see aggregated computed output📈 Forecast ScreenProduction forecast from 1 day up to 2 weeks with confidence band📊 Historical ScreenActual vs expected output comparison for up to 1 month + daily deviation chart📬 Contact ScreenEmail, phone, demo booking, Slack — plus inline contact form

🗂️ Project Structure
prototip_ui/
├── lib/
│   ├── main.dart                  # Entry point
│   ├── app.dart                   # App shell — topbar + layout + state
│   ├── theme.dart                 # Colors, text styles, decorations
│   ├── screens/
│   │   ├── forecast_screen.dart   # Forecast tab (charts + metric cards)
│   │   ├── historical_screen.dart # Historical tab (comparison + deviation)
│   │   └── contact_screen.dart    # Contact tab (options + form)
│   └── widgets/
│       ├── sidebar.dart           # Left sidebar — plant config + computed output
│       └── metric_card.dart       # Reusable metric card widget
├── test/
│   └── widget_test.dart           # Basic smoke test
└── pubspec.yaml                   # Dependencies

🚀 Getting Started
Prerequisites

Flutter SDK ≥ 3.0.0
VS Code with Flutter + Dart extensions installed
Microsoft Edge or Chrome browser

Installation
bash# 1. Clone or open the project in VS Code
cd prototip_ui

# 2. Install dependencies
flutter pub get

# 3. Run on Edge
flutter run -d edge

# or on Chrome
flutter run -d chrome
Run without terminal (VS Code)

Click the device name in the blue bottom status bar
Select Edge from the list
Press F5


📦 Dependencies
yamlfl_chart: ^0.68.0       # Charts — line, bar
google_fonts: ^6.1.0    # Inter font

🖥️ Screens
Forecast
Configure your plant specs in the sidebar and view the energy production forecast over 1d / 3d / 7d / 14d. Metric cards show average daily output, peak, minimum, and model confidence.
Historical
Compare actual vs expected output over 1 week to 1 month. A second bar chart shows daily deviation percentage — green for over-performance, red for shortfall.
Contact
Four quick-contact options (email, phone, demo, Slack) and an inline message form with interest-area selection.

🎨 Design Tokens
TokenValueUsage--green#1D9E75Primary accent--green-bg#E1F5EEPill backgrounds--bg#FFFFFFCard backgrounds--bg2#F5F5F2Page background--tx#1A1A18Primary textFontInter (Google Fonts)All text

📌 Roadmap / Subtasks

 Define UI color palette & typography
 Set up Flutter project structure
 Implement sidebar — plant tech specs
 Implement forecast screen (1d – 14d)
 Implement historical screen (1w – 1mo)
 Implement contact screen
 Test responsiveness & interactivity
 Final review & handoff


👤 Author
Built as a prototype UI for energy portfolio forecasting.