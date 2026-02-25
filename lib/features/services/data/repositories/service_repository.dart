import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profesionalservis_mobile/features/services/data/models/service_model.dart';
import 'package:profesionalservis_mobile/features/services/data/models/service_tracking_model.dart';
import 'package:profesionalservis_mobile/features/transaction/data/models/transaction_model.dart';
import 'package:profesionalservis_mobile/features/services/domain/service_payloads.dart';
import 'package:profesionalservis_mobile/network/dio_client.dart';
import 'package:profesionalservis_mobile/shared/models/paginated_response.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository(ref.watch(dioProvider));
});

class ServiceReceiptResponse {
  const ServiceReceiptResponse({
    required this.service,
    required this.store,
    this.tracking = const ServiceTrackingModel(),
  });

  final ServiceModel service;
  final Map<String, dynamic> store;
  final ServiceTrackingModel tracking;
}

class ServiceInvoiceResponse {
  const ServiceInvoiceResponse({
    required this.service,
    required this.transaction,
    required this.store,
  });

  final ServiceModel service;
  final TransactionModel transaction;
  final Map<String, dynamic> store;
}

class ServiceWhatsAppNotificationResponse {
  const ServiceWhatsAppNotificationResponse({
    required this.serviceId,
    required this.template,
    required this.recipientPhone,
    required this.message,
    required this.link,
    required this.webLink,
  });

  final String serviceId;
  final String template;
  final String recipientPhone;
  final String message;
  final String link;
  final String webLink;
}

class ServiceRepository {
  const ServiceRepository(this._dio);

  final Dio _dio;

  Future<PaginatedResponse<ServiceModel>> getServices({
    required int page,
    String? search,
    String? status,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/services',
      queryParameters: {
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    final body = response.data;
    if (body == null) {
      throw const FormatException('Data services kosong.');
    }

    return PaginatedResponse<ServiceModel>.fromJson(body, ServiceModel.fromJson);
  }

  Future<ServiceModel> createService(CreateServicePayload payload) async {
    final response = await _dio.post<Map<String, dynamic>>('/services', data: payload.toJson());
    return _unwrapServiceData(response.data);
  }

  Future<ServiceModel> getServiceDetail(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/services/$id');
    return _unwrapServiceData(response.data);
  }

  Future<ServiceReceiptResponse> getServiceReceipt(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/services/$id/receipt');
    final data = _unwrapNestedData(response.data);

    final serviceRaw = data['service'];
    if (serviceRaw is! Map<String, dynamic>) {
      throw const FormatException('Format receipt service tidak valid.');
    }

    final tracking = _parseTrackingPayload(data['tracking']);

    return ServiceReceiptResponse(
      service: ServiceModel.fromJson(serviceRaw),
      store: {
        ...(data['store'] is Map<String, dynamic> ? data['store'] as Map<String, dynamic> : const <String, dynamic>{}),
        if (tracking.progressUrl.isNotEmpty) 'tracking_url': tracking.progressUrl,
        if (tracking.qrUrl.isNotEmpty) 'tracking_qr_url': tracking.qrUrl,
      },
      tracking: tracking,
    );
  }

  Future<ServiceInvoiceResponse> getServiceInvoice(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/services/$id/invoice');
    final data = _unwrapNestedData(response.data);

    final serviceRaw = data['service'];
    final transactionRaw = data['transaction'];
    if (serviceRaw is! Map<String, dynamic> || transactionRaw is! Map<String, dynamic>) {
      throw const FormatException('Format invoice service tidak valid.');
    }

    return ServiceInvoiceResponse(
      service: ServiceModel.fromJson(serviceRaw),
      transaction: TransactionModel.fromJson(transactionRaw),
      store: data['store'] is Map<String, dynamic> ? data['store'] as Map<String, dynamic> : const <String, dynamic>{},
    );
  }

  Future<ServiceModel> updateService(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Map<String, dynamic>>('/services/$id', data: payload);
    return _unwrapServiceData(response.data);
  }

  Future<ServiceModel> updateServiceStatus({
    required String id,
    required String status,
  }) async {
    final payload = {'status': status};
    final endpoints = <String>[
      '/services/$id/workflow-status',
      '/services/$id/status',
    ];

    DioException? lastNotFound;

    for (final endpoint in endpoints) {
      try {
        final response = await _dio.patch<Map<String, dynamic>>(endpoint, data: payload);
        return _unwrapServiceData(response.data);
      } on DioException catch (error) {
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          lastNotFound = error;
          continue;
        }
        rethrow;
      }
    }

    if (lastNotFound != null) {
      rethrow;
    }

    throw const FormatException('Endpoint workflow status service tidak ditemukan.');
  }

  Future<ServiceWhatsAppNotificationResponse> notifyWhatsApp({
    required String id,
    String? template,
    String? message,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/services/$id/notify-whatsapp',
      data: {
        if (template != null && template.isNotEmpty) 'template': template,
        if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
      },
    );

    final body = response.data;
    if (body == null) {
      throw const FormatException('Response notifikasi WhatsApp tidak valid.');
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Format response notifikasi WhatsApp tidak valid.');
    }

    final notification = data['notification'];
    if (notification is! Map<String, dynamic>) {
      throw const FormatException('Data notification WhatsApp tidak ditemukan.');
    }

    return ServiceWhatsAppNotificationResponse(
      serviceId: _asString(data['service_id']),
      template: _asString(data['template']),
      recipientPhone: _asString(data['recipient_phone']),
      message: _asString(notification['message']),
      link: _asString(notification['link']),
      webLink: _asString(notification['web_link']),
    );
  }

  Future<ServiceTrackingModel> getServiceTracking(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/services/$id/tracking');
    final data = _unwrapNestedData(response.data);

    final tracking = _parseTrackingPayload(data['tracking']);
    if (tracking.progressUrl.isNotEmpty || tracking.qrUrl.isNotEmpty) {
      return tracking;
    }

    final serviceRaw = data['service'];
    if (serviceRaw is Map<String, dynamic>) {
      final fallback = _parseTrackingPayload(serviceRaw['tracking']);
      if (fallback.progressUrl.isNotEmpty || fallback.qrUrl.isNotEmpty) {
        return fallback;
      }
    }

    throw const FormatException('Format tracking service tidak valid.');
  }

  Future<void> deleteService(String id) async {
    await _dio.delete<void>('/services/$id');
  }

  Future<ServiceModel> addServiceItem(String serviceId, AddServiceItemPayload payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/services/$serviceId/items',
      data: payload.toJson(),
    );
    return _unwrapServiceData(response.data);
  }

  Future<ServiceModel> deleteServiceItem(String serviceId, String itemId) async {
    final response = await _dio.delete<Map<String, dynamic>>('/services/$serviceId/items/$itemId');
    return _unwrapServiceData(response.data);
  }

  ServiceModel _unwrapServiceData(Map<String, dynamic>? body) {
    if (body == null) {
      throw const FormatException('Response tidak valid.');
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Format response service tidak valid.');
    }
    return ServiceModel.fromJson(data);
  }

  Map<String, dynamic> _unwrapNestedData(Map<String, dynamic>? body) {
    if (body == null) {
      throw const FormatException('Response tidak valid.');
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    return body;
  }

  ServiceTrackingModel _parseTrackingPayload(dynamic value) {
    if (value is Map<String, dynamic>) {
      return ServiceTrackingModel.fromJson(value);
    }

    return const ServiceTrackingModel();
  }
}

String _asString(dynamic value) => value?.toString() ?? '';
