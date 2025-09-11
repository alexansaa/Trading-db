GO
INSERT INTO dbo.strategies(code, description) VALUES
  ('TREND', 'Trend-following confirmation'),
  ('MEANREV', 'Mean-reversion confirmation'),
  ('BREAKOUT', 'Breakout confirmation');

-- Example symbols; Python can upsert new ones as needed
INSERT INTO dbo.symbols(ticker, name) VALUES
  ('AAPL','Apple Inc.'), ('MSFT','Microsoft Corp.'), ('TSLA','Tesla Inc.');
