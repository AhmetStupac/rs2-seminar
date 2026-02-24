import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:personaltrainer_desktop/models/user.dart';
import 'package:personaltrainer_desktop/providers/user_provider.dart';
import 'package:personaltrainer_desktop/providers/blob_storage_provider.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart'
    as auth_provider;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  final UserProvider _userProvider = UserProvider();
  final BlobStorageProvider _blobStorageProvider = BlobStorageProvider();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;

  // Image upload state
  PlatformFile? _selectedFile;
  Uint8List? _fileBytes;
  int? _uploadedImageId;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
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
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select file.')),
        );
      }
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileBytes = null;
      _uploadedImageId = null;
    });
  }

  Future<void> _uploadImage() async {
    if (_selectedFile == null || _fileBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select an image first')));
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      int? userId = auth_provider.AuthProvider.userId;

      final result = await _blobStorageProvider.uploadFile(
        _fileBytes!,
        _selectedFile!.name,
        userId,
        false, // isHeader
      );

      setState(() {
        _uploadedImageId = result['imageId'];
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image.'),
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

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        User user = User(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          username: _usernameController.text,
          email: _emailController.text,
          phoneNumber: _phoneNumberController.text,
          password: _passwordController.text,
          passwordConfirmation: _passwordConfirmationController.text,
          isActive: true,
          profileImageId: _uploadedImageId, // Include the uploaded image ID
        );

        await _userProvider.insert(user);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Registration successful!')));
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Registration failed. Please try again.')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),

                      // First Name
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          hintText: 'Enter first name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'First name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Last Name
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          hintText: 'Enter last name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Last name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Username
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter username',
                          prefixIcon: Icon(Icons.account_circle),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username is required';
                          }
                          if (value.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Phone Number
                      TextFormField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter phone number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Profile Image Upload Section
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Image (Optional)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),

                            if (_selectedFile == null)
                              ElevatedButton.icon(
                                onPressed: _pickFile,
                                icon: Icon(Icons.upload_file),
                                label: Text('Select Image'),
                              )
                            else
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.image, color: Colors.blue),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedFile!.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: _removeFile,
                                    ),
                                  ],
                                ),
                              ),

                            // Preview
                            if (_fileBytes != null) ...[
                              SizedBox(height: 12),
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _fileBytes!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],

                            // Upload button
                            if (_selectedFile != null &&
                                _uploadedImageId == null) ...[
                              SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _isUploadingImage
                                    ? null
                                    : _uploadImage,
                                icon: _isUploadingImage
                                    ? SizedBox(
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
                                    : Icon(Icons.cloud_upload),
                                label: Text(
                                  _isUploadingImage
                                      ? 'Uploading...'
                                      : 'Upload Image',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ],

                            // Show uploaded image ID
                            if (_uploadedImageId != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Image uploaded (ID: $_uploadedImageId)',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Password Confirmation
                      TextFormField(
                        controller: _passwordConfirmationController,
                        obscureText: _obscurePasswordConfirmation,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Re-enter password',
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePasswordConfirmation
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePasswordConfirmation =
                                    !_obscurePasswordConfirmation;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password confirmation is required';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32),

                      // Register Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Registering...'),
                                ],
                              )
                            : Text('Register', style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(height: 16),

                      // Login Link
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
