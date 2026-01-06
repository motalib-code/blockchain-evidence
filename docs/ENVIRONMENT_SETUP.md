# Environment Variables Setup

## Required Environment Variables

Create a `.env` file in the root directory with the following variables:

```bash
# Supabase Configuration
SUPABASE_URL=your_supabase_project_url
SUPABASE_KEY=your_supabase_anon_key

# Server Configuration
PORT=3001
NODE_ENV=production

# Optional: Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

## Getting Supabase Credentials

1. **Create Supabase Project**
   - Go to [supabase.com](https://supabase.com)
   - Create new project
   - Note your project URL and anon key

2. **Find Your Credentials**
   - Project URL: `https://your-project-id.supabase.co`
   - Anon Key: Found in Project Settings > API

## Environment File Examples

### Development (.env.development)
```bash
SUPABASE_URL=https://your-dev-project.supabase.co
SUPABASE_KEY=your_development_anon_key
PORT=3001
NODE_ENV=development
```

### Production (.env.production)
```bash
SUPABASE_URL=https://your-prod-project.supabase.co
SUPABASE_KEY=your_production_anon_key
PORT=3001
NODE_ENV=production
```

## Security Notes

- Never commit `.env` files to version control
- Use different Supabase projects for dev/prod
- Rotate keys regularly
- Use environment-specific configurations