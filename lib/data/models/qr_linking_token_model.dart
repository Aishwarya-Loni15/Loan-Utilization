import '../../domain/entities/qr_linking_token.dart';

class QrLinkingTokenModel extends QrLinkingTokenEntity {
  const QrLinkingTokenModel({
    required super.tokenId,
    required super.loanId,
    required super.bankId,
    required super.bankManagerId,
    required super.createdAt,
    required super.expiresAt,
    required super.isUsed,
    super.isInvalidated,
    super.redeemedByBeneficiaryId,
  });

  factory QrLinkingTokenModel.fromMap(Map<String, dynamic> map, String id) {
    return QrLinkingTokenModel(
      tokenId: id,
      loanId: map['loanId'] ?? '',
      bankId: map['bankId'] ?? '',
      bankManagerId: map['bankManagerId'] ?? map['createdById'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : DateTime.now().add(const Duration(minutes: 15)),
      isUsed: map['isUsed'] ?? false,
      isInvalidated: map['isInvalidated'] ?? false,
      redeemedByBeneficiaryId: map['redeemedByBeneficiaryId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tokenId': tokenId,
      'loanId': loanId,
      'token': token,
      'bankId': bankId,
      'bankManagerId': bankManagerId,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isUsed': isUsed,
      'used': used,
      'isInvalidated': isInvalidated,
      'redeemedByBeneficiaryId': redeemedByBeneficiaryId,
    };
  }
}
