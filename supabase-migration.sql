-- Migration Script: Update Existing Database
-- Run this instead of the full schema

-- Add new columns to existing users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT UNIQUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS failed_login_attempts INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS locked_until TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS two_factor_enabled BOOLEAN DEFAULT FALSE;

-- Add constraints to users table
ALTER TABLE users ADD CONSTRAINT IF NOT EXISTS users_role_check CHECK (role BETWEEN 1 AND 8);

-- Update existing evidence table
ALTER TABLE evidence ADD COLUMN IF NOT EXISTS evidence_id TEXT UNIQUE;
ALTER TABLE evidence ADD COLUMN IF NOT EXISTS mime_type TEXT;
ALTER TABLE evidence ADD COLUMN IF NOT EXISTS hash_sha256 TEXT;
ALTER TABLE evidence ADD COLUMN IF NOT EXISTS blockchain_hash TEXT;
ALTER TABLE evidence ADD COLUMN IF NOT EXISTS submission_ip TEXT;
ALTER TABLE evidence ADD COLUMN IF NOT EXISTS encryption_key_id TEXT;
ALTER TABLE evidence ADD COLUMN IF NOT EXISTS is_encrypted BOOLEAN DEFAULT FALSE;
ALTER TABLE evidence ADD COLUMN IF NOT EXISTS metadata JSONB;

-- Rename hash column to hash_sha256 if it exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'evidence' AND column_name = 'hash') THEN
        ALTER TABLE evidence RENAME COLUMN hash TO hash_sha256;
    END IF;
END $$;

-- Add constraints to evidence table
ALTER TABLE evidence ADD CONSTRAINT IF NOT EXISTS evidence_status_check 
    CHECK (status IN ('pending', 'approved', 'rejected', 'under_review'));

-- Update existing cases table
ALTER TABLE cases ADD COLUMN IF NOT EXISTS case_id TEXT UNIQUE;
ALTER TABLE cases ADD COLUMN IF NOT EXISTS assigned_to TEXT[];
ALTER TABLE cases ADD COLUMN IF NOT EXISTS due_date TIMESTAMPTZ;
ALTER TABLE cases ADD COLUMN IF NOT EXISTS tags TEXT[];
ALTER TABLE cases ADD COLUMN IF NOT EXISTS metadata JSONB;

-- Add constraints to cases table
ALTER TABLE cases ADD CONSTRAINT IF NOT EXISTS cases_priority_check 
    CHECK (priority IN ('low', 'medium', 'high', 'critical'));
ALTER TABLE cases ADD CONSTRAINT IF NOT EXISTS cases_status_check 
    CHECK (status IN ('open', 'active', 'closed', 'archived'));

-- Create new tables (only if they don't exist)

-- Chain of custody table
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

-- File access logs table
CREATE TABLE IF NOT EXISTS file_access_logs (
    id SERIAL PRIMARY KEY,
    evidence_id INTEGER REFERENCES evidence(id) ON DELETE CASCADE,
    accessed_by TEXT NOT NULL,
    access_type TEXT NOT NULL CHECK (access_type IN ('view', 'download', 'modify', 'delete')),
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    ip_address TEXT,
    success BOOLEAN DEFAULT TRUE,
    failure_reason TEXT
);

-- User sessions table
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

-- Blockchain transactions table
CREATE TABLE IF NOT EXISTS blockchain_transactions (
    id SERIAL PRIMARY KEY,
    evidence_id INTEGER REFERENCES evidence(id) ON DELETE CASCADE,
    transaction_hash TEXT UNIQUE NOT NULL,
    block_number BIGINT,
    network TEXT NOT NULL,
    gas_used BIGINT,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'failed'))
);

-- Update activity_logs table structure
ALTER TABLE activity_logs ADD COLUMN IF NOT EXISTS resource_type TEXT;
ALTER TABLE activity_logs ADD COLUMN IF NOT EXISTS resource_id TEXT;
ALTER TABLE activity_logs ADD COLUMN IF NOT EXISTS user_agent TEXT;
ALTER TABLE activity_logs ADD COLUMN IF NOT EXISTS session_id TEXT;
ALTER TABLE activity_logs ADD COLUMN IF NOT EXISTS severity TEXT DEFAULT 'info';

-- Add constraint to activity_logs
ALTER TABLE activity_logs ADD CONSTRAINT IF NOT EXISTS activity_logs_severity_check 
    CHECK (severity IN ('info', 'warning', 'error', 'critical'));

-- Enable RLS on new tables
ALTER TABLE chain_of_custody ENABLE ROW LEVEL SECURITY;
ALTER TABLE file_access_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE blockchain_transactions ENABLE ROW LEVEL SECURITY;

-- Create policies for new tables
DO $$
BEGIN
    -- Chain of custody policies
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'chain_of_custody') THEN
        CREATE POLICY "Allow authenticated users" ON chain_of_custody FOR ALL USING (true);
    END IF;
    
    -- File access logs policies
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'file_access_logs') THEN
        CREATE POLICY "Allow authenticated users" ON file_access_logs FOR ALL USING (true);
    END IF;
    
    -- User sessions policies
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_sessions') THEN
        CREATE POLICY "Allow authenticated users" ON user_sessions FOR ALL USING (true);
    END IF;
    
    -- Blockchain transactions policies
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'blockchain_transactions') THEN
        CREATE POLICY "Allow authenticated users" ON blockchain_transactions FOR ALL USING (true);
    END IF;
END $$;

-- Create new indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_evidence_evidence_id ON evidence(evidence_id);
CREATE INDEX IF NOT EXISTS idx_evidence_hash_sha256 ON evidence(hash_sha256);
CREATE INDEX IF NOT EXISTS idx_evidence_mime_type ON evidence(mime_type);
CREATE INDEX IF NOT EXISTS idx_cases_case_id ON cases(case_id);
CREATE INDEX IF NOT EXISTS idx_custody_evidence ON chain_of_custody(evidence_id);
CREATE INDEX IF NOT EXISTS idx_custody_timestamp ON chain_of_custody(timestamp);
CREATE INDEX IF NOT EXISTS idx_file_access_evidence ON file_access_logs(evidence_id);
CREATE INDEX IF NOT EXISTS idx_file_access_timestamp ON file_access_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expires ON user_sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_blockchain_evidence ON blockchain_transactions(evidence_id);
CREATE INDEX IF NOT EXISTS idx_blockchain_hash ON blockchain_transactions(transaction_hash);

-- Create or replace functions
CREATE OR REPLACE FUNCTION update_last_modified()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_modified = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_cases_last_modified') THEN
        CREATE TRIGGER update_cases_last_modified
            BEFORE UPDATE ON cases
            FOR EACH ROW
            EXECUTE FUNCTION update_last_modified();
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_users_last_updated') THEN
        CREATE TRIGGER update_users_last_updated
            BEFORE UPDATE ON users
            FOR EACH ROW
            EXECUTE FUNCTION update_last_modified();
    END IF;
END $$;

-- Function to generate evidence ID
CREATE OR REPLACE FUNCTION generate_evidence_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.evidence_id IS NULL THEN
        NEW.evidence_id = 'EVD-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(NEW.id::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create evidence ID trigger if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_evidence_id') THEN
        CREATE TRIGGER set_evidence_id
            BEFORE INSERT ON evidence
            FOR EACH ROW
            EXECUTE FUNCTION generate_evidence_id();
    END IF;
END $$;

-- Function to auto-log chain of custody
CREATE OR REPLACE FUNCTION log_chain_of_custody()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO chain_of_custody (evidence_id, action, performed_by, details, entry_hash)
        VALUES (
            NEW.id,
            'EVIDENCE_CREATED',
            NEW.submitted_by,
            'Evidence initially submitted',
            encode(sha256((NEW.id || 'EVIDENCE_CREATED' || NEW.submitted_by || NOW())::bytea), 'hex')
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create chain of custody trigger if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'auto_chain_of_custody') THEN
        CREATE TRIGGER auto_chain_of_custody
            AFTER INSERT ON evidence
            FOR EACH ROW
            EXECUTE FUNCTION log_chain_of_custody();
    END IF;
END $$;