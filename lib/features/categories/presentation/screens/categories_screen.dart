import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category_model.dart';
import '../providers/categories_provider.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(context, ref),
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        data: (rows) => ListView.builder(
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final row = rows[index];
            return ListTile(
              title: Text(row.name),
              subtitle: Text(row.keywords.join(', ')),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    _showEditor(context, ref, existing: row);
                  } else if (value == 'delete') {
                    await ref.read(categoryMutationsProvider).delete(row.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            );
          },
        ),
        error: (e, s) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref, {
    CategoryModel? existing,
  }) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final iconCtrl = TextEditingController(text: existing?.icon ?? 'category');
    final colorCtrl = TextEditingController(text: existing?.color ?? '#90A4AE');
    final keywordsCtrl = TextEditingController(text: existing?.keywords.join(', ') ?? '');

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Add Category' : 'Edit Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'Icon')),
              TextField(controller: colorCtrl, decoration: const InputDecoration(labelText: 'Color Hex')),
              TextField(
                controller: keywordsCtrl,
                decoration: const InputDecoration(labelText: 'Keywords (comma-separated)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final model = existing ?? CategoryModel();
              model
                ..name = nameCtrl.text.trim()
                ..icon = iconCtrl.text.trim()
                ..color = colorCtrl.text.trim()
                ..keywords = keywordsCtrl.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
              await ref.read(categoryMutationsProvider).upsert(model);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
