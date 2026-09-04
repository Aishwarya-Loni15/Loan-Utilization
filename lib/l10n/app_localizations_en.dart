// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Laon Utilization';

  @override
  String get appSubtitle => 'AI-Powered Loan Utilization Tracking System';

  @override
  String get signIn => 'Sign In';

  @override
  String get register => 'Register';

  @override
  String get sanctionedLoan => 'Sanctioned Loan Disbursement';

  @override
  String get submitEvidence => 'Submit Loan Utilization Evidence';

  @override
  String get aiScore => 'AI Verification Score';

  @override
  String get riskLow => 'Low Risk (Verified)';

  @override
  String get riskMedium => 'Medium Risk (Review Recommended)';

  @override
  String get riskHigh => 'High Risk (Suspicious)';
}
