# Customers Module - API Documentation Mapping

## Overview
Module customers menggunakan resource `/customers` di API v1 dengan full CRUD operations.

## Implementation Status ✅

### 1. List Customers
**API Documentation:**
```
GET /customers
Query Parameters: per_page (default 15), search
Response: { "data": [...], "links": {...}, "meta": {...} }
```

**Implementation:**
```dart
// File: customer_remote_datasource.dart
Future<CustomerPage> fetchCustomers({
  String? search,
  int page = 1,
  int? perPage
})
```

**Query Parameters Mapping:**
- `search` → mencari di name, email, phone ✅
- `per_page` → pagination size (default 15 di API) ✅
- `page` → current page number ✅

**Response Parsing:**
- `data` array → List<Customer> ✅
- `meta` object → CustomerPaginationMeta ✅
- `links` object → CustomerPaginationLinks ✅

### 2. Get Customer Detail
**API Documentation:**
```
GET /customers/{id}
Response: { "data": {...} }
```

**Implementation:**
```dart
Future<Customer> fetchCustomer(String id)
```

**Response Parsing:**
- Extracts `data` object and parses as Customer ✅
- Falls back to root object jika `data` tidak ada ✅

### 3. Create Customer
**API Documentation:**
```
POST /customers
Request Body: { "name", "email", "phone", "address" }
Response: { "data": {...} } (status 201)
```

**Implementation:**
```dart
Future<Customer> createCustomer(Customer customer)
```

**Payload Generation:**
```dart
Map<String, dynamic> toPayload() {
  // Generates:
  // - name (required) ✅
  // - email (optional) ✅
  // - phone (optional) ✅
  // - address (optional) ✅
}
```

**Response Parsing:**
- Extracts `data` object and parses as Customer ✅
- Fallback to root object jika needed ✅

### 4. Update Customer
**API Documentation:**
```
PATCH /customers/{id}
Request Body: Partial fields to update
Response: { "data": {...} } (status 200)
```

**Implementation:**
```dart
Future<Customer> updateCustomer(String id, Customer customer)
```

**Payload Generation:**
- Only includes non-null fields ✅
- Supports partial updates ✅

**Response Parsing:**
- Extracts updated `data` object ✅

### 5. Delete Customer
**API Documentation:**
```
DELETE /customers/{id}
Response: { "message": "Deleted." } (status 200)
```

**Implementation:**
```dart
Future<void> deleteCustomer(String id)
```

**Response Handling:**
- Expects any 2xx status as success ✅

## Data Model Mapping

### Customer Fields
```dart
class Customer {
  String id;           // dari json['id']
  String name;         // required
  String? email;       // optional, harus unik di API
  String? phone;       // optional
  String? address;     // optional
  DateTime? createdAt; // dari json['created_at']
  DateTime? updatedAt; // dari json['updated_at']
}
```

**JSON Parsing Strategy:**
- `id`: Direct from `json['id']`
- `name`: Flexible keys untuk compatibility
- `email`, `phone`, `address`: Optional, string conversion
- `createdAt`, `updatedAt`: ISO8601 date parsing dengan timezone handling

### Pagination Meta Fields
```dart
class CustomerPaginationMeta {
  int currentPage;  // dari json['current_page']
  int lastPage;     // dari json['last_page']
  int perPage;      // dari json['per_page']
  int total;        // dari json['total']
  int? from;        // dari json['from']
  int? to;          // dari json['to']
}
```

### Pagination Links
```dart
class CustomerPaginationLinks {
  String? first;  // dari json['first']
  String? last;   // dari json['last']
  String? prev;   // dari json['prev']
  String? next;   // dari json['next']
}
```

## Request/Response Examples

### Example 1: List Customers
```
REQUEST:
GET /api/v1/customers?per_page=20&search=andi
Headers:
  Authorization: Bearer {token}
  Content-Type: application/json

RESPONSE (200):
{
  "data": [
    {
      "id": 1,
      "name": "Andi",
      "email": "andi@example.com",
      "phone": "08123456789",
      "address": "Jakarta",
      "created_at": "2026-03-10T09:00:00Z",
      "updated_at": "2026-03-10T09:00:00Z"
    }
  ],
  "links": {
    "first": "...",
    "last": "...",
    "prev": null,
    "next": null
  },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 1,
    "path": "...",
    "per_page": 20,
    "to": 1,
    "total": 1
  }
}
```

### Example 2: Create Customer
```
REQUEST:
POST /api/v1/customers
Headers:
  Authorization: Bearer {token}
  Content-Type: application/json
Body:
{
  "name": "Andi",
  "email": "andi@example.com",
  "phone": "08123456789",
  "address": "Jakarta"
}

RESPONSE (201):
{
  "data": {
    "id": 1,
    "name": "Andi",
    "email": "andi@example.com",
    "phone": "08123456789",
    "address": "Jakarta",
    "created_at": "2026-03-10T09:00:00Z",
    "updated_at": "2026-03-10T09:00:00Z"
  }
}
```

### Example 3: Update Customer
```
REQUEST:
PATCH /api/v1/customers/1
Headers:
  Authorization: Bearer {token}
  Content-Type: application/json
Body (partial update):
{
  "phone": "08111111111",
  "address": "Bandung"
}

RESPONSE (200):
{
  "data": {
    "id": 1,
    "name": "Andi",
    "email": "andi@example.com",
    "phone": "08111111111",
    "address": "Bandung",
    "created_at": "2026-03-10T09:00:00Z",
    "updated_at": "2026-03-10T09:10:00Z"
  }
}
```

## Implementation Details

### Error Handling
- 404 Not Found → NotFoundException
- 422 Validation Error → ValidationException dengan field errors
- 500+ Server Error → ApiException
- Network errors → ApiException

### Logging
- Request details: `🔵 [API REQUEST] GET /customers`
- Response success: `🟢 [API RESPONSE] 200 /customers`
- Response error: `🔴 [API ERROR] 404 /customers/999`

### Authentication
- All requests include `Authorization: Bearer {token}` header
- Token dari SharedPreferences dengan key `auth_token`
- Auto-attached via AuthInterceptor

### Pagination
- Default `per_page` dari API: 15
- Support custom `per_page` via query parameter
- `page` parameter untuk navigasi (1-based)

## Testing Checklist

- [ ] Load customers list dengan default pagination
- [ ] Load customers list dengan custom per_page
- [ ] Search customers dengan query parameter
- [ ] Load customer detail by ID
- [ ] Create new customer dengan required fields (name)
- [ ] Create customer dengan optional fields
- [ ] Update customer dengan partial fields
- [ ] Update customer dengan single field
- [ ] Delete customer
- [ ] Test error cases (404, validation, etc)

## Related Files
- Data: `lib/features/customers/data/customer_remote_datasource.dart`
- Model: `lib/features/customers/domain/customer_model.dart`
- Repository: `lib/features/customers/data/customer_repository_impl.dart`
- Controller: `lib/features/customers/presentation/customer_controller.dart`
- UI: `lib/features/customers/presentation/customer_list_page.dart`
