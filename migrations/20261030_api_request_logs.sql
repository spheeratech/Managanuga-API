CREATE TABLE IF NOT EXISTS api_request_logs (
  request_id UUID PRIMARY KEY,
  method VARCHAR(16) NOT NULL,
  route VARCHAR(512) NOT NULL,
  status_code SMALLINT NOT NULL CHECK (status_code BETWEEN 100 AND 599),
  outcome VARCHAR(7) NOT NULL CHECK (outcome IN ('success', 'failure')),
  duration_ms INTEGER NOT NULL CHECK (duration_ms >= 0),
  error_type VARCHAR(100),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_api_request_logs_created_at
  ON api_request_logs (created_at);

CREATE INDEX IF NOT EXISTS idx_api_request_logs_status_created_at
  ON api_request_logs (status_code, created_at);
