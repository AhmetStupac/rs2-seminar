import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';
import 'package:personaltrainer_desktop/models/equipment.dart';
import 'package:personaltrainer_desktop/providers/equipment_provider.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({Key? key}) : super(key: key);

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  final _provider = EquipmentProvider();
  List<Equipment> _items = [];
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
      _showError('Failed to load equipment.');
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

  Future<void> _showFormDialog({Equipment? equipment}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: equipment?.name ?? '');
    final isEdit = equipment != null;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Equipment' : 'Add Equipment'),
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
        final updated = Equipment(id: equipment.id, name: nameController.text.trim());
        await _provider.update(equipment.id!, updated.toJson());
        _showSuccess('Equipment updated successfully.');
      } else {
        final newItem = Equipment(name: nameController.text.trim());
        await _provider.insert(newItem.toJson());
        _showSuccess('Equipment added successfully.');
      }
      _load();
    } catch (e) {
      _showError('An error occurred. Please try again.');
    }
  }

  Future<void> _confirmDelete(Equipment equipment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Equipment'),
        content: Text(
          'Are you sure you want to delete "${equipment.name}"? This action cannot be undone.',
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
      await _provider.delete(equipment.id!);
      _showSuccess('Equipment deleted successfully.');
      _load();
    } catch (e) {
      _showError('Failed to delete equipment.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      'Equipment',
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
                      label: const Text('Add Equipment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
                          'No equipment found.',
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
                                backgroundColor: Colors.blueGrey,
                                child: Icon(Icons.fitness_center, color: Colors.white),
                              ),
                              title: Text(
                                item.name ?? 'Unnamed',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('ID: ${item.id}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    tooltip: 'Edit',
                                    onPressed: () => _showFormDialog(equipment: item),
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
