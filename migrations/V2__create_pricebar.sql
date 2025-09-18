-- Canonical price bars table
IF OBJECT_ID('market.PriceBar', 'U') IS NULL
BEGIN
    CREATE TABLE market.PriceBar (
        Symbol   NVARCHAR(20)  NOT NULL,
        Source   NVARCHAR(32)  NOT NULL,
        BarDate  DATETIME2(0)  NOT NULL,
        [Open]   DECIMAL(18,6) NOT NULL,
        [High]   DECIMAL(18,6) NOT NULL,
        [Low]    DECIMAL(18,6) NOT NULL,
        [Close]  DECIMAL(18,6) NOT NULL,
        Volume   BIGINT        NULL,
        AdjClose DECIMAL(18,6) NULL,
        CONSTRAINT PK_market_PriceBar PRIMARY KEY CLUSTERED (Symbol, Source, BarDate)
    );

    CREATE INDEX IX_market_PriceBar_Symbol_BarDate
        ON market.PriceBar (Symbol, BarDate DESC)
        INCLUDE ([Close], Volume, AdjClose);
END
