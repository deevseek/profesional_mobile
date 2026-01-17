# Auth API Debugging Guide

## Perubahan Yang Telah Dilakukan

### 1. **Improved Login Response Parsing**
- ✅ Support multiple token key formats:
  - `token`
  - `access_token`
  - `auth_token`
  - `jwt`
  - `data.token`

- ✅ Support multiple user key formats:
  - `user`
  - `profile`
  - `data.user`
  - `data` (entire data object)

### 2. **Enhanced Error Logging**
Setiap login attempt sekarang mencatat:
- 🔵 Request details (email)
- 🟢 Response data struktur
- 🔴 Error details jika gagal

### 3. **Endpoint Standardization**
- ✅ `auth/login` (tanpa leading slash)
- ✅ `auth/me` (tanpa leading slash)
- ✅ `auth/logout` (tanpa leading slash)

## Debugging Steps

### Step 1: Check Console Logs Saat Login
Buka DevTools/Console dan lihat logs:
- 🔵 Logs biru = request sedang dikirim
- 🟢 Logs hijau = response berhasil diterima
- 🔴 Logs merah = ada error

### Step 2: Verify API Response Format
Logs akan menampilkan struktur response actual:
```
🟢 [AUTH LOGIN] Response received: {data: {...}}
```

Pastikan response mengandung:
1. Token (dalam salah satu key format di atas)
2. User data (dalam salah satu key format di atas)

### Step 3: Check Network Tab (Browser DevTools)
Lihat POST request ke `/auth/login`:
- ✅ Status code harus 200 atau 201
- ✅ Response body harus berisi token dan user data

## Possible Issues & Solutions

### Issue 1: "Resource not found" (404)
**Penyebab**: Endpoint tidak ada atau typo
**Solusi**: Check server logs dan pastikan endpoint `/api/v1/auth/login` tersedia

### Issue 2: "Authentication token missing from server response"
**Penyebab**: Response tidak mengandung token
**Solusi**: 
1. Check response format dari server
2. Lihat console logs untuk response structure
3. Update token extraction logic jika format berbeda

### Issue 3: "User data missing from server response"
**Penyebab**: Response tidak mengandung user info
**Solusi**:
1. Check response format
2. Update user extraction logic

### Issue 4: Network Connection Error
**Penyebab**: Server tidak reachable
**Solusi**:
1. Verify API baseUrl: `https://sciencecomputer.profesionalservis.my.id/api/v1`
2. Test connection dengan Postman/curl
3. Check SSL certificate jika https

## Testing Dengan Postman

```
Method: POST
URL: https://sciencecomputer.profesionalservis.my.id/api/v1/auth/login
Headers: 
  - Content-Type: application/json
Body (raw JSON):
{
  "email": "test@example.com",
  "password": "password123"
}
```

Expected Response (example):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "test@example.com"
  }
}
```

## How to Read Logs

### Successful Login
```
🔵 [AUTH LOGIN] Attempting login with email: user@example.com
🟢 [AUTH LOGIN] Response received: {token: "xyz...", user: {id: 1, name: "John"}}
🟢 [AUTH LOGIN] Token: xyz... User: 1
```

### Failed Login
```
🔵 [AUTH LOGIN] Attempting login with email: user@example.com
🔴 [AUTH LOGIN DIO ERROR] Response status: 401
🔴 [AUTH LOGIN DIO ERROR] Response: {message: "Invalid credentials"}
```

### Network Error
```
🔵 [AUTH LOGIN] Attempting login with email: user@example.com
🔴 [AUTH LOGIN DIO ERROR] Connection timeout
```

## Token Storage

Token disimpan di SharedPreferences dengan key: `auth_token`

Cek apakah token tersimpan:
- ✅ Setelah successful login, token harus tersimpan
- ✅ Subsequent requests akan auto attach token di header: `Authorization: Bearer {token}`

## Next Steps Jika Masih Gagal

1. **Test API dengan Postman terlebih dahulu**
   - Pastikan API endpoint bekerja dengan benar
   - Check response format

2. **Update response parsing di `auth_remote_datasource.dart`**
   - Sesuaikan dengan format response yang actual

3. **Check server logs**
   - Lihat apa yang diterima server
   - Check apakah ada error di server side
