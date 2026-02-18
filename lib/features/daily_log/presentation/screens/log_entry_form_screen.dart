import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:primeos/features/daily_log/domain/entities/daily_log_entry.dart';
import 'package:primeos/features/daily_log/presentation/providers/daily_log_provider.dart';

class LogEntryFormSheet extends ConsumerStatefulWidget {
  final DailyLogEntry? existingEntry;
  final DateTime initialDate;

  const LogEntryFormSheet({
    this.existingEntry,
    required this.initialDate,
    super.key,
  });

  @override
  ConsumerState<LogEntryFormSheet> createState() => _LogEntryFormSheetState();
}

class _LogEntryFormSheetState extends ConsumerState<LogEntryFormSheet> {
  late TextEditingController _titleController;
  late TextEditingController _detailController;
  late TextEditingController _durationController;
  late TextEditingController _linkedIdController;

  String? _selectedCategoryId;
  String? _linkedType;
  DateTime? _selectedDate;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingEntry?.title ?? '');
    _detailController = TextEditingController(text: widget.existingEntry?.detail ?? '');
    _durationController = TextEditingController(
      text: widget.existingEntry?.durationMins?.toString() ?? '',
    );
    _linkedIdController = TextEditingController(text: widget.existingEntry?.linkedId ?? '');

    _selectedCategoryId = widget.existingEntry?.categoryId;
    _linkedType = widget.existingEntry?.linkedType;
    _selectedDate = widget.existingEntry?.logDate ?? widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    _durationController.dispose();
    _linkedIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(dailyLogCategoriesProvider);

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
                    widget.existingEntry == null ? 'New Log Entry' : 'Edit Entry',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(
                  _selectedDate == null
                      ? 'No date selected'
                      : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                ),
                trailing: _selectedDate == null
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() => _selectedDate = null);
                  },
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? widget.initialDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 7)),
                  );
                  if (pickedDate != null) {
                    setState(() => _selectedDate = pickedDate);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Category dropdown
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    hintText: 'Select a category',
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

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter log entry title',
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

              // Detail field
              TextFormField(
                controller: _detailController,
                decoration: InputDecoration(
                  labelText: 'Detail',
                  hintText: 'Optional details about this entry',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: 16),

              // Duration field
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: 'Duration (minutes)',
                  hintText: 'Optional duration',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final parsed = int.tryParse(value);
                    if (parsed == null || parsed < 0) {
                      return 'Duration must be a non-negative number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Linked type dropdown
              DropdownButtonFormField<String?>(
                value: _linkedType,
                decoration: InputDecoration(
                  labelText: 'Linked Type (Optional)',
                  hintText: 'Link this entry to a change',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('None')),
                  DropdownMenuItem(
                    value: 'goal_change',
                    child: Text('Goal Change'),
                  ),
                  DropdownMenuItem(
                    value: 'progress_change',
                    child: Text('Progress Change'),
                  ),
                ]
                    .map((item) => item)
                    .toList(),
                onChanged: (value) {
                  setState(() => _linkedType = value);
                },
              ),
              const SizedBox(height: 16),

              // Linked ID field (only if linkedType is selected)
              if (_linkedType != null && _linkedType!.isNotEmpty)
                TextFormField(
                  controller: _linkedIdController,
                  decoration: InputDecoration(
                    labelText: 'Linked ID',
                    hintText: 'ID of linked goal or progress entry',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              if (_linkedType != null && _linkedType!.isNotEmpty)
                const SizedBox(height: 16),

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
                      : Text(widget.existingEntry == null ? 'Create Entry' : 'Update Entry'),
                ),
              ),
              const SizedBox(height: 16),
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

    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final durationMins = _durationController.text.isEmpty
          ? null
          : int.tryParse(_durationController.text);

      final now = DateTime.now();

      if (widget.existingEntry == null) {
        // Create new entry
        final newEntry = DailyLogEntry(
          id: const Uuid().v4(),
          logDate: _selectedDate!,
          categoryId: _selectedCategoryId!,
          title: _titleController.text.trim(),
          detail: _detailController.text.trim().isEmpty
              ? null
              : _detailController.text.trim(),
          durationMins: durationMins,
          linkedType: _linkedType?.isEmpty ?? true ? null : _linkedType,
          linkedId: _linkedIdController.text.trim().isEmpty
              ? null
              : _linkedIdController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );

        await ref.read(dailyLogProvider.notifier).createEntry(newEntry);
      } else {
        // Update existing entry
        final updatedEntry = widget.existingEntry!.copyWith(
          logDate: _selectedDate!,
          categoryId: _selectedCategoryId!,
          title: _titleController.text.trim(),
          detail: _detailController.text.trim().isEmpty
              ? null
              : _detailController.text.trim(),
          durationMins: durationMins,
          linkedType: _linkedType?.isEmpty ?? true ? null : _linkedType,
          linkedId: _linkedIdController.text.trim().isEmpty
              ? null
              : _linkedIdController.text.trim(),
          updatedAt: now,
        );

        await ref.read(dailyLogProvider.notifier).updateEntry(updatedEntry);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingEntry == null ? 'Entry created' : 'Entry updated',
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
