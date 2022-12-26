import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL



if __name__ == 'main':
    connection_url = URL.create("mssql+pyodbc", query={'odbc_connect': connection_string})

    engine = create_engine(connection_url, fast_executemany=True)

    mort_rate_df = pd.read_csv('./etlshare/MORTGAGE15US.csv')

    mort_rate_df = mort_rate_df.assign(
        DATE = pd.to_datetime(mort_rate_df.DATE)
    )

    year_rate_df = mort_rate_df.groupby(pd.Grouper(key='DATE', freq='365D')).MORTGAGE15US.mean()
    year_rate_df.to_sql('yearly_mortgage_rate', engine, schema='dbo')