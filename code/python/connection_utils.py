# %%
from dotenv import load_dotenv
from azure.storage.file import FileService
from sqlalchemy.engine import URL
from sqlalchemy import create_engine
import os

DOTENV_FILE_PATH = "/mnt/secret/dev.env"
load_dotenv(DOTENV_FILE_PATH)


def get_file_service_from_env():
    """
    Gets a file service from the secret config file.
    """


    file_service = FileService(
        account_name=os.environ['FILE_SHARE_ACCOUNT_NAME'], account_key=os.environ['FILE_SHARE_ACCOUNT_KEY']
    )

    return file_service


def fs_listdir(file_service, path: str, **ldf_kwargs):
    """Return a dict of files at a path for a file service."""

    file_dict = {
        file.name: file
        for file in file_service.list_directories_and_files(path, **ldf_kwargs)
    }

    return file_dict


def get_db_connection_url_from_env() -> str:
    "Gets a SQL Server ODBC connection string from env variables."

    DRIVER_NAME = "ODBC Driver 18 for SQL Server"
    DATABASE_NAME = "bdbdb"

    connection_string = (
        f"Driver={{{DRIVER_NAME}}};"
        f"Server={os.environ['SQL_SERVER_SERVER']},{os.environ['SQL_SERVER_PORT']};"
        f"Database={DATABASE_NAME};"
        f"Uid={os.environ['SQL_SERVER_UID']};"
        f"Pwd={os.environ['SQL_SERVER_PWD']};"
        "Encrypt=yes"
    )

    connection_url = URL.create(
        "mssql+pyodbc", query={"odbc_connect": connection_string}
    )
    
    return connection_url


def get_database_engine(connection_url: str, fast_executemany=True):
    """
    Given a SQL Server connection string create a sqlalchemy engine.
    """    


    engine = create_engine(connection_url, fast_executemany=fast_executemany)
    return engine
