-- Latest close per (Symbol, Source)
CREATE OR ALTER VIEW market.vw_symbol_last_price AS
WITH ranked AS (
    SELECT
        Symbol, Source, BarDate, [Close],
        ROW_NUMBER() OVER (PARTITION BY Symbol, Source ORDER BY BarDate DESC) AS rn
    FROM market.PriceBar
)
SELECT Symbol, Source, BarDate, [Close]
FROM ranked
WHERE rn = 1;
