// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'लोनलेंस';

  @override
  String get appSubtitle => 'एआई-संचालित ऋण उपयोग ट्रैकिंग प्रणाली';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get register => 'पंजीकरण करें';

  @override
  String get sanctionedLoan => 'स्वीकृत ऋण संवितरण';

  @override
  String get submitEvidence => 'ऋण उपयोग प्रमाण प्रस्तुत करें';

  @override
  String get aiScore => 'एआई सत्यापन स्कोर';

  @override
  String get riskLow => 'कम जोखिम (सत्यापित)';

  @override
  String get riskMedium => 'मध्यम जोखिम (समीक्षा की सिफारिश)';

  @override
  String get riskHigh => 'उच्च जोखिम (संदिग्ध)';
}
