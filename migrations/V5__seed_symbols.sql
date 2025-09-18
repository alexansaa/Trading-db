-- Seed a few symbols you want the daemon/API to track
MERGE market.Symbols AS tgt
USING (VALUES
    ('AAPL', 1, 'Tiingo'),
    ('MSFT', 1, 'Tiingo'),
    ('GOOGL',1, 'Tiingo'),
    ('TSLA', 1, 'Tiingo')
) AS src(Symbol, IsActive, Source)
ON tgt.Symbol = src.Symbol
WHEN NOT MATCHED BY TARGET THEN
  INSERT (Symbol, IsActive, Source) VALUES (src.Symbol, src.IsActive, src.Source);
