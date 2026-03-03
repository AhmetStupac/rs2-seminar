import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/models/muscleGroup.dart';
import 'package:personaltrainer_desktop/providers/muscle_group_provider.dart';

class MuscleGroupScreen extends StatefulWidget {
  const MuscleGroupScreen({Key? key}) : super(key: key);

  @override
  State<MuscleGroupScreen> createState() => _MuscleGroupScreenState();
}

class _MuscleGroupScreenState extends State<MuscleGroupScreen> {
  final _provider = MuscleGroupProvider();
  List<MuscleGroup> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final result = await _provider.get();
      setState(() {
        _items = result.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load muscle groups.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _showFormDialog({MuscleGroup? muscleGroup}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: muscleGroup?.name ?? '');
    final isEdit = muscleGroup != null;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Muscle Group' : 'Add Muscle Group'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Name cannot be empty' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, true);
              }
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (isEdit) {
        final updated = MuscleGroup(id: muscleGroup.id, name: nameController.text.trim());
        await _provider.update(muscleGroup.id!, updated.toJson());
        _showSuccess('Muscle group updated successfully.');
      } else {
        final newItem = MuscleGroup(name: nameController.text.trim());
        await _provider.insert(newItem.toJson());
        _showSuccess('Muscle group added successfully.');
      }
      _load();
    } catch (e) {
      _showError('An error occurred. Please try again.');
    }
  }

  Future<void> _confirmDelete(MuscleGroup muscleGroup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Muscle Group'),
        content: Text(
          'Are you sure you want to delete "${muscleGroup.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _provider.delete(muscleGroup.id!);
      _showSuccess('Muscle group deleted successfully.');
      _load();
    } catch (e) {
      _showError('Failed to delete muscle group.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      'Muscle Groups',
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_items.length} item${_items.length != 1 ? 's' : ''}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                      onPressed: _load,
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showFormDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Muscle Group'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(
                        child: Text(
                          'No muscle groups found.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.purple,
                                child: Icon(Icons.accessibility_new, color: Colors.white),
                              ),
                              title: Text(
                                item.name ?? 'Unnamed',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    tooltip: 'Edit',
                                    onPressed: () => _showFormDialog(muscleGroup: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Delete',
                                    onPressed: () => _confirmDelete(item),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
