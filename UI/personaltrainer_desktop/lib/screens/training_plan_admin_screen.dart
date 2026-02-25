import 'package:flutter/material.dart';
import 'package:personaltrainer_mobile/layouts/navBar.dart';
import 'package:personaltrainer_mobile/models/personal_trainer.dart';
import 'package:personaltrainer_mobile/models/training_plan.dart';
import 'package:personaltrainer_mobile/providers/admin_provider.dart';
import 'package:personaltrainer_mobile/providers/personal_trainer_provider.dart';
import 'package:personaltrainer_mobile/providers/training_plan_provider.dart';

// ─── Main list screen ───────────────────────────────────────────────────────

class TrainingPlanAdminScreen extends StatefulWidget {
  const TrainingPlanAdminScreen({Key? key}) : super(key: key);

  @override
  State<TrainingPlanAdminScreen> createState() =>
      _TrainingPlanAdminScreenState();
}

class _TrainingPlanAdminScreenState extends State<TrainingPlanAdminScreen> {
  final _provider = TrainingPlanProvider();
  List<TrainingPlan> _plans = [];
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
        _plans = result.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load training plans.');
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

  Future<void> _openForm({TrainingPlan? plan}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _TrainingPlanFormScreen(plan: plan),
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _confirmDelete(TrainingPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Training Plan'),
        content: Text(
          'Are you sure you want to delete "${plan.title}"? This action cannot be undone.',
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
      await _provider.delete(plan.id!);
      _showSuccess('Training plan deleted successfully.');
      _load();
    } catch (e) {
      _showError('Failed to delete training plan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      'Training Plans',
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_plans.length} plan${_plans.length != 1 ? 's' : ''}',
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
                      onPressed: () => _openForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Training Plan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
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
                : _plans.isEmpty
                    ? const Center(
                        child: Text(
                          'No training plans found.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _plans.length,
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: ExpansionTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.indigo,
                                child: Icon(
                                  Icons.assignment,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                plan.title ?? 'Untitled',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '\$${plan.basePrice?.toStringAsFixed(2) ?? '0.00'}'
                                ' • ${plan.exercises?.length ?? 0} exercise(s)',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    tooltip: 'Edit',
                                    onPressed: () => _openForm(plan: plan),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Delete',
                                    onPressed: () => _confirmDelete(plan),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (plan.description != null &&
                                          plan.description!.isNotEmpty) ...[
                                        Text(plan.description!),
                                        const SizedBox(height: 8),
                                      ],
                                      Text(
                                        'Trainer ID: ${plan.personalTrainerId ?? 'N/A'}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        'User ID: ${plan.userId ?? 'N/A'}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      if (plan.exercises != null &&
                                          plan.exercises!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Exercises:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ...plan.exercises!.map(
                                          (ep) => Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8,
                                              top: 4,
                                            ),
                                            child: Text(
                                              '• ${ep.exercise?.name ?? 'Exercise #${ep.exerciseId}'}',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
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

// ─── Form screen ────────────────────────────────────────────────────────────

class _TrainingPlanFormScreen extends StatefulWidget {
  final TrainingPlan? plan;

  const _TrainingPlanFormScreen({this.plan});

  @override
  State<_TrainingPlanFormScreen> createState() =>
      _TrainingPlanFormScreenState();
}

class _TrainingPlanFormScreenState extends State<_TrainingPlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _provider = TrainingPlanProvider();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;

  bool _isLoading = true;
  bool _isSaving = false;

  List<PersonalTrainer> _trainers = [];
  List<Map<String, dynamic>> _users = [];

  int? _selectedTrainerId;
  int? _selectedUserId;

  bool get _isEdit => widget.plan != null;

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    _titleCtrl = TextEditingController(text: plan?.title ?? '');
    _descCtrl = TextEditingController(text: plan?.description ?? '');
    _priceCtrl = TextEditingController(
      text: plan?.basePrice?.toString() ?? '',
    );
    _selectedTrainerId = plan?.personalTrainerId;
    _selectedUserId = plan?.userId;

    _fetchDropdownData();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final trainerResult = await PersonalTrainerProvider().get();
      final userResult = await AdminProvider().getAllUsers();
      setState(() {
        _trainers = trainerResult.result;
        _users = userResult;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load form data.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedTrainerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a personal trainer.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a user.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final plan = TrainingPlan(
      id: widget.plan?.id,
      personalTrainerId: _selectedTrainerId,
      userId: _selectedUserId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      basePrice: double.parse(_priceCtrl.text.trim()),
    );

    try {
      final body = plan.toJson()
        ..remove('createdAt')
        ..remove('exercises');

      if (_isEdit) {
        await _provider.update(widget.plan!.id!, body);
      } else {
        await _provider.insert(body);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Training Plan' : 'New Training Plan'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Title is required'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Description is required'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Base Price *',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Base price is required';
                      if (double.tryParse(v.trim()) == null)
                        return 'Must be a valid number (e.g. 49.99)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedTrainerId,
                    decoration: const InputDecoration(
                      labelText: 'Personal Trainer *',
                      border: OutlineInputBorder(),
                    ),
                    items: _trainers
                        .map(
                          (t) => DropdownMenuItem<int>(
                            value: t.id,
                            child: Text(
                              t.userFirstName != null
                                  ? '${t.userFirstName} (ID: ${t.id})'
                                  : 'Trainer #${t.id}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedTrainerId = val),
                    validator: (val) =>
                        val == null ? 'Please select a trainer' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedUserId,
                    decoration: const InputDecoration(
                      labelText: 'User *',
                      border: OutlineInputBorder(),
                    ),
                    items: _users
                        .map(
                          (u) => DropdownMenuItem<int>(
                            value: u['id'] as int?,
                            child: Text(
                              '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'
                              ' (${u['username'] ?? u['id']})'
                                  .trim(),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedUserId = val),
                    validator: (val) =>
                        val == null ? 'Please select a user' : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isEdit
                                  ? 'Save Changes'
                                  : 'Create Training Plan',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
