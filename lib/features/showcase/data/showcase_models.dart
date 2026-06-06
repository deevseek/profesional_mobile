import 'package:flutter/material.dart';

class ShowcaseKpi {
  const ShowcaseKpi(this.title, this.value, this.icon, this.color, this.delta);
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String delta;
}

class ServiceOrder {
  const ServiceOrder({required this.number, required this.customer, required this.phone, required this.device, required this.issue, required this.dateIn, required this.eta, required this.status, required this.color});
  final String number;
  final String customer;
  final String phone;
  final String device;
  final String issue;
  final String dateIn;
  final String eta;
  final String status;
  final Color color;
}

class ProductShowcase {
  const ProductShowcase({required this.name, required this.sku, required this.category, required this.stock, required this.buyPrice, required this.sellPrice});
  final String name;
  final String sku;
  final String category;
  final int stock;
  final String buyPrice;
  final String sellPrice;
}

class CustomerShowcase {
  const CustomerShowcase({required this.name, required this.phone, required this.email, required this.totalService, required this.totalSpend, required this.receivable});
  final String name;
  final String phone;
  final String email;
  final int totalService;
  final String totalSpend;
  final String receivable;
}

class ActivityItem {
  const ActivityItem(this.title, this.subtitle, this.icon, this.color);
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
