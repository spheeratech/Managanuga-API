CREATE TABLE IF NOT EXISTS api_exception_logs (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  request_id UUID,
  method VARCHAR(16),
  route VARCHAR(512),
  error_type VARCHAR(100) NOT NULL,
  error_message TEXT NOT NULL,
  error_code VARCHAR(100),
  machine_hostname VARCHAR(255) NOT NULL,
  node_version VARCHAR(32) NOT NULL,
  process_id INTEGER NOT NULL,
  environment VARCHAR(50) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_api_exception_logs_request_id
  ON api_exception_logs (request_id);

CREATE INDEX IF NOT EXISTS idx_api_exception_logs_created_at
  ON api_exception_logs (created_at);
