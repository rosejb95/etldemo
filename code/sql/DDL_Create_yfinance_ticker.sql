CREATE TABLE source.yfinance_ticker (
  ticker NVARCHAR(5) PRIMARY KEY,
  isin VARCHAR(12),
  entry_datetime DATETIME2 DEFAULT SYSUTCDATETIME()
)

