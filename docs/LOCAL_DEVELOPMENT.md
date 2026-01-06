# Local Development Setup

## Prerequisites

- **Node.js** (v16 or higher)
- **npm** or **yarn**
- **Git**
- **MetaMask** browser extension
- **Supabase** account

## Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/Gooichand/blockchain-evidence.git
cd blockchain-evidence
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Environment Setup
```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your credentials
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key
PORT=3001
```

### 4. Database Setup
```bash
# Run in Supabase SQL Editor
# 1. Execute database-schema.sql
# 2. Execute setup-first-admin.sql with your wallet address
```

### 5. Start Development Server
```bash
# Full stack (API + Frontend)
npm start

# Frontend only
npm run dev:frontend

# API only
npm run dev:api
```

## Development Scripts

```bash
# Start full application
npm start

# Development with auto-reload
npm run dev

# Frontend only (port 8080)
cd public && python -m http.server 8080

# API server only (port 3001)
node server.js

# Run tests
npm test

# Lint code
npm run lint
```

## Project Structure

```
blockchain-evidence/
├── public/                 # Frontend files
│   ├── index.html         # Main entry point
│   ├── admin.html         # Admin dashboard
│   ├── dashboard*.html    # Role dashboards
│   ├── app.js            # Main application logic
│   ├── storage.js        # Database client
│   └── styles.css        # Styling
├── docs/                  # Documentation
├── contracts/             # Smart contracts
├── server.js             # Express API server
├── database-schema.sql   # Database setup
├── package.json          # Dependencies
└── README.md             # Project overview
```

## Development Workflow

### 1. Database Changes
```bash
# Update schema
# Edit database-schema.sql
# Run in Supabase SQL Editor
```

### 2. Frontend Development
```bash
# Edit files in public/
# Changes auto-reload with live server
```

### 3. Backend Development
```bash
# Edit server.js
# Restart server: npm start
```

### 4. Testing
```bash
# Create test accounts in admin dashboard
# Test different user roles
# Verify wallet connectivity
```

## Common Development Tasks

### Adding New User Role
1. Update `allowedRoles` in `server.js`
2. Add role to database schema
3. Create dashboard HTML file
4. Update role selection UI

### Adding New API Endpoint
1. Add route in `server.js`
2. Implement validation
3. Add error handling
4. Update API documentation

### Styling Changes
1. Edit `public/styles.css`
2. Use CSS variables for consistency
3. Test responsive design

## Debugging

### Browser Console
```javascript
// Check user data
console.log(localStorage.getItem('currentUser'));

// Check wallet connection
console.log(window.ethereum);

// Check API responses
// Open Network tab in DevTools
```

### Server Logs
```bash
# Enable debug mode
DEBUG=* npm start

# Check server logs
tail -f server.log
```

## Hot Reload Setup

### Frontend (Live Server)
```bash
# Install live-server globally
npm install -g live-server

# Start with auto-reload
cd public && live-server --port=8080
```

### Backend (Nodemon)
```bash
# Install nodemon
npm install -g nodemon

# Start with auto-reload
nodemon server.js
```

## Environment-Specific Configs

### Development
```bash
NODE_ENV=development
PORT=3001
# Use Sepolia testnet
# Enable debug logging
```

### Production
```bash
NODE_ENV=production
PORT=3001
# Use Mainnet
# Disable debug logging
```