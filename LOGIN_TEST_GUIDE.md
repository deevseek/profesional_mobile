/// Login Test Guide
/// 
/// Credentials for testing:
/// Email: imraniswahyudi@gmail.com
/// Password: 12345678
/// 
/// API Flow:
/// 1. LoginPage → enters credentials
/// 2. AuthController.login() → calls AuthRepository.login()
/// 3. POST /auth/login with email & password
/// 4. Server returns: { "token": "...", "user": {...} }
/// 5. Token saved to SharedPreferences with key "auth_token"
/// 6. User object stored in AuthUser model
/// 7. AuthStatus changed to "authenticated"
/// 8. UI redirects to DashboardPage
/// 
/// Debugging:
/// - Check console for 🔵 [AUTH LOGIN] logs
/// - Look for 🟢 [AUTH LOGIN] Response
/// - If error, check 🔴 [AUTH LOGIN ERROR]
/// 
/// Expected Debug Output:
/// 🔵 [AUTH LOGIN] Attempting login with email: imraniswahyudi@gmail.com
/// 🟢 [API REQUEST] POST /auth/login
/// 🟢 [API RESPONSE] 200 /auth/login
/// 🟢 [AUTH LOGIN] Response received: {...}
/// 🟢 [AUTH LOGIN] Token: eyJhbGc... User: <user_id>
/// ✅ [INIT] User authenticated: <user_name>
/// 
/// Then navigate to Customers:
/// 🟢 [CUSTOMER] fetchCustomers - page: 1, perPage: 15
/// 🟢 [API REQUEST] GET /customers
/// 🟢 [API RESPONSE] 200 /customers
/// 🟢 [CUSTOMER] Response: {"data": [...], "meta": {...}, "links": {...}}
/// 
/// Common Issues & Solutions:
/// 
/// Issue 1: "Invalid email or password"
/// - Wrong credentials
/// - Solution: Verify email & password are correct
/// 
/// Issue 2: "Unauthorized - Please login again"
/// - Token expired or invalid
/// - Solution: Login again
/// 
/// Issue 3: "Authentication required" on Customers page
/// - Token not sent with request
/// - Solution: Check AuthInterceptor is adding Authorization header
/// 
/// Issue 4: "Connection error"
/// - Server not reachable
/// - Solution: Check server URL: https://sciencecomputer.profesionalservis.my.id/api/v1
/// - Check internet connection
///
