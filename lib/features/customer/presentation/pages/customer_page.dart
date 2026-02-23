import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/customer/data/models/customer_model.dart';
import 'package:profesionalservis_mobile/features/customer/presentation/providers/customer_provider.dart';

class CustomerPage extends ConsumerWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerProvider);
    final notifier = ref.read(customerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isSubmitting
            ? null
            : () => _showCustomerForm(context: context, ref: ref),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah Customer'),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Text(
              'Pelanggan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Customer',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              onChanged: notifier.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Cari nama, telepon, atau email...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: state.searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () => notifier.setSearchQuery(''),
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (state.errorMessage != null) ...[
              _ErrorBanner(message: state.errorMessage!),
              const SizedBox(height: 12),
            ],
            if (!state.isLoading && state.items.isEmpty)
              const _EmptyCustomerState()
            else
              ...state.items.map(
                (customer) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CustomerCard(
                    customer: customer,
                    onEdit: () => _showCustomerForm(
                      context: context,
                      ref: ref,
                      customer: customer,
                    ),
                    onDelete: () => _showDeleteConfirmation(
                      context: context,
                      onConfirm: () => notifier.deleteCustomer(customer.id),
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

  Future<void> _showCustomerForm({
    required BuildContext context,
    required WidgetRef ref,
    CustomerModel? customer,
  }) async {
    final nameController = TextEditingController(text: customer?.name);
    final phoneController = TextEditingController(text: customer?.phone);
    final emailController = TextEditingController(text: customer?.email);
    final addressController = TextEditingController(text: customer?.address);
    final notesController = TextEditingController(text: customer?.notes);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer == null ? 'Tambah Pelanggan' : 'Edit Pelanggan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama pelanggan'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'No. telepon'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Catatan'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final payload = CustomerModel(
                      id: customer?.id ?? '',
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      address: addressController.text.trim(),
                      notes: notesController.text.trim(),
                    );

                    if (payload.name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama pelanggan wajib diisi.')),
                      );
                      return;
                    }

                    final notifier = ref.read(customerProvider.notifier);
                    final success = customer == null
                        ? await notifier.addCustomer(payload)
                        : await notifier.updateCustomer(id: customer.id, customer: payload);

                    if (context.mounted && success) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(customer == null ? 'Simpan' : 'Update'),
                ),
              ),
            ],
          ),
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    notesController.dispose();
  }

  Future<void> _showDeleteConfirmation({
    required BuildContext context,
    required Future<bool> Function() onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus pelanggan?'),
        content: const Text('Data pelanggan yang dihapus tidak bisa dikembalikan.'),
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

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  final CustomerModel customer;
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
              color: const Color(0xFFFFF4ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_rounded, color: Color(0xFFB54708)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                _infoText(context, Icons.phone_rounded, customer.phone, fallback: '-'),
                _infoText(context, Icons.mail_outline_rounded, customer.email, fallback: '-'),
                if (customer.address.isNotEmpty)
                  _infoText(context, Icons.location_on_outlined, customer.address),
                if (customer.notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      customer.notes,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF667085),
                      ),
                    ),
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

  Widget _infoText(BuildContext context, IconData icon, String value, {String fallback = ''}) {
    final display = value.isEmpty ? fallback : value;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF98A2B3)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              display,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF667085),
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECDCA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFB42318)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFB42318),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCustomerState extends StatelessWidget {
  const _EmptyCustomerState();

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
          const Icon(Icons.people_outline_rounded, size: 44, color: Color(0xFF98A2B3)),
          const SizedBox(height: 10),
          Text(
            'Belum ada data pelanggan.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan pelanggan pertama untuk mulai kelola relasi customer.',
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
