CREATE TABLE IF NOT EXISTS api_integration_logs (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  request_id UUID,
  service VARCHAR(100) NOT NULL,
  operation VARCHAR(100) NOT NULL,
  outcome VARCHAR(7) NOT NULL CHECK (outcome IN ('success', 'failure')),
  duration_ms INTEGER NOT NULL CHECK (duration_ms >= 0),
  http_status SMALLINT CHECK (http_status IS NULL OR http_status BETWEEN 100 AND 599),
  error_type VARCHAR(100),
  error_message TEXT,
  error_code VARCHAR(100),
  machine_hostname VARCHAR(255) NOT NULL,
  node_version VARCHAR(32) NOT NULL,
  process_id INTEGER NOT NULL,
  environment VARCHAR(50) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_api_integration_logs_service_created_at
  ON api_integration_logs (service, created_at);

CREATE INDEX IF NOT EXISTS idx_api_integration_logs_request_id
  ON api_integration_logs (request_id);
