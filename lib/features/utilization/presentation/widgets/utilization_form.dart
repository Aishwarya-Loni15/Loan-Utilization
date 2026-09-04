import 'package:flutter/material.dart';

class UtilizationFormWidget extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final Widget evidencePicker;
  final Widget gpsWidget;
  final VoidCallback onSubmit;
  final bool isLoading;

  const UtilizationFormWidget({
    super.key,
    required this.amountController,
    required this.descriptionController,
    required this.evidencePicker,
    required this.gpsWidget,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Spent Amount (₹)',
            hintText: 'e.g. 50000',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Utilization Description',
            hintText: 'Describe items purchased or works executed...',
          ),
        ),
        const SizedBox(height: 20),
        evidencePicker,
        const SizedBox(height: 20),
        gpsWidget,
      ],
    );
  }
}
