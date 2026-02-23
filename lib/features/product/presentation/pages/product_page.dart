import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/product/data/models/product_model.dart';
import 'package:profesionalservis_mobile/features/product/presentation/providers/product_provider.dart';

class ProductPage extends ConsumerWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productProvider);
    final notifier = ref.read(productProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isSubmitting
            ? null
            : () => _showProductForm(context: context, ref: ref),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Text(
              'Inventory Produk',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kelola stok produk ala Moka POS.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              onChanged: notifier.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Cari produk, SKU, atau kategori...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: state.searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () => notifier.setSearchQuery(''),
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    label: 'Semua',
                    selected: state.selectedCategory == null,
                    onTap: () => notifier.setCategory(null),
                  ),
                  ...state.categories.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _CategoryChip(
                        label: category,
                        selected: state.selectedCategory == category,
                        onTap: () => notifier.setCategory(category),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (state.errorMessage != null) ...[
              _ErrorBanner(message: state.errorMessage!),
              const SizedBox(height: 12),
            ],
            if (!state.isLoading && state.items.isEmpty)
              const _EmptyProductState()
            else
              ...state.items.map(
                (product) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ProductCard(
                    product: product,
                    onEdit: () => _showProductForm(
                      context: context,
                      ref: ref,
                      product: product,
                    ),
                    onDelete: () => _showDeleteConfirmation(
                      context: context,
                      onConfirm: () async {
                        final success = await notifier.deleteProduct(product.id);
                        return success;
                      },
                    ),
                  ),
                ),
              ),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (state.hasNextPage && !state.isLoading)
              Center(
                child: TextButton.icon(
                  onPressed: notifier.fetchMore,
                  icon: const Icon(Icons.expand_more_rounded),
                  label: const Text('Muat lebih banyak'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showProductForm({
    required BuildContext context,
    required WidgetRef ref,
    ProductModel? product,
  }) async {
    final nameController = TextEditingController(text: product?.name);
    final skuController = TextEditingController(text: product?.sku);
    final categoryController = TextEditingController(text: product?.category);
    final stockController = TextEditingController(
      text: product == null ? '' : product.stock.toString(),
    );
    final priceController = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    final descController = TextEditingController(text: product?.description);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product == null ? 'Tambah Produk' : 'Edit Produk',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama produk'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: skuController,
                decoration: const InputDecoration(labelText: 'SKU'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stok'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Harga'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final parsed = ProductModel(
                      id: product?.id ?? '',
                      name: nameController.text.trim(),
                      sku: skuController.text.trim(),
                      category: categoryController.text.trim(),
                      stock: int.tryParse(stockController.text) ?? 0,
                      price: int.tryParse(priceController.text) ?? 0,
                      description: descController.text.trim(),
                    );

                    if (parsed.name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama produk wajib diisi.')),
                      );
                      return;
                    }

                    final notifier = ref.read(productProvider.notifier);
                    final success = product == null
                        ? await notifier.addProduct(parsed)
                        : await notifier.updateProduct(id: product.id, product: parsed);

                    if (context.mounted && success) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(product == null ? 'Simpan' : 'Update'),
                ),
              ),
            ],
          ),
        );
      },
    );

    nameController.dispose();
    skuController.dispose();
    categoryController.dispose();
    stockController.dispose();
    priceController.dispose();
    descController.dispose();
  }

  Future<void> _showDeleteConfirmation({
    required BuildContext context,
    required Future<bool> Function() onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: const Text('Data produk yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (result == true) {
      await onConfirm();
    }
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF175CD3)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: ${product.sku.isEmpty ? '-' : product.sku}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _InfoBadge(label: 'Kategori ${product.category}'),
                    _InfoBadge(label: 'Stok ${product.stock}'),
                    _InfoBadge(label: 'Rp ${product.price}'),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF344054),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE4E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: const Color(0xFFB42318)),
      ),
    );
  }
}

class _EmptyProductState extends StatelessWidget {
  const _EmptyProductState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 34, color: Color(0xFF98A2B3)),
          const SizedBox(height: 10),
          Text(
            'Belum ada produk',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan produk baru menggunakan tombol + di bawah.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}
