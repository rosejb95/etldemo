# %%
import pandas as pd
from sklearn.datasets import load_iris
import pyodbc

FILE_FOLDER = r"/mnt/etlshare"
FILE_NAME = "iris_clean.pkl"


def main():

    # %%
    iris_df = load_iris(as_frame=True)['data']
    # %%
    iris_df.columns = iris_df.columns.str.replace(' (cm)', '', regex=False).str.replace('\s', '_')

    # %%
    iris_df.to_pickle(f"{FILE_FOLDER}/iris_clean.pkl")