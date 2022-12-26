import connection_utils as cu
import pandas as pd
import yfinance as yf

TABLE_SCHEMA = "source"
TICKER_TABLE_NAME = "yfinance_ticker"
HISTORY_TABLE_NAME = "yfinance_ticker_history"


SOURCE_TO_SQL_COLUMNS_NAMES = {
    "Date": "history_date",
    "Open": "open_price",
    "High": "high_price",
    "Low": "low_price",
    "Close": "close_price",
    "Adj Close": "adjusted_close_price",
    "Volume": "volume",
    "Dividends": "dividends",
    "Stock Splits": "stock_splits",
}


def get_ticker_reference_data(tickers: yf.Tickers) -> pd.DataFrame:
    """
    Pulls reference data given a collection of tickers. Returns a DF.
    Currently only pulls isin."""

    ticker_data = [
        [ticker_symbol, ticker.isin]
        for ticker_symbol, ticker in tickers.tickers.items()
    ]
    ticker_df = pd.DataFrame(ticker_data, columns=["ticker", "isin"], dtype=object)
    ticker_df = ticker_df.assign(
        isin=ticker_df["isin"].where(ticker_df["isin"] != "-", None)
    )

    return ticker_df


def get_ticker_history_as_frame(tickers: yf.Tickers) -> pd.DataFrame:
    # TODO Change to incremental as needed.
    ticker_history_df = pd.concat(
        [
            ticker.history(period="max").reset_index()
            for _, ticker in tickers.tickers.items()
        ],
        ignore_index=True,
    )
    ticker_history_df = ticker_history_df.dropna(how="all", axis=1)
    ticker_history_df = ticker_history_df.where(
        pd.isnull(ticker_history_df), ticker_history_df.astype(str)
    )
    ticker_history_df = ticker_history_df.where(pd.notnull(ticker_history_df), None)

    ticker_history_df = ticker_history_df.rename(columns=SOURCE_TO_SQL_COLUMNS_NAMES)

    return ticker_history_df


if __name__ == "__main__":
    connection_string = cu.get_db_connection_url_from_env()
    engine = cu.create_engine(connection_string)

    ab_ticker_series = pd.read_sql("SELECT ticker FROM source.ABTicker", engine).ticker
    tickers = yf.Tickers(" ".join(ab_ticker_series))

    ticker_df = get_ticker_reference_data(tickers)

    with engine.begin() as con:
        con.execute(f"TRUNCATE TABLE {TABLE_SCHEMA}.{TICKER_TABLE_NAME}")
        ticker_df.to_sql(
            TICKER_TABLE_NAME,
            con,
            TABLE_SCHEMA,
            if_exists="append",
            index=False,
            chunksize=8000,
        )

    ticker_history_df = get_ticker_history_as_frame(tickers)

    with engine.begin() as con:
        con.execute(f"TRUNCATE TABLE {TABLE_SCHEMA}.{HISTORY_TABLE_NAME}")
        ticker_history_df.to_sql(
            HISTORY_TABLE_NAME,
            con,
            TABLE_SCHEMA,
            if_exists="append",
            index=False,
            chunksize=8000,
        )
