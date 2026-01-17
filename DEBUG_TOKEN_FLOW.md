/// Debug Checklist for Token Storage Issue
/// 
/// Expected Flow:
/// 1. User login dengan email/password
/// 2. Server return response dengan token
/// 3. AuthRepositoryImpl.login() extract token
/// 4. SaveToSharedPreferences dengan key 'auth_token'
/// 5. AuthInterceptor read token saat API request
/// 6. Add 'Authorization: Bearer <token>' header
/// 7. Server accept request
/// 
/// Debug Logs to Check:
/// 
/// STEP 1: Login
/// 🔵 [AUTH LOGIN] Attempting login with email: imraniswahyudi@gmail.com
/// 🟢 [API REQUEST] POST /auth/login
/// 🟢 [API RESPONSE] 200 /auth/login
/// 
/// STEP 2: Token Extract & Save
/// 🔵 [AUTH REPO] login() called
/// 🟢 [AUTH REPO] Token extracted: eyJhbGc... (200 chars)
/// 💾 [AUTH REPO] Token saved to SharedPreferences: SUCCESS
/// 💾 [AUTH REPO] Verify read: eyJhbGc...
/// 
/// STEP 3: Navigate to Customers
/// 🔵 [CUSTOMER] fetchCustomers - page: 1
/// 🔵 [API REQUEST] GET /customers
/// 
/// STEP 4: AuthInterceptor Add Header
/// 📦 [AUTH INTERCEPTOR] Got fresh SharedPreferences
/// 🔑 [AUTH INTERCEPTOR] PATH: /customers
/// 🔑 [AUTH INTERCEPTOR] Token in storage: YES (200 chars)
/// ✅ [AUTH INTERCEPTOR] Authorization header set: Bearer eyJhbGc...
/// 🔑 [AUTH INTERCEPTOR] Request headers: {Authorization: Bearer eyJhbGc...}
/// 
/// STEP 5: Server Response
/// 🟢 [API RESPONSE] 200 /customers
/// 🟢 [CUSTOMER] Response: {data: [...], meta: {...}, links: {...}}
/// 
/// If you see:
/// ❌ 🔑 [AUTH INTERCEPTOR] No token found
/// → Token not saved or SharedPreferences not available
/// → Check step 2 logs
/// 
/// If you see:
/// ❌ 🔴 [API ERROR] 404 /customers
/// → Token not in header (check step 4)
/// → Or server doesn't have /customers endpoint
///
