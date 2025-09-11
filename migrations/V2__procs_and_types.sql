GO

-- Table type for bulk upsert of bars from Python
CREATE TYPE dbo.PriceBarType AS TABLE
(
  ts DATETIME2(3) NOT NULL,
  [open] DECIMAL(18,6) NOT NULL,
  high DECIMAL(18,6) NOT NULL,
  low  DECIMAL(18,6) NOT NULL,
  [close] DECIMAL(18,6) NOT NULL,
  volume BIGINT NULL
);
GO

-- Ensure symbol exists, return @symbol_id
CREATE OR ALTER PROCEDURE dbo.ensure_symbol
  @ticker NVARCHAR(16),
  @name   NVARCHAR(128) = NULL,
  @symbol_id INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT @symbol_id = id FROM dbo.symbols WHERE ticker=@ticker;
  IF @symbol_id IS NULL
  BEGIN
    INSERT INTO dbo.symbols(ticker, name, active) VALUES(@ticker, @name, 1);
    SET @symbol_id = SCOPE_IDENTITY();
  END
END
GO

-- Upsert price bars via TVP (MERGE is set-based & idempotent)
CREATE OR ALTER PROCEDURE dbo.upsert_price_bars
  @ticker NVARCHAR(16),
  @bars dbo.PriceBarType READONLY
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @sid INT;
  EXEC dbo.ensure_symbol @ticker=@ticker, @name=NULL, @symbol_id=@sid OUTPUT;

  MERGE dbo.price_bars AS tgt
  USING (
    SELECT @sid AS symbol_id, ts, [open], high, low, [close], volume
    FROM @bars
  ) AS src
  ON (tgt.symbol_id = src.symbol_id AND tgt.ts = src.ts)
  WHEN MATCHED THEN UPDATE SET
    [open]=src.[open], high=src.high, low=src.low, [close]=src.[close], volume=src.volume
  WHEN NOT MATCHED THEN INSERT(symbol_id, ts, [open], high, low, [close], volume)
    VALUES(src.symbol_id, src.ts, src.[open], src.high, src.low, src.[close], src.volume);
END
GO

-- Get price history window
CREATE OR ALTER PROCEDURE dbo.get_price_history
  @ticker NVARCHAR(16),
  @from   DATETIME2(3),
  @to     DATETIME2(3)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @sid INT = (SELECT id FROM dbo.symbols WHERE ticker=@ticker);
  IF @sid IS NULL
  BEGIN
    SELECT CAST(NULL AS DATETIME2(3)) AS ts, CAST(NULL AS DECIMAL(18,6)) AS [open],
           CAST(NULL AS DECIMAL(18,6)) AS high, CAST(NULL AS DECIMAL(18,6)) AS low,
           CAST(NULL AS DECIMAL(18,6)) AS [close], CAST(NULL AS BIGINT) AS volume
    WHERE 1=0;
    RETURN;
  END

  SELECT ts, [open], high, low, [close], volume
  FROM dbo.price_bars WITH (READPAST)
  WHERE symbol_id=@sid AND ts BETWEEN @from AND @to
  ORDER BY ts ASC;
END
GO

-- Insert a trade
CREATE OR ALTER PROCEDURE dbo.insert_trade
  @ticker NVARCHAR(16),
  @ts     DATETIME2(3),
  @side   NVARCHAR(4),
  @qty    DECIMAL(18,6),
  @price  DECIMAL(18,6),
  @fees   DECIMAL(18,6) = NULL,
  @order_id NVARCHAR(64) = NULL,
  @status NVARCHAR(16) = 'FILLED'
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @sid INT;
  EXEC dbo.ensure_symbol @ticker=@ticker, @symbol_id=@sid OUTPUT;

  INSERT INTO dbo.trades(symbol_id, ts, side, qty, price, fees, order_id, status)
  VALUES(@sid, @ts, @side, @qty, @price, @fees, @order_id, @status);
END
GO

-- Get trades by window
CREATE OR ALTER PROCEDURE dbo.get_trades
  @ticker NVARCHAR(16)=NULL,
  @from   DATETIME2(3)=NULL,
  @to     DATETIME2(3)=NULL
AS
BEGIN
  SET NOCOUNT ON;
  SELECT t.id, s.ticker, t.ts, t.side, t.qty, t.price, t.fees, t.pnl, t.status, t.order_id
  FROM dbo.trades t
  JOIN dbo.symbols s ON s.id=t.symbol_id
  WHERE (@ticker IS NULL OR s.ticker=@ticker)
    AND (@from IS NULL OR t.ts >= @from)
    AND (@to   IS NULL OR t.ts <= @to)
  ORDER BY t.ts DESC, t.id DESC;
END
GO

-- Record model predictions (single strategy)
CREATE OR ALTER PROCEDURE dbo.upsert_prediction
  @ticker NVARCHAR(16),
  @ts DATETIME2(3),
  @strategy_code NVARCHAR(64),
  @direction NVARCHAR(8),
  @confidence FLOAT,
  @meta NVARCHAR(MAX) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @sid INT, @stid INT;
  SELECT @sid = id FROM dbo.symbols WHERE ticker=@ticker;
  SELECT @stid = id FROM dbo.strategies WHERE code=@strategy_code;
  IF @sid IS NULL OR @stid IS NULL
  BEGIN
    RAISERROR('Unknown symbol or strategy', 16, 1);
    RETURN;
  END

  MERGE dbo.predictions AS tgt
  USING (SELECT @sid AS symbol_id, @ts AS ts, @stid AS strategy_id) AS src
  ON (tgt.symbol_id=src.symbol_id AND tgt.ts=src.ts AND tgt.strategy_id=src.strategy_id)
  WHEN MATCHED THEN UPDATE SET direction=@direction, confidence=@confidence, meta=@meta
  WHEN NOT MATCHED THEN
    INSERT(symbol_id, ts, strategy_id, direction, confidence, meta)
    VALUES(@sid, @ts, @stid, @direction, @confidence, @meta);
END
GO
