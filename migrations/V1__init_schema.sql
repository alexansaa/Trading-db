-- Create DB (if not already in Azure SQL/managed instance, comment this)
-- IF DB_ID('trading') IS NULL
-- #BEGIN
--   CREATE DATABASE trading;
-- END
-- GO
-- USE trading;
-- GO

-- Reference
CREATE TABLE dbo.symbols(
  id INT IDENTITY PRIMARY KEY,
  ticker NVARCHAR(16) NOT NULL UNIQUE,
  name NVARCHAR(128) NULL,
  active BIT NOT NULL DEFAULT 1
);

-- Market data
CREATE TABLE dbo.price_bars(
  id BIGINT IDENTITY PRIMARY KEY,
  symbol_id INT NOT NULL,
  ts DATETIME2(3) NOT NULL,         -- millisecond resolution
  [open] DECIMAL(18,6) NOT NULL,
  high DECIMAL(18,6) NOT NULL,
  low  DECIMAL(18,6) NOT NULL,
  [close] DECIMAL(18,6) NOT NULL,
  volume BIGINT NULL,
  CONSTRAINT UQ_price_bars UNIQUE(symbol_id, ts),
  CONSTRAINT FK_price_bars_symbol FOREIGN KEY(symbol_id) REFERENCES dbo.symbols(id)
);

-- Indicators snapshot per bar
CREATE TABLE dbo.indicators(
  id BIGINT IDENTITY PRIMARY KEY,
  symbol_id INT NOT NULL,
  ts DATETIME2(3) NOT NULL,
  rsi FLOAT NULL,
  macd FLOAT NULL,
  macd_signal FLOAT NULL,
  macd_hist FLOAT NULL,
  sma_20 FLOAT NULL,
  sma_50 FLOAT NULL,
  sma_200 FLOAT NULL,
  CONSTRAINT UQ_indicators UNIQUE(symbol_id, ts),
  CONSTRAINT FK_indicators_symbol FOREIGN KEY(symbol_id) REFERENCES dbo.symbols(id)
);

-- Strategy catalog
CREATE TABLE dbo.strategies(
  id INT IDENTITY PRIMARY KEY,
  code NVARCHAR(64) NOT NULL UNIQUE,
  description NVARCHAR(256) NULL
);

-- Predictions by strategy and aggregate
CREATE TABLE dbo.predictions(
  id BIGINT IDENTITY PRIMARY KEY,
  symbol_id INT NOT NULL,
  ts DATETIME2(3) NOT NULL,
  strategy_id INT NOT NULL,
  direction NVARCHAR(8) NOT NULL CHECK (direction IN ('BUY','SELL','HOLD')),
  confidence FLOAT NOT NULL,
  meta NVARCHAR(MAX) NULL,
  CONSTRAINT FK_predictions_symbol FOREIGN KEY(symbol_id) REFERENCES dbo.symbols(id),
  CONSTRAINT FK_predictions_strategy FOREIGN KEY(strategy_id) REFERENCES dbo.strategies(id),
  CONSTRAINT UQ_predictions UNIQUE(symbol_id, ts, strategy_id)
);

-- Executed trades (mock/paper or real)
CREATE TABLE dbo.trades(
  id BIGINT IDENTITY PRIMARY KEY,
  symbol_id INT NOT NULL,
  ts DATETIME2(3) NOT NULL,
  side NVARCHAR(4) NOT NULL CHECK (side IN ('BUY','SELL')),
  qty DECIMAL(18,6) NOT NULL,
  price DECIMAL(18,6) NOT NULL,
  fees DECIMAL(18,6) NULL,
  order_id NVARCHAR(64) NULL,
  status NVARCHAR(16) NOT NULL DEFAULT 'FILLED',
  pnl DECIMAL(18,6) NULL, -- realized PnL (optional, can be NULL until settled)
  CONSTRAINT FK_trades_symbol FOREIGN KEY(symbol_id) REFERENCES dbo.symbols(id)
);

-- Users (mapped from IDP)
CREATE TABLE dbo.users(
  id INT IDENTITY PRIMARY KEY,
  sub NVARCHAR(255) NOT NULL UNIQUE,  -- JWT subject
  email NVARCHAR(255) NOT NULL,
  [name] NVARCHAR(255) NULL
);
