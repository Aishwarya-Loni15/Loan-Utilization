class QrLinkingTokenEntity {
  final String tokenId;
  final String loanId;
  final String bankId;
  final String bankManagerId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;
  final bool isInvalidated;
  final String? redeemedByBeneficiaryId;

  const QrLinkingTokenEntity({
    required this.tokenId,
    required this.loanId,
    required this.bankId,
    required this.bankManagerId,
    required this.createdAt,
    required this.expiresAt,
    required this.isUsed,
    this.isInvalidated = false,
    this.redeemedByBeneficiaryId,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isUsed && !isExpired && !isInvalidated;

  String get token => tokenId;
  bool get used => isUsed;
  String get createdBy => bankManagerId;
}
