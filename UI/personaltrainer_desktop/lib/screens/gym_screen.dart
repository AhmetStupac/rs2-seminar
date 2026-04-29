import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:personaltrainer_desktop/models/gym.dart';
import 'package:personaltrainer_desktop/providers/gym_provider.dart';
import 'package:personaltrainer_desktop/providers/blob_storage_provider.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/widgets/network_image_loader.dart';

class GymScreen extends StatefulWidget {
  final Gym? gym;

  const GymScreen({Key? key, this.gym}) : super(key: key);

  @override
  _GymScreenState createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController workTimeController = TextEditingController();

  late GymProvider _gymProvider;
  late BlobStorageProvider _blobStorageProvider;

  PlatformFile? _selectedFile;
  Uint8List? _fileBytes;
  int? _uploadedImageId;
  String? _existingImageUrl;
  bool isLoading = false;
  bool _isUploading = false;
  String? errorMessage;
  String? _nameError;
  String? _addressError;
  String? _cityError;
  String? _countryError;
  String? _emailError;
  String? _phoneError;
  String? _workTimeError;
  String? _imageError;

  @override
  void initState() {
    super.initState();
    _gymProvider = GymProvider();
    _blobStorageProvider = BlobStorageProvider();

    if (widget.gym != null) {
      nameController.text = widget.gym!.name ?? '';
      addressController.text = widget.gym!.address ?? '';
      cityController.text = widget.gym!.city ?? '';
      countryController.text = widget.gym!.country ?? '';
      emailController.text = widget.gym!.email ?? '';
      phoneNumberController.text = widget.gym!.phoneNumber ?? '';
      workTimeController.text = widget.gym!.workTime ?? '';
      _uploadedImageId = widget.gym!.imageId;
      _existingImageUrl = widget.gym!.imageUrl;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    cityController.dispose();
    countryController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    workTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
          _imageError = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileBytes = null;
      _imageError = null;
    });
  }

  Future<void> _uploadImage() async {
    if (_selectedFile == null || _fileBytes == null) {
      setState(() {
        _imageError = 'Please select an image first';
      });
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final result = await _blobStorageProvider.uploadFile(
        _fileBytes!,
        _selectedFile!.name,
        false,
      );

      setState(() {
        _uploadedImageId = result['imageId'];
        _isUploading = false;
        _imageError = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Image uploaded successfully (ID: ${result['imageId']})',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    }
  }

  Future<void> _saveGym() async {
    String? nameError;
    String? addressError;
    String? cityError;
    String? countryError;
    String? emailError;
    String? phoneError;
    String? workTimeError;

    if (nameController.text.trim().isEmpty) {
      nameError = 'Gym name cannot be empty.';
    }
    if (addressController.text.trim().isEmpty) {
      addressError = 'Address cannot be empty.';
    }
    if (cityController.text.trim().isEmpty) {
      cityError = 'City cannot be empty.';
    }
    if (countryController.text.trim().isEmpty) {
      countryError = 'Country cannot be empty.';
    }
    if (emailController.text.trim().isEmpty) {
      emailError = 'Email cannot be empty.';
    }
    if (phoneNumberController.text.trim().isEmpty) {
      phoneError = 'Phone number cannot be empty.';
    }
    if (workTimeController.text.trim().isEmpty) {
      workTimeError = 'Work time cannot be empty.';
    }

    final phoneRaw = phoneNumberController.text.trim();
    final phoneRegex = RegExp(r'^\+387 6[0-9] [0-9]{3} [0-9]{3}$');
    if (phoneError == null && !phoneRegex.hasMatch(phoneRaw)) {
      phoneError =
          'Phone must be in format +387 6x xxx xxx (e.g. +387 61 234 567).';
    }

    final emailRaw = emailController.text.trim();
    final emailComRegex = RegExp(
      r'^[a-zA-Z0-9]+\.[a-zA-Z0-9]+@[a-zA-Z0-9]+\.com$',
    );
    final emailEduRegex = RegExp(r'^[a-zA-Z0-9]+\.[a-zA-Z0-9]+@edu\.fit\.ba$');
    if (emailError == null &&
        !emailComRegex.hasMatch(emailRaw) &&
        !emailEduRegex.hasMatch(emailRaw)) {
      emailError =
          'Email must be in format firstname.lastname@domain.com or firstname.lastname@edu.fit.ba';
    }

    setState(() {
      _nameError = nameError;
      _addressError = addressError;
      _cityError = cityError;
      _countryError = countryError;
      _emailError = emailError;
      _phoneError = phoneError;
      _workTimeError = workTimeError;
      errorMessage = null;
    });

    if (nameError != null ||
        addressError != null ||
        cityError != null ||
        countryError != null ||
        emailError != null ||
        phoneError != null ||
        workTimeError != null) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Upload image if selected but not yet uploaded
      if (_selectedFile != null &&
          _fileBytes != null &&
          _uploadedImageId == null) {
        await _uploadImage();
      }

      final gym = Gym(
        id: widget.gym?.id,
        name: nameController.text,
        address: addressController.text,
        city: cityController.text,
        country: countryController.text,
        email: emailController.text,
        phoneNumber: phoneNumberController.text,
        workTime: workTimeController.text,
        imageId: _uploadedImageId,
      );

      if (widget.gym == null) {
        await _gymProvider.insert(gym);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gym added successfully')));
      } else {
        await _gymProvider.update(gym.id!, gym);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gym updated successfully')),
        );
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        errorMessage = 'Please check all fields and try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      'Gyms',
      Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.gym == null ? 'Add Gym' : 'Edit Gym',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column - form fields
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              'Gym Name',
                              nameController,
                              'Arena Sport Centar',
                              errorText: _nameError,
                              onChanged: (_) {
                                if (_nameError != null) {
                                  setState(() => _nameError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              'Address',
                              addressController,
                              'Brace Kaljica',
                              errorText: _addressError,
                              onChanged: (_) {
                                if (_addressError != null) {
                                  setState(() => _addressError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              'City',
                              cityController,
                              'Mostar',
                              errorText: _cityError,
                              onChanged: (_) {
                                if (_cityError != null) {
                                  setState(() => _cityError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              'Country',
                              countryController,
                              'Bosna i Hercegovina',
                              errorText: _countryError,
                              onChanged: (_) {
                                if (_countryError != null) {
                                  setState(() => _countryError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              'Email',
                              emailController,
                              'info@arenasport.ba',
                              errorText: _emailError,
                              onChanged: (_) {
                                if (_emailError != null) {
                                  setState(() => _emailError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              'Phone',
                              phoneNumberController,
                              '+387 36 123 456',
                              errorText: _phoneError,
                              onChanged: (_) {
                                if (_phoneError != null) {
                                  setState(() => _phoneError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              'Working Hours',
                              workTimeController,
                              '07:00 - 23:00',
                              errorText: _workTimeError,
                              onChanged: (_) {
                                if (_workTimeError != null) {
                                  setState(() => _workTimeError = null);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Right column - image upload
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Image',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildImageUpload(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[700],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red[800]),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: isLoading ? null : _saveGym,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            errorText: errorText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.purple, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File selection button or file info
          if (_selectedFile == null)
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey[300]!),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.image, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFile!.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
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
                    onPressed: _removeFile,
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: 'Remove Image',
                  ),
                ],
              ),
            ),

          if (_imageError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _imageError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),

          // Image preview
          if (_fileBytes != null) ...[
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(_fileBytes!, fit: BoxFit.contain),
              ),
            ),
          ] else if (_existingImageUrl != null &&
              _existingImageUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: NetworkImageLoader(
                  imageUrl: _existingImageUrl!,
                  height: 200,
                  fit: BoxFit.contain,
                  errorWidget: Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading image',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Upload button (separate from save)
          if (_selectedFile != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadImage,
              icon: _isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_isUploading ? 'Uploading...' : 'Upload Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],

          // Upload success indicator
          if (_uploadedImageId != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Image uploaded (ID: $_uploadedImageId)',
                    style: TextStyle(color: Colors.green[700], fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
