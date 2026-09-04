import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/providers/auth_provider.dart';

class BeneficiaryProfilePage extends ConsumerWidget {
  const BeneficiaryProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Beneficiary User',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Personal & Location Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text('Phone Number'),
                subtitle: Text(user?.phone ?? 'Not set'),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Address'),
                subtitle: Text(user?.address ?? 'Not set'),
              ),
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('State & District'),
                subtitle: Text('${user?.state}, ${user?.district}'),
              ),
              ListTile(
                leading: const Icon(Icons.location_city_outlined),
                title: const Text('Taluka & Village'),
                subtitle: Text('${user?.taluka}, ${user?.village}'),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Sign Out',
                isOutlined: true,
                onPressed: () => ref.read(currentUserProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
