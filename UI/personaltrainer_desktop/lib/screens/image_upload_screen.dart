import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:personaltrainer_mobile/layouts/navBar.dart';
import 'package:personaltrainer_mobile/models/image.dart' as img_model;
import 'package:personaltrainer_mobile/models/exercise.dart';
import 'package:personaltrainer_mobile/models/muscleGroup.dart';
import 'package:personaltrainer_mobile/models/equipment.dart';
import 'package:personaltrainer_mobile/providers/image_provider.dart'
    as img_provider;
import 'package:personaltrainer_mobile/providers/auth_provider.dart'
    as auth_provider;
import 'package:personaltrainer_mobile/providers/muscle_group_provider.dart';
import 'package:personaltrainer_mobile/providers/equipment_provider.dart';

class ImageUploadScreen extends StatefulWidget {
  final int? trainingId;

  ImageUploadScreen({Key? key, this.trainingId}) : super(key: key);

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _exerciseNameController;
  late img_provider.ImageProvider _imageProvider;
  bool _isHeader = false;

  int? _selectedMuscleGroupId;
  int? _selectedEquipmentId;
  List<MuscleGroup> _muscleGroups = [];
  List<Equipment> _equipments = [];
  bool _isLoadingDropdowns = true;

  PlatformFile? _selectedFile;
  Uint8List? _fileBytes;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _imageProvider = img_provider.ImageProvider();
    _nameController = TextEditingController();
    _exerciseNameController = TextEditingController();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final mgProvider = MuscleGroupProvider();
    final eqProvider = EquipmentProvider();
    final mgResult = await mgProvider.get();
    final eqResult = await eqProvider.get();
    setState(() {
      _muscleGroups = mgResult.result;
      _equipments = eqResult.result;
      _isLoadingDropdowns = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          SnackBar(content: Text('Greška pri izboru fajla: ${e.toString()}')),
        );
      }
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileBytes = null;
    });
  }

  Future<void> _sendToApi() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedFile == null || _fileBytes == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Molimo odaberite fajl')));
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        int? userId = auth_provider.AuthProvider.userId;

        // Kreiraj Exercise entitet
        Exercise exercise = Exercise(
          name: _exerciseNameController.text,
          muscleGroupId: _selectedMuscleGroupId,
          equipmentId: _selectedEquipmentId,
        );

        // Upload slike
        final image = await _imageProvider.uploadFile(
          _fileBytes!,
          _selectedFile!.name,
          _nameController.text,
          userId,
          _isHeader,
        );

        // Ovdje možeš dodati logiku za vezu slike i exercise entiteta ako backend to podržava

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Slika i vježba uspješno poslati!')),
          );
          Navigator.of(context).pop(image);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Greška: ${e.toString()}')));
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
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Naziv slike',
                        hintText: 'Unesite naziv slike',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Unesite naziv'
                          : null,
                    ),
                    SizedBox(height: 12),

                    TextFormField(
                      controller: _exerciseNameController,
                      decoration: InputDecoration(
                        labelText: 'Ime vježbe',
                        hintText: 'Unesite ime vježbe',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Unesite ime vježbe'
                          : null,
                    ),
                    SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      value: _selectedMuscleGroupId,
                      decoration: InputDecoration(labelText: "Muscle Group"),
                      items: _muscleGroups
                          .map(
                            (mg) => DropdownMenuItem<int>(
                              value: mg.id,
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
                          val == null ? 'Odaberite muscle group' : null,
                    ),
                    SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      value: _selectedEquipmentId,
                      decoration: InputDecoration(labelText: "Equipment"),
                      items: _equipments
                          .map(
                            (eq) => DropdownMenuItem<int>(
                              value: eq.id,
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
                          val == null ? 'Odaberite equipment' : null,
                    ),
                    SizedBox(height: 12),

                    CheckboxListTile(
                      value: _isHeader,
                      onChanged: (val) {
                        setState(() {
                          _isHeader = val ?? false;
                        });
                      },
                      title: Text('isHeader'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),

                    SizedBox(height: 12),

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
                              label: Text('Odaberi fajl'),
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
                                    tooltip: 'Ukloni fajl',
                                  ),
                                ],
                              ),
                            ),

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
                        ],
                      ),
                    ),

                    SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isUploading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text('Otkaži'),
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
                                    Text('Šaljem...'),
                                  ],
                                )
                              : Text('Pošalji'),
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
