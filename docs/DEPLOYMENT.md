# Deployment Guide

## Platform Options

### Render (Recommended)
- **Free tier available**
- **Automatic deployments**
- **Environment variables support**
- **Custom domains**

### Vercel
- **Excellent for frontend**
- **Serverless functions**
- **Fast global CDN**

### Netlify
- **Static site hosting**
- **Form handling**
- **Edge functions**

## Render Deployment

### 1. Prepare Repository
```bash
# Ensure render.yaml exists
# Commit all changes
git add .
git commit -m "Prepare for deployment"
git push origin main
```

### 2. Create Render Service
1. Go to [render.com](https://render.com)
2. Connect GitHub repository
3. Select "Web Service"
4. Choose `blockchain-evidence` repository

### 3. Configure Service
```yaml
# render.yaml (already included)
services:
  - type: web
    name: evid-dgc
    env: node
    plan: free
    buildCommand: npm install
    startCommand: npm start
    envVars:
      - key: NODE_ENV
        value: production
```

### 4. Set Environment Variables
```bash
SUPABASE_URL=your_production_supabase_url
SUPABASE_KEY=your_production_supabase_key
NODE_ENV=production
PORT=3001
```

### 5. Deploy
- Click "Create Web Service"
- Deployment starts automatically
- Access via provided URL

## Vercel Deployment

### 1. Install Vercel CLI
```bash
npm install -g vercel
```

### 2. Configure Project
```json
// vercel.json
{
  "version": 2,
  "builds": [
    {
      "src": "server.js",
      "use": "@vercel/node"
    },
    {
      "src": "public/**",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "/server.js"
    },
    {
      "src": "/(.*)",
      "dest": "/public/$1"
    }
  ]
}
```

### 3. Deploy
```bash
# Login to Vercel
vercel login

# Deploy
vercel

# Set environment variables
vercel env add SUPABASE_URL
vercel env add SUPABASE_KEY

# Redeploy with env vars
vercel --prod
```

## Netlify Deployment

### 1. Build Configuration
```toml
# netlify.toml
[build]
  publish = "public"
  command = "npm run build"

[build.environment]
  NODE_VERSION = "18"

[[redirects]]
  from = "/api/*"
  to = "/.netlify/functions/:splat"
  status = 200

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### 2. Netlify Functions
```javascript
// netlify/functions/api.js
const express = require('express');
const serverless = require('serverless-http');
const app = require('../../server');

module.exports.handler = serverless(app);
```

### 3. Deploy
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Deploy
netlify deploy

# Production deploy
netlify deploy --prod
```

## Database Setup (All Platforms)

### 1. Supabase Configuration
```sql
-- Run in Supabase SQL Editor
-- 1. Execute database-schema.sql
-- 2. Execute setup-first-admin.sql
-- 3. Configure RLS policies
```

### 2. Environment Variables
```bash
# Production Supabase project
SUPABASE_URL=https://your-prod-project.supabase.co
SUPABASE_KEY=your_production_anon_key
```

## Custom Domain Setup

### Render
1. Go to service settings
2. Add custom domain
3. Configure DNS records
4. Enable HTTPS

### Vercel
```bash
# Add domain
vercel domains add yourdomain.com

# Configure DNS
# Add CNAME record pointing to vercel
```

### Netlify
1. Site settings → Domain management
2. Add custom domain
3. Configure DNS
4. Enable HTTPS

## Environment-Specific Deployments

### Staging
```bash
# Create staging branch
git checkout -b staging

# Deploy to staging environment
# Use separate Supabase project
```

### Production
```bash
# Deploy from main branch
# Use production Supabase project
# Enable monitoring and logging
```

## Post-Deployment Checklist

- [ ] Test wallet connectivity
- [ ] Verify admin login
- [ ] Test user registration
- [ ] Check all user roles
- [ ] Verify database operations
- [ ] Test responsive design
- [ ] Check HTTPS certificate
- [ ] Monitor error logs
- [ ] Set up analytics (optional)

## Monitoring & Maintenance

### Health Checks
```bash
# API health endpoint
curl https://your-domain.com/api/health

# Expected response
{"status":"OK","timestamp":"2026-01-XX"}
```

### Log Monitoring
- Check platform-specific logs
- Monitor error rates
- Set up alerts for failures

### Database Maintenance
- Monitor Supabase usage
- Backup important data
- Optimize queries if needed