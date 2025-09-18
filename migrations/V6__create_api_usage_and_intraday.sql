-- Ensure schema exists (safe if already created)
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'market')
    EXEC(N'CREATE SCHEMA market');

-- ApiUsage (track daily API calls)
IF OBJECT_ID(N'market.ApiUsage', N'U') IS NULL
BEGIN
    CREATE TABLE market.ApiUsage (
        UsageDate DATE NOT NULL,
        Service   NVARCHAR(50) NOT NULL,
        Calls     INT NOT NULL DEFAULT (0),
        CONSTRAINT PK_market_ApiUsage PRIMARY KEY CLUSTERED (UsageDate, Service)
    );
END
GO

-- Intraday bars
IF OBJECT_ID(N'market.PriceBarIntra', N'U') IS NULL
BEGIN
    CREATE TABLE market.PriceBarIntra (
        Symbol      NVARCHAR(20)  NOT NULL,
        Source      NVARCHAR(32)  NOT NULL,
        BarTime     DATETIME2(0)  NOT NULL,           -- timestamp of bar
        IntervalSec INT           NOT NULL,           -- e.g., 60, 300, 900
        [Open]      DECIMAL(18,6) NULL,
        [High]      DECIMAL(18,6) NULL,
        [Low]       DECIMAL(18,6) NULL,
        [Close]     DECIMAL(18,6) NULL,
        Volume      BIGINT        NULL,
        CONSTRAINT PK_market_PriceBarIntra PRIMARY KEY CLUSTERED (Symbol, Source, BarTime, IntervalSec)
    );

    -- Handy query pattern: latest bars per symbol
    CREATE INDEX IX_market_PriceBarIntra_Symbol_BarTime
        ON market.PriceBarIntra (Symbol, BarTime DESC)
        INCLUDE ([Close], Volume);
END
GO
