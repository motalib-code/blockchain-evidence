-- Minimal Migration - Only New Tables
-- Run this in Supabase SQL Editor

-- Create chain_of_custody table
CREATE TABLE IF NOT EXISTS chain_of_custody (
    id SERIAL PRIMARY KEY,
    evidence_id INTEGER REFERENCES evidence(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    performed_by TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    ip_address TEXT,
    details TEXT,
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
    success BOOLEAN DEFAULT TRUE
);

-- Enable RLS
ALTER TABLE chain_of_custody ENABLE ROW LEVEL SECURITY;
ALTER TABLE file_access_logs ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Allow all operations" ON chain_of_custody FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON file_access_logs FOR ALL USING (true);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_custody_evidence ON chain_of_custody(evidence_id);
CREATE INDEX IF NOT EXISTS idx_file_access_evidence ON file_access_logs(evidence_id);