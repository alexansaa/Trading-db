IF OBJECT_ID('market.Symbols','U') IS NULL
BEGIN
    CREATE TABLE market.Symbols (
        Symbol   NVARCHAR(20) NOT NULL PRIMARY KEY,
        IsActive BIT          NOT NULL DEFAULT(1),
        Source   NVARCHAR(32) NULL
    );
END
