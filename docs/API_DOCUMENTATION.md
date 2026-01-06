# API Documentation

## Base URL
```
Production: https://your-domain.com/api
Development: http://localhost:3001/api
```

## Authentication
- **Admin endpoints** require admin wallet verification
- **Public endpoints** are accessible without authentication
- **Rate limiting** applies to all endpoints

## Public Endpoints

### Health Check
```http
GET /api/health
```

**Response:**
```json
{
  "status": "OK",
  "timestamp": "2026-01-15T10:30:00.000Z"
}
```

### Get User by Wallet
```http
GET /api/user/:wallet
```

**Parameters:**
- `wallet` (string): Ethereum wallet address (0x...)

**Response:**
```json
{
  "user": {
    "id": 1,
    "wallet_address": "0x1234...",
    "full_name": "John Doe",
    "role": "investigator",
    "department": "Police",
    "jurisdiction": "City",
    "badge_number": "12345",
    "account_type": "real",
    "created_at": "2026-01-15T10:30:00.000Z",
    "is_active": true
  }
}
```

**Error Response:**
```json
{
  "error": "Invalid wallet address"
}
```

## Admin Endpoints

All admin endpoints require `adminWallet` in request body for verification.

### Create Regular User
```http
POST /api/admin/create-user
```

**Request Body:**
```json
{
  "adminWallet": "0xadmin...",
  "userData": {
    "walletAddress": "0x1234...",
    "fullName": "John Doe",
    "role": "investigator",
    "department": "Police",
    "jurisdiction": "City",
    "badgeNumber": "12345"
  }
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "wallet_address": "0x1234...",
    "full_name": "John Doe",
    "role": "investigator",
    "created_at": "2026-01-15T10:30:00.000Z"
  }
}
```

**Error Responses:**
```json
// Unauthorized
{
  "error": "Unauthorized: Only active administrators can create user accounts"
}

// Invalid role
{
  "error": "Invalid role specified for regular user"
}

// Wallet exists
{
  "error": "Wallet address already registered"
}
```

### Create Admin User
```http
POST /api/admin/create-admin
```

**Request Body:**
```json
{
  "adminWallet": "0xadmin...",
  "adminData": {
    "walletAddress": "0x5678...",
    "fullName": "Jane Admin"
  }
}
```

**Response:**
```json
{
  "success": true,
  "admin": {
    "id": 2,
    "wallet_address": "0x5678...",
    "full_name": "Jane Admin",
    "role": "admin",
    "created_at": "2026-01-15T10:30:00.000Z"
  }
}
```

**Error Responses:**
```json
// Admin limit reached
{
  "error": "Maximum admin limit (10) reached"
}
```

### Delete User (Soft Delete)
```http
POST /api/admin/delete-user
```

**Request Body:**
```json
{
  "adminWallet": "0xadmin...",
  "targetWallet": "0x1234..."
}
```

**Response:**
```json
{
  "success": true
}
```

**Error Responses:**
```json
// Self-deletion attempt
{
  "error": "Administrators cannot delete their own account"
}

// User not found
{
  "error": "Target user not found"
}
```

### Get All Users
```http
POST /api/admin/users
```

**Request Body:**
```json
{
  "adminWallet": "0xadmin..."
}
```

**Response:**
```json
{
  "users": [
    {
      "id": 1,
      "wallet_address": "0x1234...",
      "full_name": "John Doe",
      "role": "investigator",
      "account_type": "real",
      "is_active": true,
      "created_at": "2026-01-15T10:30:00.000Z"
    }
  ]
}
```

## User Roles

### Available Roles
```json
[
  "public_viewer",
  "investigator", 
  "forensic_analyst",
  "legal_professional",
  "court_official",
  "evidence_manager",
  "auditor",
  "admin"
]
```

### Role Permissions
- **public_viewer**: View public cases
- **investigator**: Create and manage investigations
- **forensic_analyst**: Analyze evidence
- **legal_professional**: Legal review and documentation
- **court_official**: Court proceedings management
- **evidence_manager**: Evidence lifecycle management
- **auditor**: System auditing and compliance
- **admin**: Full system access and user management

## Rate Limiting

### Default Limits
- **General endpoints**: 100 requests per 15 minutes
- **Admin endpoints**: 50 requests per 15 minutes

### Rate Limit Headers
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
X-RateLimit-Reset: 1642248000
```

### Rate Limit Exceeded
```json
{
  "error": "Too many requests, please try again later"
}
```

## Error Codes

### HTTP Status Codes
- `200` - Success
- `400` - Bad Request (validation error)
- `401` - Unauthorized
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `409` - Conflict (duplicate resource)
- `429` - Too Many Requests (rate limited)
- `500` - Internal Server Error

### Error Response Format
```json
{
  "error": "Error message description",
  "code": "ERROR_CODE",
  "timestamp": "2026-01-15T10:30:00.000Z"
}
```

## Request/Response Examples

### cURL Examples

**Get User:**
```bash
curl -X GET "https://your-domain.com/api/user/0x1234..." \
  -H "Content-Type: application/json"
```

**Create User (Admin):**
```bash
curl -X POST "https://your-domain.com/api/admin/create-user" \
  -H "Content-Type: application/json" \
  -d '{
    "adminWallet": "0xadmin...",
    "userData": {
      "walletAddress": "0x1234...",
      "fullName": "John Doe",
      "role": "investigator"
    }
  }'
```

### JavaScript Examples

**Fetch User:**
```javascript
const response = await fetch(`/api/user/${walletAddress}`);
const data = await response.json();
```

**Create User:**
```javascript
const response = await fetch('/api/admin/create-user', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    adminWallet: adminWallet,
    userData: {
      walletAddress: newWallet,
      fullName: fullName,
      role: selectedRole
    }
  })
});
```

## Security Considerations

- All admin operations are logged
- Wallet addresses are validated
- Input sanitization is performed
- Rate limiting prevents abuse
- Soft delete preserves audit trail
- Admin self-deletion is prevented