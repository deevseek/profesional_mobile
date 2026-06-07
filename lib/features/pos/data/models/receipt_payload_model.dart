import 'package:profesionalservis_mobile/features/transaction/data/models/transaction_model.dart';
import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

class ReceiptPayloadModel {
  const ReceiptPayloadModel({
    required this.transaction,
    required this.store,
  });

  final TransactionModel transaction;
  final StoreReceiptModel store;

  factory ReceiptPayloadModel.fromJson(Map<String, dynamic> json) {
    final data = unwrapDataMap(json);
    final transactionMap = parseMap(data['transaction']);
    final storeMap = parseMap(data['store']);

    if (transactionMap.isEmpty) {
      throw const FormatException('Payload struk tidak memiliki data transaksi.');
    }

    return ReceiptPayloadModel(
      transaction: TransactionModel.fromJson(transactionMap),
      store: StoreReceiptModel.fromJson(storeMap),
    );
  }
}

class StoreReceiptModel {
  const StoreReceiptModel({
    required this.name,
    required this.address,
    required this.phone,
    required this.bankAccountNumber,
    required this.bankAccountNumbers,
    required this.npwpNumber,
    required this.hours,
    required this.logo,
  });

  final String name;
  final String address;
  final String phone;
  final String bankAccountNumber;
  final List<String> bankAccountNumbers;
  final String npwpNumber;
  final String hours;
  final String logo;

  factory StoreReceiptModel.fromJson(Map<String, dynamic> json) {
    final bankAccountNumber = parseString(
      json['bank_account_number'] ?? json['bankAccountNumber'] ?? json['bank_account'] ?? json['rekening'],
    );
    final bankAccountNumbers = _parseBankAccountNumbers(json['bank_account_numbers'] ?? json['bankAccountNumbers']);

    return StoreReceiptModel(
      name: parseString(json['name'] ?? json['store_name'], fallback: 'PROFESIONAL SERVIS'),
      address: parseString(json['address'] ?? json['store_address'], fallback: '-'),
      phone: parseString(json['phone'] ?? json['store_phone'], fallback: '-'),
      bankAccountNumber: bankAccountNumber,
      bankAccountNumbers: bankAccountNumbers.isEmpty && bankAccountNumber.isNotEmpty
          ? <String>[bankAccountNumber]
          : bankAccountNumbers,
      npwpNumber: parseString(json['npwp_number'] ?? json['npwp'] ?? json['store_npwp']),
      hours: parseString(json['hours'] ?? json['store_hours']),
      logo: parseString(json['logo'] ?? json['store_logo'] ?? json['store_logo_path']),
    );
  }

  static List<String> _parseBankAccountNumbers(dynamic value) {
    if (value is List) {
      return value
          .map((entry) {
            if (entry is Map) {
              return parseString(
                entry['number'] ?? entry['account_number'] ?? entry['bank_account_number'] ?? entry['value'],
              );
            }
            return parseString(entry);
          })
          .where((entry) => entry.isNotEmpty)
          .toList(growable: false);
    }

    final text = parseString(value);
    if (text.isEmpty) return const <String>[];
    return text
        .split(RegExp(r'[\n,;]+'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
  }
}
