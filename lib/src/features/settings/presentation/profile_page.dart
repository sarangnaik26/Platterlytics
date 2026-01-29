import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/domain/profile_model.dart';
import '../../profile/presentation/profile_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ownerNameController;
  late TextEditingController _businessNameController;
  late TextEditingController _contactInfoController;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _ownerNameController = TextEditingController();
    _businessNameController = TextEditingController();
    _contactInfoController = TextEditingController();
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _businessNameController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  void _loadProfile(UserProfile profile) {
    if (!_isInit) {
      _ownerNameController.text = profile.ownerName;
      _businessNameController.text = profile.businessName;
      _contactInfoController.text = profile.contactInfo;
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: profileAsync.when(
        data: (profile) {
          _loadProfile(profile);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _ownerNameController,
                  decoration: const InputDecoration(
                    labelText: "Owner Name",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter owner name'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _businessNameController,
                  decoration: const InputDecoration(
                    labelText: "Business Name",
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactInfoController,
                  decoration: const InputDecoration(
                    labelText: "Contact Info",
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newProfile = UserProfile(
                        ownerName: _ownerNameController.text,
                        businessName: _businessNameController.text,
                        contactInfo: _contactInfoController.text,
                      );
                      ref
                          .read(profileControllerProvider.notifier)
                          .updateProfile(newProfile);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Profile Saved")),
                      );
                    }
                  },
                  child: const Text("Save Profile"),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
