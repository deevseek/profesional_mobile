import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/services/data/models/service_model.dart';
import 'package:profesionalservis_mobile/features/services/domain/service_status.dart';
import 'package:profesionalservis_mobile/features/services/presentation/pages/create_service_screen.dart';
import 'package:profesionalservis_mobile/features/services/presentation/pages/service_detail_screen.dart';
import 'package:profesionalservis_mobile/features/services/presentation/providers/service_providers.dart';
import 'package:profesionalservis_mobile/features/services/presentation/widgets/service_widgets.dart';

class ServiceListScreen extends ConsumerStatefulWidget {
  const ServiceListScreen({super.key});

  @override
  ConsumerState<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends ConsumerState<ServiceListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(serviceListProvider.notifier).fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(serviceListProvider);
    final notifier = ref.read(serviceListProvider.notifier);
    final listState = listAsync.valueOrNull;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateServiceScreen()),
          );
          if (mounted) {
            await notifier.refresh();
          }
        },
        backgroundColor: const Color(0xFFFF7A00),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Service', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Column(
              children: [
                TextField(
                  onChanged: notifier.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cari nomor service / customer',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: (listState?.search ?? '').isNotEmpty
                        ? IconButton(
                            onPressed: () => notifier.onSearchChanged(''),
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        selected: listState?.status == null,
                        label: const Text('Semua'),
                        onSelected: (_) => notifier.setStatus(null),
                      ),
                      const SizedBox(width: 8),
                      ...ServiceStatus.values.map(
                        (status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: listState?.status == status.value,
                            label: Text(status.label),
                            onSelected: (_) => notifier.setStatus(status.value),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: notifier.refresh,
              child: listAsync.when(
                loading: () => ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  children: const [
                    ServiceSkeletonCard(),
                    ServiceSkeletonCard(),
                    ServiceSkeletonCard(),
                  ],
                ),
                error: (_, __) => ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.5,
                      child: ServiceErrorState(onRetry: notifier.refresh),
                    ),
                  ],
                ),
                data: (state) {
                  if (state.items.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(
                          height: 380,
                          child: ServiceEmptyState(message: 'Belum ada data service.'),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                    itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final service = state.items[index];
                      return _ServiceCard(service: service);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ServiceDetailScreen(serviceId: service.id)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      service.serviceNumber,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  ServiceStatusBadge(status: service.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(service.customerName, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('${service.deviceName} • ${service.deviceType}'),
              const SizedBox(height: 6),
              Text(
                _dateLabel(service.createdAt),
                style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateLabel(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
