import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth_service.dart';
import '../login_page.dart';
import '../widgets/translated_text.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _deleteConfirmController =
      TextEditingController();
  final TextEditingController _deletePasswordController =
      TextEditingController();

  bool _isUpdatingEmail = false;
  bool _isUpdatingPassword = false;
  bool _isDeleting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newEmailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _deleteConfirmController.dispose();
    _deletePasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newEmail = _newEmailController.text.trim();

    if (newEmail.isEmpty || currentPassword.isEmpty) {
      _showSnackBar('Enter your current password and the new email.');
      return;
    }

    setState(() {
      _isUpdatingEmail = true;
    });

    try {
      await _authService.updateEmailAddress(
        currentPassword: currentPassword,
        newEmail: newEmail,
      );
      if (!mounted) return;

      _showSnackBar('Email updated successfully.');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showSnackBar('Could not update email: ${error.code}');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Could not update email: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingEmail = false;
        });
      }
    }
  }

  Future<void> _updatePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      _showSnackBar('Enter your current password and a new password.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('New password and confirmation do not match.');
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar('New password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isUpdatingPassword = true;
    });

    try {
      await _authService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (!mounted) return;

      _showSnackBar('Password updated successfully.');
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showSnackBar('Could not update password: ${error.code}');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Could not update password: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPassword = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const TranslatedText('Delete account?'),
          content: const TranslatedText(
            'This will permanently delete your account, profile, and progress.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const TranslatedText('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const TranslatedText('Continue'),
            ),
          ],
        );
      },
    );

    if (!mounted || proceed != true) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const TranslatedText('Confirm deletion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TranslatedText(
                'Type DELETE and enter your current password to continue.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _deleteConfirmController,
                decoration: const InputDecoration(
                  labelText: 'Type DELETE',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _deletePasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const TranslatedText('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final typed = _deleteConfirmController.text.trim();
                if (typed == 'DELETE') {
                  Navigator.of(context).pop(true);
                }
              },
              child: const TranslatedText('Delete permanently'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    final currentPassword = _deletePasswordController.text.trim();
    if (currentPassword.isEmpty) {
      _showSnackBar('Enter your current password to delete the account.');
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await _authService.deleteAccount(currentPassword: currentPassword);
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showSnackBar('Could not delete account: ${error.code}');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Could not delete account: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Unknown email';

    return Scaffold(
      appBar: AppBar(title: const TranslatedText('Account Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TranslatedText(
                      'Update email address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TranslatedText('Current email: $email'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        label: TranslatedText('New email address'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        label: TranslatedText('Current password'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUpdatingEmail ? null : _updateEmail,
                        child: TranslatedText(
                          _isUpdatingEmail ? 'Updating...' : 'Update email',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TranslatedText(
                      'Update password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        label: TranslatedText('New password'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        label: TranslatedText('Confirm new password'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUpdatingPassword ? null : _updatePassword,
                        child: TranslatedText(
                          _isUpdatingPassword
                              ? 'Updating...'
                              : 'Update password',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.red.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TranslatedText(
                      'Delete account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const TranslatedText(
                      'This action is permanent and cannot be undone.',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isDeleting ? null : _confirmDeleteAccount,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 2),
                          foregroundColor: Colors.red,
                        ),
                        child: TranslatedText(
                          _isDeleting ? 'Deleting...' : 'Delete account',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
