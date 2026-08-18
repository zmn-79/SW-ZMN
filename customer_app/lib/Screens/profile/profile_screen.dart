import 'package:flutter/material.dart';
import '../../models/user_profile_model.dart';
import '../../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfileModel? profile;
  bool isLoading = true;
  bool isSaving = false;

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    setState(() {
      isLoading = true;
    });

    final data = await UserService.getMyProfile();

    if (!mounted) return;

    setState(() {
      profile = data;
      isLoading = false;

      if (data != null) {
        fullNameController.text = data.fullName;
        phoneController.text = data.phone;
      }
    });
  }

  Future<void> saveChanges() async {
    if (profile == null) return;

    setState(() {
      isSaving = true;
    });

    final updated = profile!.copyWith(
      fullName: fullNameController.text,
      phone: phoneController.text,
    );

    final result = await UserService.updateMyProfile(updated);

    if (!mounted) return;

    setState(() {
      isSaving = false;
      if (result.isSuccess) {
        profile = result.profile;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Profile updated successfully'
              : (result.errorMessage ?? 'Failed to update profile'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : profile == null
              ? const Center(child: Text('Could not load profile'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      profile!.email,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isSaving ? null : saveChanges,
                      child:
                          isSaving
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
    );
  }
}
