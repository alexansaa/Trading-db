-- Ensure schema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'market')
    EXEC('CREATE SCHEMA market');

-- Daily bars table
IF OBJECT_ID('market.PriceBar', 'U') IS NULL
BEGIN
    CREATE TABLE market.PriceBar (
        Id BIGINT IDENTITY(1,1) PRIMARY KEY,
        Symbol      NVARCHAR(32)   NOT NULL,
        Source      NVARCHAR(16)   NOT NULL DEFAULT 'tiingo',
        BarDate     DATE           NOT NULL,   -- trading day
        [Open]      DECIMAL(18,6)  NULL,
        [High]      DECIMAL(18,6)  NULL,
        [Low]       DECIMAL(18,6)  NULL,
        [Close]     DECIMAL(18,6)  NULL,
        Volume      BIGINT         NULL,
        AdjClose    DECIMAL(18,6)  NULL,
        CONSTRAINT UQ_PriceBar UNIQUE (Symbol, Source, BarDate)
    );
END

-- Helpful index for latest queries
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PriceBar_Symbol_BarDate' AND object_id = OBJECT_ID('market.PriceBar'))
    CREATE INDEX IX_PriceBar_Symbol_BarDate ON market.PriceBar(Symbol, BarDate DESC);

-- Upsert proc the Python daemon will call in bulk
GO
CREATE OR ALTER PROCEDURE market.usp_UpsertPriceBar
    @Symbol   NVARCHAR(32),
    @BarDate  DATE,
    @Open     DECIMAL(18,6) = NULL,
    @High     DECIMAL(18,6) = NULL,
    @Low      DECIMAL(18,6) = NULL,
    @Close    DECIMAL(18,6) = NULL,
    @Volume   BIGINT        = NULL,
    @AdjClose DECIMAL(18,6) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    MERGE market.PriceBar AS tgt
    USING (SELECT @Symbol AS Symbol, 'tiingo' AS Source, @BarDate AS BarDate) AS src
    ON (tgt.Symbol = src.Symbol AND tgt.Source = src.Source AND tgt.BarDate = src.BarDate)
    WHEN MATCHED THEN UPDATE SET
        [Open]   = @Open,
        [High]   = @High,
        [Low]    = @Low,
        [Close]  = @Close,
        Volume   = @Volume,
        AdjClose = @AdjClose
    WHEN NOT MATCHED THEN
        INSERT (Symbol, Source, BarDate, [Open], [High], [Low], [Close], Volume, AdjClose)
        VALUES (@Symbol, 'tiingo', @BarDate, @Open, @High, @Low, @Close, @Volume, @AdjClose);
END
GO
