import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:personaltrainer_desktop/models/user.dart';
import 'package:personaltrainer_desktop/providers/user_provider.dart';
import 'package:personaltrainer_desktop/providers/blob_storage_provider.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart'
    as auth_provider;
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/screens/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _loading = true;
  bool _saving = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();

  final BlobStorageProvider _blobStorageProvider = BlobStorageProvider();

  // Image upload state
  PlatformFile? _selectedFile;
  Uint8List? _fileBytes;
  Uint8List? _existingImageBytes; // For displaying existing profile image
  int? _uploadedImageId;
  bool _isUploadingImage = false;
  bool _newImageUploaded =
      false; // Track if a new image was uploaded this session

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final provider = UserProvider();
    final user = await provider.getCurrentUser();

    // Download existing profile image if available
    Uint8List? existingImage;
    if (user?.profileImage?.url != null &&
        user!.profileImage!.url!.isNotEmpty) {
      try {
        existingImage = await _blobStorageProvider.downloadImageBytes(
          user.profileImage!.url!,
        );
      } catch (e) {
      }
    }

    setState(() {
      _user = user;
      _loading = false;
      _existingImageBytes = existingImage;

      // Populate controllers
      if (user != null) {
        _firstNameController.text = user.firstName ?? '';
        _lastNameController.text = user.lastName ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phoneNumber ?? '';
        _usernameController.text = user.username ?? '';
        _uploadedImageId = user.profileImageId;
      }
    });
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _fileBytes = result.files.first.bytes;
          _newImageUploaded = false; // Reset flag when new file is picked
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to select file.')));
      }
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileBytes = null;
      _newImageUploaded = false;
    });
  }

  Future<void> _uploadImage() async {
    if (_selectedFile == null || _fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final result = await _blobStorageProvider.uploadFile(
        _fileBytes!,
        _selectedFile!.name,
        false, // isHeader
      );

      setState(() {
        _uploadedImageId = result['imageId'];
        _newImageUploaded = true; // Mark that a new image was uploaded
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Image uploaded successfully! (ID: ${result['imageId']})',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  String? _validate() {
    if (_firstNameController.text.trim().isEmpty)
      return 'First name cannot be empty.';
    if (_lastNameController.text.trim().isEmpty)
      return 'Last name cannot be empty.';
    if (_emailController.text.trim().isEmpty) return 'Email cannot be empty.';
    final emailComRegex = RegExp(
      r'^[a-zA-Z0-9]+\.[a-zA-Z0-9]+@[a-zA-Z0-9]+\.com$',
    );
    final emailEduRegex = RegExp(r'^[a-zA-Z0-9]+\.[a-zA-Z0-9]+@edu\.fit\.ba$');
    final email = _emailController.text.trim();
    if (!emailComRegex.hasMatch(email) && !emailEduRegex.hasMatch(email))
      return 'Email must be in format firstname.lastname@domain.com or firstname.lastname@edu.fit.ba';
    if (_phoneController.text.trim().isEmpty)
      return 'Phone number cannot be empty.';
    final phoneRegex = RegExp(r'^\+387 6[0-9] [0-9]{3} [0-9]{3}$');
    if (!phoneRegex.hasMatch(_phoneController.text.trim()))
      return 'Phone must be in format +387 6x xxx xxx (e.g. +387 61 234 567).';
    if (_usernameController.text.trim().isEmpty)
      return 'Username cannot be empty.';
    return null;
  }

  Future<void> _saveChanges() async {
    if (_user == null) return;

    final validationError = _validate();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(validationError),
            ],
          ),
          backgroundColor: Colors.orange[700],
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final provider = UserProvider();
      final success = await provider.updateUser(
        _user!.id!,
        _firstNameController.text,
        _lastNameController.text,
        _emailController.text,
        _usernameController.text,
        _phoneController.text,
        _uploadedImageId, // Include profileImageId
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          // Reload user data
          setState(() {
            _newImageUploaded = false; // Reset flag after successful save
            _selectedFile = null;
            _fileBytes = null;
          });
          await _loadUser();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
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
              content: Text('Verification code sent! Check your email.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Navigate to change password screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangePasswordScreen(email: _user!.email),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send reset email. Please try again.'),
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
            content: Text('Failed to send reset email. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
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
                          // Profile Picture
                          GestureDetector(
                            onTap: _pickFile,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 3,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: _fileBytes != null
                                        ? Image.memory(
                                            _fileBytes!,
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 120,
                                          )
                                        : _existingImageBytes != null
                                        ? Image.memory(
                                            _existingImageBytes!,
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 120,
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey[400],
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Upload button and status
                          if (_selectedFile != null && !_newImageUploaded)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ElevatedButton.icon(
                                onPressed: _isUploadingImage
                                    ? null
                                    : _uploadImage,
                                icon: _isUploadingImage
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Icon(Icons.cloud_upload, size: 18),
                                label: Text(
                                  _isUploadingImage
                                      ? 'Uploading...'
                                      : 'Upload Photo',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),

                          if (_newImageUploaded)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Profile photo uploaded',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),

                          TextField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
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
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
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
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText:
                                  'e.g. john.doe@gmail.com or john.doe@edu.fit.ba',
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
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              hintText: '+387 6x xxx xxx',
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
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _usernameController,
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
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _saveChanges,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _showResetPasswordDialog,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Reset Password',
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

