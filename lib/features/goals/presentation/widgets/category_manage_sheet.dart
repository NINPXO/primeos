import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:primeos/features/goals/domain/entities/goal_category.dart';
import 'package:primeos/features/goals/presentation/providers/goal_categories_provider.dart';

class CategoryManageSheet extends ConsumerStatefulWidget {
  const CategoryManageSheet({super.key});

  @override
  ConsumerState<CategoryManageSheet> createState() => _CategoryManageSheetState();
}

class _CategoryManageSheetState extends ConsumerState<CategoryManageSheet> {
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage Categories',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add category form
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'New Category Name',
                hintText: 'Enter category name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
                onPressed: _isLoading ? null : _addCategory,
              ),
            ),
            const SizedBox(height: 24),

            // Divider
            Divider(
              color: Theme.of(context).colorScheme.outlineVariant,
              height: 32,
            ),

            // Existing categories list
            Text(
              'Existing Categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No categories yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(category.name),
                      subtitle: category.isSystem ? const Text('System category') : null,
                      trailing: category.isSystem
                          ? null
                          : IconButton(
                        icon: const Icon(Icons.delete),
                        color: Theme.of(context).colorScheme.error,
                        onPressed: () => _confirmDeleteCategory(context, category.id),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, st) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: $error'),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _addCategory() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newCategory = GoalCategory(
        id: const Uuid().v4(),
        name: name,
        isSystem: false,
        colorHex: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(goalCategoriesProvider.notifier).addCategory(newCategory);

      _nameController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added')),
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

  void _confirmDeleteCategory(BuildContext context, String categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text(
          'Are you sure you want to delete this category? Goals in this category will need to be reassigned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(goalCategoriesProvider.notifier).deleteCategory(categoryId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Category deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
