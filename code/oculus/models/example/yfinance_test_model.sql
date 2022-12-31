
{{ config(materialized='view')}}

SELECT 
CAST(history_date AS DATETIME2) AS history_date,
CAST(open_price AS DECIMAL(18, 2)) AS open_price,
CAST(high_price AS DECIMAL(18, 2)) AS high_price,
CAST(low_price AS DECIMAL(18, 2)) AS low_price,
CAST(close_price AS DECIMAL(18, 2)) AS close_price,
CAST(adjusted_close_price AS DECIMAL(18, 2)) AS adjusted_close_price,
CAST(volume AS DECIMAL(18, 2)) AS volume,
CAST(dividends AS DECIMAL(18, 2)) AS dividends,
CAST(stock_splits AS DECIMAL(18, 2)) AS stock_splits,
entry_datetime AS source_modified_datetime
FROM {{ source('raw', 'yfinance_ticker_history') }}