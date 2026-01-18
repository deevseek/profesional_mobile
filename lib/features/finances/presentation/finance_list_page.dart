import 'package:flutter/material.dart';

import '../domain/finance_model.dart';
import 'finance_controller.dart';

class FinanceListPage extends StatefulWidget {
  const FinanceListPage({super.key});

  @override
  State<FinanceListPage> createState() => _FinanceListPageState();
}

class _FinanceListPageState extends State<FinanceListPage> {
  final FinanceController _controller = FinanceController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {});
    });
    _typeController.addListener(() {
      setState(() {});
    });
    _controller.loadFinances();
  }

  @override
  void dispose() {
    _controller.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Finances'),
            actions: [
              IconButton(
                onPressed: _controller.isLoading
                    ? null
                    : () => _controller.loadFinances(
                          description: _descriptionController.text,
                          type: _typeController.text,
                          page: 1,
                        ),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(context),
              _buildTypeFilter(context),
              if (_controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildErrorBanner(_controller.errorMessage!),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _controller.loadFinances(
                      description: _descriptionController.text,
                      type: _typeController.text,
                      page: _controller.page,
                    );
                  },
                  child: _buildList(context),
                ),
              ),
              _buildPagination(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SearchBar(
        controller: _descriptionController,
        hintText: 'Search by description',
        leading: const Icon(Icons.search),
        trailing: [
          if (_descriptionController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _descriptionController.clear();
                _controller.loadFinances(
                  description: '',
                  type: _typeController.text,
                  page: 1,
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _controller.isLoading
                ? null
                : () => _controller.loadFinances(
                      description: _descriptionController.text,
                      type: _typeController.text,
                      page: 1,
                    ),
          ),
        ],
        onSubmitted: (value) {
          _controller.loadFinances(
            description: value,
            type: _typeController.text,
            page: 1,
          );
        },
      ),
    );
  }

  Widget _buildTypeFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _typeController,
        decoration: InputDecoration(
          labelText: 'Type',
          prefixIcon: const Icon(Icons.category_outlined),
          suffixIcon: _typeController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _typeController.clear();
                    _controller.loadFinances(
                      description: _descriptionController.text,
                      type: '',
                      page: 1,
                    );
                  },
                )
              : null,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _controller.loadFinances(
            description: _descriptionController.text,
            type: value,
            page: 1,
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (_controller.isLoading && _controller.finances.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.finances.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No finances found',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _controller.finances.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final finance = _controller.finances[index];
        final typeLabel = finance.type ?? 'Finance';
        return Card(
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                typeLabel.isNotEmpty ? typeLabel[0].toUpperCase() : '#',
              ),
            ),
            title: Text(typeLabel.isNotEmpty ? typeLabel : 'Finance'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (finance.description != null && finance.description!.isNotEmpty)
                  Text(finance.description!),
                if (finance.amount != null) Text('Amount: ${_formatAmount(finance.amount)}'),
                if (finance.createdAt != null)
                  Text('Created: ${_formatDate(finance.createdAt)}'),
                if (finance.reference != null && finance.reference!.isNotEmpty)
                  Text('Reference: ${finance.reference}'),
                if (finance.status != null && finance.status!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildStatusBadge(context, finance.status!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPagination(BuildContext context) {
    final meta = _controller.meta;
    if (meta == null) {
      return const SizedBox.shrink();
    }

    final canGoBack = meta.currentPage > 1;
    final canGoForward = meta.currentPage < meta.lastPage;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Page ${meta.currentPage} of ${meta.lastPage} · ${meta.total} total',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            onPressed: canGoBack && !_controller.isLoading
                ? () => _controller.loadFinances(
                      description: _descriptionController.text,
                      type: _typeController.text,
                      page: meta.currentPage - 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: canGoForward && !_controller.isLoading
                ? () => _controller.loadFinances(
                      description: _descriptionController.text,
                      type: _typeController.text,
                      page: meta.currentPage + 1,
                    )
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final label = _formatStatusLabel(status);
    final color = _statusColor(context, status);
    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      visualDensity: VisualDensity.compact,
    );
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
      case 'paid':
        return Colors.green.shade600;
      case 'pending':
      case 'processing':
        return Colors.orange.shade700;
      case 'failed':
      case 'rejected':
        return Colors.red.shade600;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _formatStatusLabel(String status) {
    if (status.trim().isEmpty) {
      return 'Unknown';
    }
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '—';
    }
    return value.toLocal().toString();
  }

  String _formatAmount(double? value) {
    if (value == null) {
      return '—';
    }
    return '\$${value.toStringAsFixed(2)}';
  }

  Widget _buildErrorBanner(String message) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
        title: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
      ),
    );
  }
}
