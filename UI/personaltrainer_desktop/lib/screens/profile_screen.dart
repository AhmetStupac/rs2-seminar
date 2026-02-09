import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/models/user.dart';
import 'package:personaltrainer_mobile/providers/user_provider.dart';
import 'package:personaltrainer_mobile/layouts/navBar.dart';
import 'package:personaltrainer_mobile/screens/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final provider = UserProvider();
    final user = await provider.getCurrentUser();
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _showResetPasswordDialog() async {
    if (_user?.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('A password reset link will be sent to:'),
            const SizedBox(height: 8),
            Text(
              _user!.email!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Click the link in the email to reset your password.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send Email'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _sendResetEmail();
    }
  }

  Future<void> _sendResetEmail() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final provider = UserProvider();
      final success = await provider.forgotPassword(_user!.email!);

      // Dismiss loading indicator
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent! Check your inbox.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to send reset email. Please check the console for details.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      // Dismiss loading indicator
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _showPasteResetLinkDialog() async {
    final TextEditingController tokenController = TextEditingController();

    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paste Reset Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste the password reset link from your email here:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tokenController,
              decoration: const InputDecoration(
                hintText: 'personaltrainerapp://reset-password?token=...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            const Text(
              'You can paste the full URL, scheme URL, or just the token.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final input = tokenController.text.trim();
              if (input.isNotEmpty) {
                Navigator.pop(context, input);
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      String? token;

      // Try parsing as URI first
      final uri = Uri.tryParse(result);
      if (uri != null && uri.queryParameters.containsKey('token')) {
        token = uri.queryParameters['token'];
      } else {
        // Try extracting token with regex
        final regex = RegExp(r'token=([^&\s]+)');
        final match = regex.firstMatch(result);
        if (match != null) {
          token = match.group(1);
        } else {
          // Assume the entire input is the token
          token = result;
        }
      }

      if (token != null && token.isNotEmpty && mounted) {
        // Validate token format (JWT tokens have 3 parts separated by dots)
        if (!_isValidTokenFormat(token)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid token format. Please check the reset link and try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangePasswordScreen(resetToken: token),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not extract token from the provided input.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isValidTokenFormat(String token) {
    // JWT tokens have 3 parts separated by dots: header.payload.signature
    final parts = token.split('.');
    if (parts.length != 3) {
      return false;
    }

    // Each part should be non-empty and contain valid base64url characters
    final base64UrlPattern = RegExp(r'^[A-Za-z0-9_-]+$');
    for (final part in parts) {
      if (part.isEmpty || !base64UrlPattern.hasMatch(part)) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      'Profile',
      _loading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? const Center(child: Text('Error loading profile.'))
          : Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: TextEditingController(
                              text:
                                  (_user!.firstName ?? '') +
                                  ' ' +
                                  (_user!.lastName ?? ''),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                                letterSpacing: 0.5,
                                height: 1.2,
                              ),
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                            ),
                            textAlign: TextAlign.center,
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: TextEditingController(
                              text: _user!.email ?? '',
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                                letterSpacing: 0.5,
                                height: 1.2,
                              ),
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                            ),
                            textAlign: TextAlign.center,
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: TextEditingController(
                              text: _user!.phoneNumber ?? '',
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                                letterSpacing: 0.5,
                                height: 1.2,
                              ),
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                            ),
                            textAlign: TextAlign.center,
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: TextEditingController(
                              text: _user!.username ?? '',
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                                letterSpacing: 0.5,
                                height: 1.2,
                              ),
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                            ),
                            textAlign: TextAlign.center,
                            readOnly: true,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _showResetPasswordDialog,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Send Reset Email',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _showPasteResetLinkDialog,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Paste Reset Link',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
