import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:personaltrainer_mobile/models/gym.dart';
import 'package:personaltrainer_mobile/providers/gym_provider.dart';
import 'package:personaltrainer_mobile/providers/blob_storage_provider.dart';
import 'package:personaltrainer_mobile/layouts/navBar.dart';

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

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  int? _uploadedImageId;
  bool isLoading = false;
  String? errorMessage;

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
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImageBytes = result.files.first.bytes;
          _selectedImageName = result.files.first.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri odabiru slike: $e')),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImageBytes == null || _selectedImageName == null) {
      return;
    }

    try {
      final result = await _blobStorageProvider.uploadFile(
        _selectedImageBytes!,
        _selectedImageName!,
        null,
        false,
      );

      setState(() {
        _uploadedImageId = result['imageId'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Slika uspješno uploadovana')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri uploadu slike: $e')),
      );
    }
  }

  Future<void> _saveGym() async {
    if (nameController.text.isEmpty) {
      setState(() {
        errorMessage = 'Naziv teretane je obavezan';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Upload image if selected
      if (_selectedImageBytes != null && _selectedImageName != null) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teretana uspješno dodana')),
        );
      } else {
        await _gymProvider.update(gym.id!, gym);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teretana uspješno ažurirana')),
        );
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        errorMessage = 'Greška pri spremanju: $e';
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
      'Teretane',
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
                    widget.gym == null
                        ? 'Dodaj teretanu'
                        : 'Uredi teretanu',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),
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
                              'Naziv teretane',
                              nameController,
                              'Arena Sport Centar',
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              'Adresa',
                              addressController,
                              'Brace Kaljica',
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              'Grad',
                              cityController,
                              'Mostar',
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              'Država',
                              countryController,
                              'Bosna i Hercegovina',
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              'Email',
                              emailController,
                              'info@arenasport.ba',
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              'Telefon',
                              phoneNumberController,
                              '+387 36 123 456',
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              'Radno vrijeme',
                              workTimeController,
                              '07:00 - 23:00',
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
                              'Slika',
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
                          'Otkaži',
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
                            : const Text('Spremi'),
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
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          if (_selectedImageBytes != null)
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                image: DecorationImage(
                  image: MemoryImage(_selectedImageBytes!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Nema odabrane slike',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload),
                label: const Text('Odaberi sliku'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
