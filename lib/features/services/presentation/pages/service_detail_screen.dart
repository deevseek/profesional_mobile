import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/product/data/models/product_model.dart';
import 'package:profesionalservis_mobile/features/services/data/models/service_item_model.dart';
import 'package:profesionalservis_mobile/features/services/data/models/service_model.dart';
import 'package:profesionalservis_mobile/features/services/domain/service_payloads.dart';
import 'package:profesionalservis_mobile/features/services/domain/service_status.dart';
import 'package:profesionalservis_mobile/features/services/presentation/pages/service_receipt_preview_screen.dart';
import 'package:profesionalservis_mobile/features/services/presentation/providers/service_providers.dart';
import 'package:profesionalservis_mobile/features/services/presentation/widgets/service_widgets.dart';

class ServiceDetailScreen extends ConsumerWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(serviceDetailProvider(serviceId));
    final notifier = ref.read(serviceDetailProvider(serviceId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Service'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.receipt_long_rounded),
            onSelected: (value) async {
              try {
                if (value == 'receipt') {
                  final receipt = await notifier.getReceipt();
                  if (!context.mounted) return;
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ServiceReceiptPreviewScreen(
                        service: receipt.service,
                        store: receipt.store,
                      ),
                    ),
                  );
                  return;
                }

                final invoice = await notifier.getInvoice();
                if (!context.mounted) return;
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ServiceReceiptPreviewScreen(
                      service: invoice.service,
                      store: invoice.store,
                      transaction: invoice.transaction,
                    ),
                  ),
                );
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value == 'invoice'
                          ? 'Invoice belum tersedia atau gagal dimuat'
                          : 'Tanda terima gagal dimuat',
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'receipt', child: Text('Tanda Terima')),
              PopupMenuItem(value: 'invoice', child: Text('Invoice')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: detailAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [ServiceSkeletonCard(), ServiceSkeletonCard(), ServiceSkeletonCard()],
          ),
          error: (_, __) => ListView(
            children: [
              SizedBox(height: 360, child: ServiceErrorState(onRetry: notifier.refresh)),
            ],
          ),
          data: (service) => _DetailContent(service: service, serviceId: serviceId),
        ),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.service, required this.serviceId});

  final ServiceModel service;
  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(serviceDetailProvider(serviceId).notifier);
    final status = ServiceStatusX.fromRaw(service.status);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderCard(service: service),
        const SizedBox(height: 12),
        _StatusStepper(
          current: status,
          onQuickNext: () async {
            final next = status.next;
            if (next == null) return;
            final ok = await notifier.updateService({'status': next.value});
            if (context.mounted && ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Status diubah ke ${next.label}')),
              );
            }
          },
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Informasi Keluhan',
          child: Text(service.complaint.isEmpty ? '-' : service.complaint),
        ),
        const SizedBox(height: 12),
        _DiagnosisSection(serviceId: serviceId, diagnosis: service.diagnosis),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Item Sparepart',
          trailing: TextButton.icon(
            onPressed: () => _showAddItemDialog(context, serviceId),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Item'),
          ),
          child: _ItemList(serviceId: serviceId, items: service.items),
        ),
        const SizedBox(height: 12),
        _FinalCostSection(serviceId: serviceId, finalCost: service.finalCost),

        const SizedBox(height: 12),
        _TrackingSection(serviceId: serviceId),
      ],
    );
  }

  Future<void> _showAddItemDialog(BuildContext context, String serviceId) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _AddItemDialog(serviceId: serviceId),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(service.serviceNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ),
              ServiceStatusBadge(status: service.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(service.customerName, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('${service.deviceName} • ${service.deviceType}'),
        ],
      ),
    );
  }
}

class _StatusStepper extends StatelessWidget {
  const _StatusStepper({required this.current, required this.onQuickNext});

  final ServiceStatus current;
  final Future<void> Function() onQuickNext;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Workflow Status',
      trailing: current.next == null
          ? null
          : ElevatedButton(
              onPressed: () => onQuickNext(),
              child: Text('Next: ${current.next!.label}'),
            ),
      child: Row(
        children: ServiceStatus.values.map((status) {
          final done = ServiceStatus.values.indexOf(status) <= ServiceStatus.values.indexOf(current);
          return Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: done ? const Color(0xFFFF7A00) : const Color(0xFFE4E7EC),
                  child: Icon(Icons.check, size: 14, color: done ? Colors.white : const Color(0xFF98A2B3)),
                ),
                const SizedBox(height: 4),
                Text(status.label, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
              ],
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _DiagnosisSection extends ConsumerStatefulWidget {
  const _DiagnosisSection({required this.serviceId, required this.diagnosis});

  final String serviceId;
  final String diagnosis;

  @override
  ConsumerState<_DiagnosisSection> createState() => _DiagnosisSectionState();
}

class _DiagnosisSectionState extends ConsumerState<_DiagnosisSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.diagnosis);
  }

  @override
  void didUpdateWidget(covariant _DiagnosisSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.diagnosis != widget.diagnosis) {
      _controller.text = widget.diagnosis;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(serviceDetailProvider(widget.serviceId).notifier);

    return _SectionCard(
      title: 'Diagnosis Teknisi',
      trailing: TextButton(
        onPressed: () async {
          final ok = await notifier.updateService({'diagnosis': _controller.text});
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(ok ? 'Diagnosis diperbarui' : 'Gagal update diagnosis')),
            );
          }
        },
        child: const Text('Simpan'),
      ),
      child: TextField(
        controller: _controller,
        minLines: 2,
        maxLines: 4,
        decoration: const InputDecoration(hintText: 'Tulis diagnosis teknisi...'),
      ),
    );
  }
}

class _ItemList extends ConsumerWidget {
  const _ItemList({required this.serviceId, required this.items});

  final String serviceId;
  final List<ServiceItemModel> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const ServiceEmptyState(message: 'Belum ada sparepart ditambahkan.');
    }

    final notifier = ref.read(serviceDetailProvider(serviceId).notifier);

    return ListView.separated(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: const Color(0xFFD92D20),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            return showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Hapus item?'),
                    content: const Text('Item sparepart akan dihapus dari service.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (_) async {
            await notifier.removeItem(item.id);
          },
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.productName),
            subtitle: Text('${item.qty} x ${_money(item.price)}'),
            trailing: Text(_money(item.subtotal), style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        );
      },
    );
  }
}

class _FinalCostSection extends ConsumerStatefulWidget {
  const _FinalCostSection({required this.serviceId, required this.finalCost});

  final String serviceId;
  final int finalCost;

  @override
  ConsumerState<_FinalCostSection> createState() => _FinalCostSectionState();
}

class _FinalCostSectionState extends ConsumerState<_FinalCostSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.finalCost.toString());
  }

  @override
  void didUpdateWidget(covariant _FinalCostSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.finalCost != oldWidget.finalCost) {
      _controller.text = widget.finalCost.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(serviceDetailProvider(widget.serviceId).notifier);

    return _SectionCard(
      title: 'Total Biaya',
      trailing: TextButton(
        onPressed: () async {
          final amount = int.tryParse(_controller.text) ?? 0;
          final ok = await notifier.updateService({'service_fee': amount});
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(ok ? 'Total biaya diperbarui' : 'Gagal update biaya')),
            );
          }
        },
        child: const Text('Update'),
      ),
      child: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(prefixText: 'Rp '),
      ),
    );
  }
}

class _AddItemDialog extends ConsumerStatefulWidget {
  const _AddItemDialog({required this.serviceId});

  final String serviceId;

  @override
  ConsumerState<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends ConsumerState<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  ProductModel? _selectedProduct;
  final _searchController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productSearchProvider(_searchController.text));
    final notifier = ref.read(serviceDetailProvider(widget.serviceId).notifier);

    return AlertDialog(
      title: const Text('Tambah Item Sparepart'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Cari produk...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 8),
              productsAsync.when(
                loading: () => const LinearProgressIndicator(minHeight: 3),
                error: (_, __) => const Text('Gagal memuat produk'),
                data: (products) => DropdownButtonFormField<ProductModel>(
                  value: _selectedProduct,
                  items: products
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                      .toList(growable: false),
                  onChanged: (value) {
                    setState(() {
                      _selectedProduct = value;
                      _priceController.text = (value?.price ?? 0).toString();
                    });
                  },
                  validator: (value) => value == null ? 'Pilih produk' : null,
                  decoration: const InputDecoration(labelText: 'Produk'),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Qty'),
                validator: (value) => (int.tryParse(value ?? '') ?? 0) <= 0 ? 'Qty invalid' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga'),
                validator: (value) => (int.tryParse(value ?? '') ?? 0) <= 0 ? 'Harga harus lebih dari 0' : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Subtotal: ${_money((int.tryParse(_qtyController.text) ?? 0) * (int.tryParse(_priceController.text) ?? 0))}',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        FilledButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            final ok = await notifier.addItem(
              AddServiceItemPayload(
                productId: _selectedProduct!.id,
                qty: int.parse(_qtyController.text),
                price: int.parse(_priceController.text),
              ),
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ok ? 'Item ditambahkan' : 'Gagal tambah item')),
              );
            }
            if (ok && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

String _money(int value) {
  return 'Rp ${value.toString()}';
}

class _TrackingSection extends ConsumerWidget {
  const _TrackingSection({required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingAsync = ref.watch(serviceTrackingProvider(serviceId));

    return _SectionCard(
      title: 'QR Tracking Service',
      child: trackingAsync.when(
        loading: () => const LinearProgressIndicator(minHeight: 3),
        error: (_, __) => const Text('Gagal memuat QR tracking.'),
        data: (tracking) {
          final url = tracking.progressUrl;
          final qrUrl = tracking.qrUrl;
          if (url.isEmpty && qrUrl.isEmpty) {
            return const Text('Tracking URL belum tersedia.');
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (qrUrl.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      qrUrl,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        width: 150,
                        height: 150,
                        child: Center(child: Text('QR gagal dimuat')),
                      ),
                    ),
                  ),
                ),
              if (url.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(url, style: const TextStyle(fontSize: 12, color: Color(0xFF475467))),
              ],
            ],
          );
        },
      ),
    );
  }
}
