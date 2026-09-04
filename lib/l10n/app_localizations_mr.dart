// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'लोनलेंस';

  @override
  String get appSubtitle => 'एआय-संचालित कर्ज वापर ट्रॅकिंग प्रणाली';

  @override
  String get signIn => 'साइन इन करा';

  @override
  String get register => 'नोंदणी करा';

  @override
  String get sanctionedLoan => 'मंजूर कर्ज वितरण';

  @override
  String get submitEvidence => 'कर्ज वापर पुरावा सादर करा';

  @override
  String get aiScore => 'एआय पडताळणी स्कोअर';

  @override
  String get riskLow => 'कमी धोका (पडताळलेले)';

  @override
  String get riskMedium => 'मध्यम धोका (पुनरावलोकन शिफारस)';

  @override
  String get riskHigh => 'उच्च धोका (संशयास्पद)';
}
