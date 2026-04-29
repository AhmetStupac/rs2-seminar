import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/models/exercise.dart';
import 'package:personaltrainer_desktop/models/muscleGroup.dart';
import 'package:personaltrainer_desktop/models/equipment.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart'
    as auth_provider;
import 'package:personaltrainer_desktop/providers/blob_storage_provider.dart';
import 'package:personaltrainer_desktop/providers/muscle_group_provider.dart';
import 'package:personaltrainer_desktop/providers/equipment_provider.dart';
import 'package:personaltrainer_desktop/providers/exerciseProvider.dart';

class ImageUploadScreen extends StatefulWidget {
  final int? trainingId;

  const ImageUploadScreen({super.key, this.trainingId});

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  int? _uploadedImageId;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _exerciseNameController;
  late BlobStorageProvider _blobStorageProvider;
  late ExerciseProvider _exerciseProvider;
  bool _isHeader = false;

  int? _selectedMuscleGroupId;
  int? _selectedEquipmentId;
  List<MuscleGroup> _muscleGroups = [];
  List<Equipment> _equipments = [];
  bool _isLoadingDropdowns = true;

  PlatformFile? _selectedFile;
  Uint8List? _fileBytes;
  bool _isUploading = false;
  String? _fileValidationError;

  @override
  void initState() {
    super.initState();
    _blobStorageProvider = BlobStorageProvider();
    _exerciseProvider = ExerciseProvider();
    _exerciseNameController = TextEditingController();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final mgProvider = MuscleGroupProvider();
    final eqProvider = EquipmentProvider();
    final mgResult = await mgProvider.get();
    final eqResult = await eqProvider.get();


    if (eqResult.result.isNotEmpty) {
      for (var eq in eqResult.result) {
      }
    }

    setState(() {
      _muscleGroups = mgResult.result;
      _equipments = eqResult.result;
      _isLoadingDropdowns = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _uploadImageOnly() async {
    if (_selectedFile == null || _fileBytes == null) {
      setState(() {
        _fileValidationError = 'Please select a file';
      });
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // uploadFile sada vraÄ‡a Map<String, dynamic> umjesto Image objekta
      final result = await _blobStorageProvider.uploadFile(
        _fileBytes!,
        _selectedFile!.name,
        _isHeader,
      );

      setState(() {
        _uploadedImageId = result['imageId']; // Uzmi imageId iz mape
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image uploaded successfully! (ID: ${result['imageId']})',
          ),
        ),
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $errorMessage')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
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
          _fileValidationError = null;
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
      _fileValidationError = null;
    });
  }

  Future<void> _sendToApi() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedFile == null || _fileBytes == null) {
        setState(() {
          _fileValidationError = 'Please select a file';
        });
        return;
      }

      // Prikazi dialog za potvrdu nepovratne akcije
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Submission'),
          content: Text('Are you sure you want to send this data?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Submit'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      setState(() {
        _isUploading = true;
      });

      try {
        // PRVI HTTP REQUEST - Upload slike
        final imageResult = await _blobStorageProvider.uploadFile(
          _fileBytes!,
          _selectedFile!.name,
          _isHeader,
        );

        // Uzmi imageId iz rezultata prvog HTTP requesta
        int? imageId = imageResult['imageId'];

        // Kreiraj Exercise entitet sa imageId
        Exercise exercise = Exercise(
          name: _exerciseNameController.text,
          muscleGroupId: _selectedMuscleGroupId,
          equipmentId: _selectedEquipmentId,
          imageId: imageId, // Pohrani imageId u exercise objekat
        );

        // DRUGI HTTP REQUEST - Kreiraj exercise na API-ju
        await _exerciseProvider.insert(exercise);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image uploaded (ID: $imageId) and exercise created successfully!',
              ),
            ),
          );
          Navigator.of(context).pop(exercise);
        }
      } catch (e) {
        if (mounted) {
          final errorMessage = e.toString().replaceFirst('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create exercise: $errorMessage')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      'Upload slike',
      _isLoadingDropdowns
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // isHeader checkbox section
                    CheckboxListTile(
                      value: _isHeader,
                      onChanged: (val) {
                        setState(() {
                          _isHeader = val ?? false;
                        });
                      },
                      title: Text('Is the picture a header?'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),

                    SizedBox(height: 24),

                    // File picker section
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
                            'Fajl',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),

                          if (_selectedFile == null)
                            ElevatedButton.icon(
                              onPressed: _pickFile,
                              icon: Icon(Icons.upload_file),
                              label: Text('Select file'),
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
                                            fontWeight: FontWeight.w500,
                                          ),
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
                                    icon: Icon(Icons.close, color: Colors.red),
                                    tooltip: 'Remove file',
                                  ),
                                ],
                              ),
                            ),

                          if (_fileValidationError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _fileValidationError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ],

                          // Preview slike
                          if (_fileBytes != null) ...[
                            SizedBox(height: 16),
                            Container(
                              height: 200,
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
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _isUploading ? null : _uploadImageOnly,
                            icon: Icon(Icons.cloud_upload),
                            label: Text('Upload image'),
                          ),
                          if (_uploadedImageId != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Image ID: $_uploadedImageId',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    TextFormField(
                      controller: _exerciseNameController,
                      decoration: InputDecoration(
                        labelText: 'Exercise Name',
                        hintText: 'Enter exercise name',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter an exercise name'
                          : null,
                    ),
                    SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      initialValue:
                          _muscleGroups.any(
                            (mg) =>
                                mg.id != null &&
                                mg.id == _selectedMuscleGroupId,
                          )
                          ? _selectedMuscleGroupId
                          : null,
                      decoration: InputDecoration(labelText: "Muscle Group"),
                      items: _muscleGroups
                          .where((mg) => mg.id != null)
                          .map(
                            (mg) => DropdownMenuItem<int>(
                              value: mg.id!,
                              child: Text(mg.name ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedMuscleGroupId = val;
                        });
                      },
                      validator: (val) =>
                          val == null ? 'Please select a muscle group' : null,
                    ),
                    SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      initialValue:
                          _equipments.any(
                            (eq) =>
                                eq.id != null && eq.id == _selectedEquipmentId,
                          )
                          ? _selectedEquipmentId
                          : null,
                      decoration: InputDecoration(labelText: "Equipment"),
                      items: _equipments
                          .where((eq) => eq.id != null)
                          .map(
                            (eq) => DropdownMenuItem<int>(
                              value: eq.id!,
                              child: Text(eq.name ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedEquipmentId = val;
                        });
                      },
                      validator: (val) =>
                          val == null ? 'Please select equipment' : null,
                    ),

                    SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isUploading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text('Cancel'),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isUploading ? null : _sendToApi,
                          child: _isUploading
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Sending...'),
                                  ],
                                )
                              : Text('Send'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

