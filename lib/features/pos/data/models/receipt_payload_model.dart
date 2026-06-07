import 'package:profesionalservis_mobile/features/transaction/data/models/transaction_model.dart';
import 'package:profesionalservis_mobile/shared/utils/json_parsers.dart';

class ReceiptPayloadModel {
  const ReceiptPayloadModel({
    required this.transaction,
    required this.store,
    required this.warrantyTermLines,
    required this.paymentMethodLabel,
  });

  final TransactionModel transaction;
  final ReceiptStoreModel store;
  final List<String> warrantyTermLines;
  final String paymentMethodLabel;

  factory ReceiptPayloadModel.fromJson(Map<String, dynamic> json) {
    final unwrapped = unwrapDataMap(json);
    final receiptMap = parseMap(unwrapped['receipt']);
    final data = receiptMap.isEmpty ? unwrapped : receiptMap;
    final transactionMap = parseMap(data['transaction']);
    final storeMap = parseMap(data['store']);

    if (transactionMap.isEmpty) {
      throw const FormatException('Payload struk tidak memiliki data transaksi.');
    }

    final transaction = TransactionModel.fromJson(transactionMap);
    final paymentMethodLabel = parseString(
      data['payment_method_label'] ?? data['paymentMethodLabel'] ?? data['payment_label'],
    );

    return ReceiptPayloadModel(
      transaction: transaction,
      store: ReceiptStoreModel.fromJson(storeMap),
      warrantyTermLines: _parseStringList(
        data['warranty_term_lines'] ?? data['warrantyTermLines'] ?? data['warranty_terms'] ?? data['warranty'],
      ),
      paymentMethodLabel: paymentMethodLabel.isEmpty ? _fallbackPaymentMethodLabel(transaction.paymentMethod) : paymentMethodLabel,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map(parseString).where((entry) => entry.isNotEmpty).toList(growable: false);
    }
    final text = parseString(value);
    if (text.isEmpty) return const <String>[];
    return text
        .split(RegExp(r'[\n]+'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
  }

  static String _fallbackPaymentMethodLabel(String value) {
    final normalized = value.trim().replaceAll('-', ' ');
    return normalized.isEmpty ? '-' : normalized.toUpperCase();
  }
}

class ReceiptStoreModel {
  const ReceiptStoreModel({
    required this.name,
    required this.address,
    required this.phone,
    required this.bankAccountNumber,
    required this.bankAccountNumbers,
    required this.npwpNumber,
    required this.hours,
    required this.logo,
    required this.logoUrl,
  });

  final String name;
  final String address;
  final String phone;
  final String bankAccountNumber;
  final List<String> bankAccountNumbers;
  final String npwpNumber;
  final String hours;
  final String logo;
  final String logoUrl;

  String get effectiveLogoUrl => logoUrl.trim().isNotEmpty ? logoUrl.trim() : logo.trim();

  factory ReceiptStoreModel.fromJson(Map<String, dynamic> json) {
    final bankAccountNumber = parseString(
      json['bank_account_number'] ?? json['bankAccountNumber'] ?? json['bank_account'] ?? json['rekening'],
    );
    final bankAccountNumbers = _parseBankAccountNumbers(json['bank_account_numbers'] ?? json['bankAccountNumbers']);

    final logo = parseString(json['logo'] ?? json['store_logo'] ?? json['store_logo_path']);
    return ReceiptStoreModel(
      name: parseString(json['name'] ?? json['store_name'], fallback: 'PROFESIONAL SERVIS'),
      address: parseString(json['address'] ?? json['store_address'], fallback: '-'),
      phone: parseString(json['phone'] ?? json['store_phone'], fallback: '-'),
      bankAccountNumber: bankAccountNumber,
      bankAccountNumbers: bankAccountNumbers.isEmpty && bankAccountNumber.isNotEmpty
          ? <String>[bankAccountNumber]
          : bankAccountNumbers,
      npwpNumber: parseString(json['npwp_number'] ?? json['npwp'] ?? json['store_npwp']),
      hours: parseString(json['hours'] ?? json['store_hours']),
      logo: logo,
      logoUrl: parseString(json['logo_url'] ?? json['logoUrl'] ?? json['store_logo_url'], fallback: logo),
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

typedef StoreReceiptModel = ReceiptStoreModel;
