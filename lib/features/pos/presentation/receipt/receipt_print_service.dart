import 'package:profesionalservis_mobile/features/settings/data/models/store_settings_model.dart';

String receiptMoney(num value) {
  final negative = value < 0;
  final raw = value.abs().round().toString();
  final grouped = raw.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  return '${negative ? '-' : ''}Rp $grouped';
}

String receiptDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/${value.year} $hour:$minute';
}

String receiptDateOnly(DateTime value) => receiptDate(value).split(' ').first;

String storeNameOrFallback(StoreSettingsModel store) {
  final name = store.storeName.trim();
  return name.isEmpty ? 'PROFESIONAL SERVIS' : name;
}

String storeAddressOrFallback(StoreSettingsModel store) {
  final address = store.address.trim();
  return address.isEmpty ? '-' : address;
}

String storePhoneOrFallback(StoreSettingsModel store) {
  final phone = store.phone.trim();
  return phone.isEmpty ? '-' : phone;
}
