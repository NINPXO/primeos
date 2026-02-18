import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:primeos/features/progress/domain/entities/progress_entry.dart';
import 'package:primeos/features/progress/presentation/providers/progress_provider.dart';
import 'package:primeos/features/goals/presentation/providers/goals_provider.dart';

class ProgressFormScreen extends ConsumerStatefulWidget {
  final ProgressEntry? existingEntry;

  const ProgressFormScreen({this.existingEntry, super.key});

  @override
  ConsumerState<ProgressFormScreen> createState() =>
      _ProgressFormScreenState();
}

class _ProgressFormScreenState extends ConsumerState<ProgressFormScreen> {
  late TextEditingController _valueController;
  late TextEditingController _unitController;
  late TextEditingController _noteController;

  String? _selectedGoalId;
  String _trackingPeriod = 'daily'; // daily|weekly|monthly
  DateTime? _loggedDate;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _valueController =
        TextEditingController(text: widget.existingEntry?.value.toString() ?? '');
    _unitController =
        TextEditingController(text: widget.existingEntry?.unit ?? '');
    _noteController =
        TextEditingController(text: widget.existingEntry?.note ?? '');

    _selectedGoalId = widget.existingEntry?.goalId;
    _trackingPeriod = widget.existingEntry?.trackingPeriod ?? 'daily';
    _loggedDate = widget.existingEntry?.loggedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existingEntry == null
                        ? 'New Progress Entry'
                        : 'Edit Progress Entry',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Goal selector dropdown
              goalsAsync.when(
                data: (goals) => DropdownButtonFormField<String>(
                  value: _selectedGoalId,
                  decoration: InputDecoration(
                    labelText: 'Goal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: goals
                      .map((goal) => DropdownMenuItem(
                            value: goal.id,
                            child: Text(goal.title),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedGoalId = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a goal';
                    }
                    return null;
                  },
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (error, st) => Text('Error loading goals: $error'),
              ),
              const SizedBox(height: 16),

              // Value input field
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: 'Value',
                  hintText: 'Enter numeric value',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Value is required';
                  }
                  final numValue = double.tryParse(value);
                  if (numValue == null) {
                    return 'Must be a valid number';
                  }
                  if (numValue <= 0) {
                    return 'Value must be positive';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Unit input field
              TextFormField(
                controller: _unitController,
                decoration: InputDecoration(
                  labelText: 'Unit (Optional)',
                  hintText: 'e.g., km, pages, hours',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tracking period dropdown
              DropdownButtonFormField<String>(
                value: _trackingPeriod,
                decoration: InputDecoration(
                  labelText: 'Tracking Period',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ]
                    .map((item) => item)
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _trackingPeriod = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Logged Date'),
                subtitle: Text(
                  _loggedDate == null
                      ? 'No date selected'
                      : '${_loggedDate!.year}-${_loggedDate!.month.toString().padLeft(2, '0')}-${_loggedDate!.day.toString().padLeft(2, '0')}',
                ),
                trailing: _loggedDate == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() => _loggedDate = null);
                        },
                      ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _loggedDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() => _loggedDate = pickedDate);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Note text area
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: 'Add any notes about this progress',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveEntry,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.existingEntry == null
                          ? 'Create Entry'
                          : 'Update Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGoalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a goal')),
      );
      return;
    }

    if (_loggedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a logged date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final value = double.parse(_valueController.text);

      if (widget.existingEntry == null) {
        // Get goal to retrieve categoryId
        final goalsResult = await ref.read(goalsProvider.notifier)
            .getProgressForGoal(_selectedGoalId!);

        // Find the goal to get its categoryId - we need to fetch goals
        final allGoals = ref.read(goalsProvider).value ?? [];
        final selectedGoal =
            allGoals.firstWhere((g) => g.id == _selectedGoalId);

        // Create new entry
        final newEntry = ProgressEntry(
          id: const Uuid().v4(),
          goalId: _selectedGoalId!,
          categoryId: selectedGoal.categoryId,
          value: value,
          unit: _unitController.text.trim().isEmpty
              ? null
              : _unitController.text.trim(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          trackingPeriod: _trackingPeriod,
          loggedDate: _loggedDate!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await ref.read(progressProvider.notifier).createEntry(newEntry);
      } else {
        // Update existing entry
        final updatedEntry = widget.existingEntry!.copyWith(
          goalId: _selectedGoalId!,
          value: value,
          unit: _unitController.text.trim().isEmpty
              ? null
              : _unitController.text.trim(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          trackingPeriod: _trackingPeriod,
          loggedDate: _loggedDate!,
          updatedAt: DateTime.now(),
        );

        await ref.read(progressProvider.notifier).updateEntry(updatedEntry);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingEntry == null
                  ? 'Progress entry created'
                  : 'Progress entry updated',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
