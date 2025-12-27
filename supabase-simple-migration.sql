-- Simple Migration Script for Supabase
-- Run this in SQL Editor

-- Add new columns to users table
DO $$
BEGIN
    -- Add email column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'email') THEN
        ALTER TABLE users ADD COLUMN email TEXT UNIQUE;
    END IF;
    
    -- Add last_login column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'last_login') THEN
        ALTER TABLE users ADD COLUMN last_login TIMESTAMPTZ;
    END IF;
    
    -- Add failed_login_attempts column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'failed_login_attempts') THEN
        ALTER TABLE users ADD COLUMN failed_login_attempts INTEGER DEFAULT 0;
    END IF;
    
    -- Add locked_until column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'locked_until') THEN
        ALTER TABLE users ADD COLUMN locked_until TIMESTAMPTZ;
    END IF;
    
    -- Add password_hash column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'password_hash') THEN
        ALTER TABLE users ADD COLUMN password_hash TEXT;
    END IF;
    
    -- Add two_factor_enabled column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'two_factor_enabled') THEN
        ALTER TABLE users ADD COLUMN two_factor_enabled BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

-- Add new columns to evidence table
DO $$
BEGIN
    -- Add evidence_id column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'evidence' AND column_name = 'evidence_id') THEN
        ALTER TABLE evidence ADD COLUMN evidence_id TEXT UNIQUE;
    END IF;
    
    -- Add mime_type column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'evidence' AND column_name = 'mime_type') THEN
        ALTER TABLE evidence ADD COLUMN mime_type TEXT;
    END IF;
    
    -- Add blockchain_hash column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'evidence' AND column_name = 'blockchain_hash') THEN
        ALTER TABLE evidence ADD COLUMN blockchain_hash TEXT;
    END IF;
    
    -- Add submission_ip column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'evidence' AND column_name = 'submission_ip') THEN
        ALTER TABLE evidence ADD COLUMN submission_ip TEXT;
    END IF;
    
    -- Add is_encrypted column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'evidence' AND column_name = 'is_encrypted') THEN
        ALTER TABLE evidence ADD COLUMN is_encrypted BOOLEAN DEFAULT FALSE;
    END IF;
    
    -- Add metadata column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'evidence' AND column_name = 'metadata') THEN
        ALTER TABLE evidence ADD COLUMN metadata JSONB;
    END IF;
    
    -- Rename hash to hash_sha256 if needed
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'evidence' AND column_name = 'hash') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'evidence' AND column_name = 'hash_sha256') THEN
        ALTER TABLE evidence RENAME COLUMN hash TO hash_sha256;
    END IF;
END $$;

-- Add new columns to cases table
DO $$
BEGIN
    -- Add case_id column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cases' AND column_name = 'case_id') THEN
        ALTER TABLE cases ADD COLUMN case_id TEXT UNIQUE;
    END IF;
    
    -- Add assigned_to column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cases' AND column_name = 'assigned_to') THEN
        ALTER TABLE cases ADD COLUMN assigned_to TEXT[];
    END IF;
    
    -- Add due_date column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cases' AND column_name = 'due_date') THEN
        ALTER TABLE cases ADD COLUMN due_date TIMESTAMPTZ;
    END IF;
    
    -- Add tags column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cases' AND column_name = 'tags') THEN
        ALTER TABLE cases ADD COLUMN tags TEXT[];
    END IF;
    
    -- Add metadata column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cases' AND column_name = 'metadata') THEN
        ALTER TABLE cases ADD COLUMN metadata JSONB;
    END IF;
END $$;

-- Create chain_of_custody table
CREATE TABLE IF NOT EXISTS chain_of_custody (
    id SERIAL PRIMARY KEY,
    evidence_id INTEGER REFERENCES evidence(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    performed_by TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    ip_address TEXT,
    details TEXT,
    previous_hash TEXT,
    entry_hash TEXT NOT NULL
);

-- Create file_access_logs table
CREATE TABLE IF NOT EXISTS file_access_logs (
    id SERIAL PRIMARY KEY,
    evidence_id INTEGER REFERENCES evidence(id) ON DELETE CASCADE,
    accessed_by TEXT NOT NULL,
    access_type TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    ip_address TEXT,
    success BOOLEAN DEFAULT TRUE,
    failure_reason TEXT
);

-- Create user_sessions table
CREATE TABLE IF NOT EXISTS user_sessions (
    id SERIAL PRIMARY KEY,
    session_id TEXT UNIQUE NOT NULL,
    user_id TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    ip_address TEXT,
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

-- Create blockchain_transactions table
CREATE TABLE IF NOT EXISTS blockchain_transactions (
    id SERIAL PRIMARY KEY,
    evidence_id INTEGER REFERENCES evidence(id) ON DELETE CASCADE,
    transaction_hash TEXT UNIQUE NOT NULL,
    block_number BIGINT,
    network TEXT NOT NULL,
    gas_used BIGINT,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    status TEXT DEFAULT 'pending'
);

-- Add new columns to activity_logs
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'activity_logs' AND column_name = 'resource_type') THEN
        ALTER TABLE activity_logs ADD COLUMN resource_type TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'activity_logs' AND column_name = 'resource_id') THEN
        ALTER TABLE activity_logs ADD COLUMN resource_id TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'activity_logs' AND column_name = 'user_agent') THEN
        ALTER TABLE activity_logs ADD COLUMN user_agent TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'activity_logs' AND column_name = 'session_id') THEN
        ALTER TABLE activity_logs ADD COLUMN session_id TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'activity_logs' AND column_name = 'severity') THEN
        ALTER TABLE activity_logs ADD COLUMN severity TEXT DEFAULT 'info';
    END IF;
END $$;

-- Enable RLS on new tables
ALTER TABLE chain_of_custody ENABLE ROW LEVEL SECURITY;
ALTER TABLE file_access_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE blockchain_transactions ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Allow all operations" ON chain_of_custody FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON file_access_logs FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON user_sessions FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON blockchain_transactions FOR ALL USING (true);

-- Create indexes (only for existing columns)
CREATE INDEX IF NOT EXISTS idx_evidence_evidence_id ON evidence(evidence_id);
CREATE INDEX IF NOT EXISTS idx_cases_case_id ON cases(case_id);
CREATE INDEX IF NOT EXISTS idx_custody_evidence ON chain_of_custody(evidence_id);
CREATE INDEX IF NOT EXISTS idx_file_access_evidence ON file_access_logs(evidence_id);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_blockchain_evidence ON blockchain_transactions(evidence_id);