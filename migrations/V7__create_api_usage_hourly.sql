-- Ensure schema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'market')
    EXEC('CREATE SCHEMA market');

-- Hourly usage table
IF OBJECT_ID(N'market.ApiUsageHourly', N'U') IS NULL
BEGIN
    CREATE TABLE market.ApiUsageHourly (
        UsageDate  DATE         NOT NULL,      -- in your app TZ
        UsageHour  TINYINT      NOT NULL,      -- 0..23
        Service    NVARCHAR(50) NOT NULL,
        Calls      INT          NOT NULL DEFAULT 0,
        CONSTRAINT PK_ApiUsageHourly PRIMARY KEY (UsageDate, UsageHour, Service)
    );

    -- Helpful index for queries by date/service
    CREATE INDEX IX_ApiUsageHourly_DateSvc ON market.ApiUsageHourly(UsageDate, Service);
END
