import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:primeos/features/goals/domain/entities/goal.dart';
import 'package:primeos/features/goals/presentation/providers/goals_provider.dart';
import 'package:primeos/features/goals/presentation/providers/goal_categories_provider.dart';

class GoalFormSheet extends ConsumerStatefulWidget {
  final Goal? existingGoal;

  const GoalFormSheet({this.existingGoal, super.key});

  @override
  ConsumerState<GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<GoalFormSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetValueController;
  late TextEditingController _targetUnitController;

  String? _selectedCategoryId;
  String _status = 'active';
  DateTime? _selectedTargetDate;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingGoal?.title ?? '');
    _descriptionController = TextEditingController(text: widget.existingGoal?.description ?? '');
    _targetValueController = TextEditingController(
      text: widget.existingGoal?.targetValue?.toString() ?? '',
    );
    _targetUnitController = TextEditingController(text: widget.existingGoal?.targetUnit ?? '');

    _selectedCategoryId = widget.existingGoal?.categoryId;
    _status = widget.existingGoal?.status ?? 'active';
    _selectedTargetDate = widget.existingGoal?.targetDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _targetUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(goalCategoriesProvider);

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
                    widget.existingGoal == null ? 'New Goal' : 'Edit Goal',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter goal title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: 16),

              // Category dropdown
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: categories
                      .map((category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategoryId = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (error, st) => Text('Error loading categories: $error'),
              ),
              const SizedBox(height: 16),

              // Status dropdown
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'paused', child: Text('Paused')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'abandoned', child: Text('Abandoned')),
                ]
                    .map((item) => item)
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Target value field
              TextFormField(
                controller: _targetValueController,
                decoration: InputDecoration(
                  labelText: 'Target Value (Optional)',
                  hintText: 'e.g., 100',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Target unit field
              TextFormField(
                controller: _targetUnitController,
                decoration: InputDecoration(
                  labelText: 'Target Unit (Optional)',
                  hintText: 'e.g., km, pages, hours',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Target date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Target Date (Optional)'),
                subtitle: Text(
                  _selectedTargetDate == null
                      ? 'No date selected'
                      : '${_selectedTargetDate!.year}-${_selectedTargetDate!.month.toString().padLeft(2, '0')}-${_selectedTargetDate!.day.toString().padLeft(2, '0')}',
                ),
                trailing: _selectedTargetDate == null
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() => _selectedTargetDate = null);
                  },
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedTargetDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (pickedDate != null) {
                    setState(() => _selectedTargetDate = pickedDate);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveGoal,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(widget.existingGoal == null ? 'Create Goal' : 'Update Goal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final targetValue = _targetValueController.text.isEmpty
          ? null
          : double.tryParse(_targetValueController.text);

      if (widget.existingGoal == null) {
        // Create new goal
        final newGoal = Goal(
          id: const Uuid().v4(),
          categoryId: _selectedCategoryId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          status: _status,
          targetValue: targetValue,
          targetUnit: _targetUnitController.text.trim().isEmpty
              ? null
              : _targetUnitController.text.trim(),
          targetDate: _selectedTargetDate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await ref.read(goalsProvider.notifier).addGoal(newGoal);
      } else {
        // Update existing goal
        final updatedGoal = widget.existingGoal!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          categoryId: _selectedCategoryId!,
          status: _status,
          targetValue: targetValue,
          targetUnit: _targetUnitController.text.trim().isEmpty
              ? null
              : _targetUnitController.text.trim(),
          targetDate: _selectedTargetDate,
          updatedAt: DateTime.now(),
        );

        await ref.read(goalsProvider.notifier).updateGoal(updatedGoal);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingGoal == null ? 'Goal created' : 'Goal updated',
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
