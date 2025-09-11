GO

-- Helpful view: last close per symbol
CREATE OR ALTER VIEW dbo.vw_symbol_last_price AS
SELECT s.ticker, pb.ts, pb.[close]
FROM dbo.symbols s
CROSS APPLY (
  SELECT TOP(1) ts, [close]
  FROM dbo.price_bars b
  WHERE b.symbol_id = s.id
  ORDER BY ts DESC
) pb;
GO

-- Indexes for query speed
CREATE INDEX IX_price_bars_symbol_ts ON dbo.price_bars(symbol_id, ts) INCLUDE([open], high, low, [close], volume);
CREATE INDEX IX_indicators_symbol_ts ON dbo.indicators(symbol_id, ts);
CREATE INDEX IX_trades_symbol_ts ON dbo.trades(symbol_id, ts);
CREATE INDEX IX_predictions_symbol_ts_strat ON dbo.predictions(symbol_id, ts, strategy_id);
GO
