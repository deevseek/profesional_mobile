import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/showcase/data/showcase_models.dart';
import 'package:profesionalservis_mobile/theme/app_colors.dart';

// TODO: Replace dummy data with API endpoint once dashboard showcase metrics are available from backend.
final showcaseKpisProvider = Provider<List<ShowcaseKpi>>((ref) => const [
      ShowcaseKpi('Penjualan Hari Ini', 'Rp 8,7 jt', Icons.payments_outlined, AppColors.primaryBlue, '+12%'),
      ShowcaseKpi('Servis Aktif', '38', Icons.build_circle_outlined, AppColors.teal, '+6'),
      ShowcaseKpi('Stok Menipis', '14', Icons.inventory_2_outlined, AppColors.warning, 'Cek'),
      ShowcaseKpi('Pendapatan Bulan Ini', 'Rp 126 jt', Icons.trending_up_rounded, AppColors.cyan, '+18%'),
      ShowcaseKpi('Piutang Usaha', 'Rp 11,4 jt', Icons.account_balance_wallet_outlined, AppColors.danger, '7 due'),
      ShowcaseKpi('Laba Bersih', 'Rp 42,8 jt', Icons.ssid_chart_rounded, AppColors.success, '+9%'),
    ]);

// TODO: Replace dummy data with API endpoint /services when full tracking payload is exposed.
final showcaseOrdersProvider = Provider<List<ServiceOrder>>((ref) => const [
      ServiceOrder(number: 'SRV-2406-0018', customer: 'Andi Wijaya', phone: '0812-4432-1188', device: 'iPhone 13 Pro', issue: 'Layar bergaris setelah jatuh', dateIn: 'Hari ini 09:12', eta: 'Selesai 18:00', status: 'Dikerjakan', color: AppColors.primaryBlue),
      ServiceOrder(number: 'SRV-2406-0017', customer: 'Siti Rahma', phone: '0821-7765-9001', device: 'MacBook Air M1', issue: 'Tidak bisa charging', dateIn: 'Hari ini 08:40', eta: 'Besok 12:00', status: 'Diagnosa', color: AppColors.warning),
      ServiceOrder(number: 'SRV-2406-0016', customer: 'CV Bumi Tekno', phone: '0819-3330-2211', device: 'Printer Epson L3210', issue: 'Hasil cetak putus-putus', dateIn: 'Kemarin 15:20', eta: 'Hari ini 16:00', status: 'QC', color: AppColors.teal),
      ServiceOrder(number: 'SRV-2406-0015', customer: 'Rizky Pratama', phone: '0857-1200-4455', device: 'Samsung A54', issue: 'Baterai cepat habis', dateIn: 'Kemarin 11:04', eta: 'Menunggu sparepart', status: 'Menunggu', color: AppColors.cyan),
    ]);

// TODO: Replace dummy data with API endpoint /products plus stock summary.
final showcaseProductsProvider = Provider<List<ProductShowcase>>((ref) => const [
      ProductShowcase(name: 'LCD iPhone 13 Pro OLED', sku: 'SP-IP13P-LCD', category: 'Sparepart', stock: 4, buyPrice: 'Rp 1.850.000', sellPrice: 'Rp 2.350.000'),
      ProductShowcase(name: 'Battery Samsung A54', sku: 'SP-SA54-BAT', category: 'Sparepart', stock: 2, buyPrice: 'Rp 185.000', sellPrice: 'Rp 320.000'),
      ProductShowcase(name: 'Tempered Glass Premium', sku: 'ACC-TG-PRM', category: 'Aksesoris', stock: 86, buyPrice: 'Rp 12.000', sellPrice: 'Rp 35.000'),
      ProductShowcase(name: 'Obeng Precision Set', sku: 'TLS-PRS-24', category: 'Tools', stock: 0, buyPrice: 'Rp 95.000', sellPrice: 'Rp 165.000'),
    ]);

// TODO: Replace dummy data with API endpoint /customers CRM aggregate.
final showcaseCustomersProvider = Provider<List<CustomerShowcase>>((ref) => const [
      CustomerShowcase(name: 'Andi Wijaya', phone: '0812-4432-1188', email: 'andi@email.com', totalService: 8, totalSpend: 'Rp 7,8 jt', receivable: 'Rp 0'),
      CustomerShowcase(name: 'Siti Rahma', phone: '0821-7765-9001', email: 'siti@email.com', totalService: 3, totalSpend: 'Rp 2,1 jt', receivable: 'Rp 450 rb'),
      CustomerShowcase(name: 'CV Bumi Tekno', phone: '0819-3330-2211', email: 'finance@bumitekno.id', totalService: 24, totalSpend: 'Rp 38 jt', receivable: 'Rp 3,2 jt'),
    ]);

final showcaseActivitiesProvider = Provider<List<ActivityItem>>((ref) => const [
      ActivityItem('Pembayaran diterima', 'Invoice POS-2406-091 dibayar QRIS', Icons.check_circle_outline, AppColors.success),
      ActivityItem('Order baru', 'SRV-2406-0018 masuk dari Andi Wijaya', Icons.add_task_rounded, AppColors.primaryBlue),
      ActivityItem('Stok menipis', 'Battery Samsung A54 tersisa 2 pcs', Icons.warning_amber_rounded, AppColors.warning),
      ActivityItem('Piutang jatuh tempo', 'CV Bumi Tekno jatuh tempo hari ini', Icons.event_busy_rounded, AppColors.danger),
    ]);
