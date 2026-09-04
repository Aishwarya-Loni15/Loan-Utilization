import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/qr_linking_token.dart';
import '../../data/datasources/remote/qr_linking_remote_datasource.dart';

class LoanQrDialog extends StatefulWidget {
  final LoanEntity loan;
  final QrLinkingTokenEntity? initialToken;

  const LoanQrDialog({
    super.key,
    required this.loan,
    this.initialToken,
  });

  static Future<void> show(BuildContext context, LoanEntity loan, {QrLinkingTokenEntity? initialToken}) {
    return showDialog<void>(
      context: context,
      builder: (context) => LoanQrDialog(loan: loan, initialToken: initialToken),
    );
  }

  @override
  State<LoanQrDialog> createState() => _LoanQrDialogState();
}

class _LoanQrDialogState extends State<LoanQrDialog> {
  QrLinkingTokenEntity? _currentToken;
  bool _isLoading = false;
  Timer? _timer;
  int _secondsRemaining = 900; // 15 mins default

  @override
  void initState() {
    super.initState();
    if (widget.initialToken != null) {
      _currentToken = widget.initialToken;
      _startTimer();
    } else {
      _generateNewToken();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_currentToken == null) return;
    final diff = _currentToken!.expiresAt.difference(DateTime.now()).inSeconds;
    setState(() {
      _secondsRemaining = diff > 0 ? diff : 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _generateNewToken() async {
    setState(() => _isLoading = true);
    try {
      final token = await QrLinkingRemoteDataSource().createToken(
        loanId: widget.loan.loanId,
        bankId: widget.loan.bankId,
        bankManagerId: 'bank_mgr',
      );
      setState(() {
        _currentToken = token;
      });
      _startTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate token: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final loanNumber = widget.loan.loanAccountNumber ?? widget.loan.loanId;
    final tokenString = _currentToken?.tokenId ?? 'LL-TOKEN-PENDING';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Temporary Linking QR',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield_outlined, color: AppColors.info, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Secure QR contains ONLY a single-use token. Sensitive financial data is never stored in the QR code.',
                        style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      Container(
                        width: 180,
                        height: 180,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _QrPainter(data: tokenString),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Token display & copy button
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: tokenString));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied token "$tokenString" to clipboard!')),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tokenString,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 14,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.copy_rounded, color: AppColors.primary, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Expiration countdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: _secondsRemaining > 0 ? AppColors.warning : AppColors.danger,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _secondsRemaining > 0
                              ? 'Expires in: ${_formatTimer(_secondsRemaining)}'
                              : 'TOKEN EXPIRED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _secondsRemaining > 0 ? AppColors.warning : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _DetailRow(label: 'Loan Account', value: loanNumber),
              const SizedBox(height: 6),
              _DetailRow(label: 'Beneficiary Name', value: widget.loan.beneficiaryName ?? 'Pending Linking'),
              const SizedBox(height: 6),
              _DetailRow(label: 'Scheme', value: widget.loan.schemeName),
              const SizedBox(height: 6),
              _DetailRow(
                label: 'Disbursed Amount',
                value: '₹ ${widget.loan.disbursedAmount.toStringAsFixed(0)}',
                isBold: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_secondsRemaining > 0 && _currentToken != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          if (_currentToken != null) {
                            final messenger = ScaffoldMessenger.of(context);
                            await QrLinkingRemoteDataSource().invalidateToken(_currentToken!.tokenId);
                            if (!mounted) return;
                            setState(() {
                              _secondsRemaining = 0;
                            });
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Token invalidated manually.'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.block_rounded, color: AppColors.danger),
                        label: const Text('Invalidate Token', style: TextStyle(color: AppColors.danger)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.danger),
                        ),
                      ),
                    ),
                  if (_secondsRemaining > 0 && _currentToken != null) const SizedBox(width: 10),
                  if (_secondsRemaining <= 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _generateNewToken,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Refresh Token'),
                      ),
                    ),
                  if (_secondsRemaining <= 0) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _DetailRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
              color: isBold ? AppColors.success : AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _QrPainter extends CustomPainter {
  final String data;

  _QrPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final step = size.width / 11;

    for (int r = 0; r < 11; r++) {
      for (int c = 0; c < 11; c++) {
        if (r >= 4 && r <= 6 && c >= 4 && c <= 6) continue;

        bool isCorner = (r < 3 && c < 3) || (r < 3 && c > 7) || (r > 7 && c < 3);
        if (isCorner) {
          paint.color = AppColors.primary;
          canvas.drawRect(
            Rect.fromLTWH(c * step + 1, r * step + 1, step - 2, step - 2),
            paint,
          );
        } else if ((r + c * 3 + data.hashCode) % 3 == 0) {
          paint.color = Colors.black87;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * step + 1.5, r * step + 1.5, step - 3, step - 3),
              const Radius.circular(2),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
