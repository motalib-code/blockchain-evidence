# Troubleshooting Guide

## Common Issues and Solutions

### MetaMask Connection Issues

#### Problem: "MetaMask not detected"
**Symptoms:**
- Button shows "Install MetaMask"
- Wallet connection fails

**Solutions:**
1. **Install MetaMask Extension**
   ```bash
   # Visit chrome.google.com/webstore
   # Search for "MetaMask"
   # Click "Add to Chrome"
   ```

2. **Enable MetaMask**
   - Check if extension is enabled
   - Refresh the page
   - Try incognito mode

3. **Browser Compatibility**
   - Use Chrome, Firefox, or Edge
   - Update browser to latest version

#### Problem: "User rejected the request"
**Symptoms:**
- Connection popup appears but fails
- "User denied account authorization"

**Solutions:**
1. **Accept Connection Request**
   - Click "Connect" in MetaMask popup
   - Select correct account
   - Approve the connection

2. **Reset MetaMask Connection**
   ```javascript
   // In browser console
   window.ethereum.request({
     method: "wallet_requestPermissions",
     params: [{ eth_accounts: {} }]
   });
   ```

### Database Connection Issues

#### Problem: "Database connection failed"
**Symptoms:**
- User registration fails
- Data not loading
- API errors

**Solutions:**
1. **Check Environment Variables**
   ```bash
   # Verify .env file
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_KEY=your_anon_key
   ```

2. **Verify Supabase Project**
   - Check project status in Supabase dashboard
   - Verify API keys are correct
   - Ensure project is not paused

3. **Network Issues**
   - Check internet connection
   - Try different network
   - Disable VPN if active

#### Problem: "Row Level Security policy violation"
**Symptoms:**
- Database operations fail
- "insufficient_privilege" errors

**Solutions:**
1. **Update RLS Policies**
   ```sql
   -- In Supabase SQL Editor
   DROP POLICY IF EXISTS "Allow all operations" ON users;
   CREATE POLICY "Allow all operations" ON users FOR ALL USING (true);
   ```

2. **Check Table Permissions**
   - Verify RLS is properly configured
   - Ensure policies allow operations

### User Registration Issues

#### Problem: "Invalid wallet address format"
**Symptoms:**
- Registration form validation fails
- Address format errors

**Solutions:**
1. **Check Wallet Address Format**
   ```javascript
   // Valid format: 0x followed by 40 hex characters
   const validAddress = /^0x[a-fA-F0-9]{40}$/;
   ```

2. **Copy Address from MetaMask**
   - Click account name in MetaMask
   - Copy full address
   - Paste into form

#### Problem: "Administrator role cannot be self-registered"
**Symptoms:**
- Admin role selection fails
- Registration blocked

**Solutions:**
1. **Use Different Role**
   - Select from available roles
   - Contact existing admin for admin role

2. **Admin Account Creation**
   - Only existing admins can create admin accounts
   - Maximum 10 admin accounts allowed

### Login Issues

#### Problem: "Access denied. Administrator privileges required"
**Symptoms:**
- Admin dashboard access blocked
- Insufficient permissions error

**Solutions:**
1. **Verify Admin Status**
   ```javascript
   // Check user data in localStorage
   const userData = localStorage.getItem('evidUser_' + walletAddress);
   console.log(JSON.parse(userData));
   ```

2. **Contact System Administrator**
   - Request admin role assignment
   - Verify account is active

#### Problem: "User not found in database"
**Symptoms:**
- Login fails for existing user
- Account not recognized

**Solutions:**
1. **Check Wallet Address**
   - Ensure using correct MetaMask account
   - Verify address matches registration

2. **Re-register Account**
   - Create new account if needed
   - Contact admin for assistance

### Performance Issues

#### Problem: "Slow loading times"
**Symptoms:**
- Pages load slowly
- API responses delayed

**Solutions:**
1. **Check Network Connection**
   - Test internet speed
   - Try different network
   - Disable browser extensions

2. **Clear Browser Cache**
   ```bash
   # Chrome: Ctrl+Shift+Delete
   # Firefox: Ctrl+Shift+Delete
   # Clear browsing data
   ```

3. **Optimize Database Queries**
   - Check Supabase performance
   - Monitor API response times

### Browser Compatibility Issues

#### Problem: "Features not working in browser"
**Symptoms:**
- JavaScript errors
- UI elements not responding

**Solutions:**
1. **Update Browser**
   - Use latest Chrome, Firefox, or Edge
   - Enable JavaScript
   - Disable ad blockers

2. **Check Console Errors**
   ```bash
   # Open Developer Tools (F12)
   # Check Console tab for errors
   # Look for JavaScript errors
   ```

### Local Development Issues

#### Problem: "npm install fails"
**Symptoms:**
- Dependency installation errors
- Module not found errors

**Solutions:**
1. **Clear npm Cache**
   ```bash
   npm cache clean --force
   rm -rf node_modules
   rm package-lock.json
   npm install
   ```

2. **Check Node.js Version**
   ```bash
   node --version  # Should be v16+
   npm --version   # Should be v8+
   ```

#### Problem: "Port already in use"
**Symptoms:**
- Server won't start
- "EADDRINUSE" error

**Solutions:**
1. **Kill Process on Port**
   ```bash
   # Windows
   netstat -ano | findstr :3001
   taskkill /PID <PID> /F
   
   # Mac/Linux
   lsof -ti:3001 | xargs kill -9
   ```

2. **Use Different Port**
   ```bash
   PORT=3002 npm start
   ```

## Error Codes Reference

### HTTP Status Codes
- **400**: Bad Request - Check request format
- **401**: Unauthorized - Check authentication
- **403**: Forbidden - Insufficient permissions
- **404**: Not Found - Check URL/endpoint
- **409**: Conflict - Resource already exists
- **429**: Too Many Requests - Rate limited
- **500**: Internal Server Error - Server issue

### Custom Error Messages
- **"Invalid wallet address format"**: Use proper 0x format
- **"Wallet address already registered"**: Account exists
- **"Maximum admin limit reached"**: Too many admins
- **"User cannot delete own account"**: Self-deletion blocked

## Debugging Steps

### 1. Check Browser Console
```javascript
// Open DevTools (F12)
// Look for JavaScript errors
// Check Network tab for failed requests
```

### 2. Verify Environment
```bash
# Check environment variables
echo $SUPABASE_URL
echo $SUPABASE_KEY

# Test API endpoint
curl http://localhost:3001/api/health
```

### 3. Database Verification
```sql
-- Check user table
SELECT * FROM users LIMIT 5;

-- Check admin users
SELECT * FROM users WHERE role = 'admin';
```

### 4. Network Debugging
```bash
# Test connectivity
ping supabase.co

# Check DNS resolution
nslookup your-project.supabase.co
```

## Getting Help

### Support Channels
1. **GitHub Issues**: Report bugs and feature requests
2. **Documentation**: Check all docs/ files
3. **Community**: Join discussions
4. **Email**: Contact project maintainers

### Information to Include
- Browser and version
- Operating system
- Error messages (full text)
- Steps to reproduce
- Screenshots if applicable
- Console logs

### Log Collection
```javascript
// Enable debug logging
localStorage.setItem('debug', 'true');

// Export logs
console.log('User data:', localStorage.getItem('currentUser'));
console.log('Error details:', error.message);
```