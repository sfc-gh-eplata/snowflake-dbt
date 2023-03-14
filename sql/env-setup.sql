-- 0.- Cleanup
USE ROLE SYSADMIN;
DROP WAREHOUSE IF EXISTS XSMALL_SNOWPARK_DBT;
DROP WAREHOUSE IF EXISTS SMALL_SNOWPARK_DBT;
DROP DATABASE IF EXISTS SNOWPARK_DBT;
DROP DATABASE IF EXISTS SNOWPARK_DBT_OTHER_DB;

USE ROLE USERADMIN;
DROP USER IF EXISTS DBTDEMO;

-- 1.- Creating VW
USE ROLE SYSADMIN;
CREATE OR REPLACE WAREHOUSE XSMALL_SNOWPARK_DBT WITH COMMENT = 'X-Small: max cluster 3'
    WAREHOUSE_SIZE = 'XSMALL'
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 3
    SCALING_POLICY = 'ECONOMY';

USE ROLE SYSADMIN;
CREATE OR REPLACE WAREHOUSE SMALL_SNOWPARK_DBT WITH COMMENT = 'Small: max cluster 3'
    WAREHOUSE_SIZE = 'SMALL'
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 3
    SCALING_POLICY = 'ECONOMY';

-- 2.- Creating Databases
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE SNOWPARK_DBT COMMENT = 'SNOWPARK_DBT DEMO'
 DATA_RETENTION_TIME_IN_DAYS = 3
 MAX_DATA_EXTENSION_TIME_IN_DAYS = 3;

CREATE OR REPLACE DATABASE SNOWPARK_DBT_OTHER_DB COMMENT = 'SNOWPARK_DBT DEMO'
 DATA_RETENTION_TIME_IN_DAYS = 3
 MAX_DATA_EXTENSION_TIME_IN_DAYS = 3;

-- 3.- Creating schemas
CREATE OR REPLACE SCHEMA SNOWPARK_DBT.RAW WITH MANAGED ACCESS
COMMENT = 'This contains RAW data';

CREATE OR REPLACE SCHEMA SNOWPARK_DBT.STG WITH MANAGED ACCESS
COMMENT = 'This contains STG data';

-- 4.- Creating simple Snowpark python Stored Procedure
USE ROLE SYSADMIN;
CREATE OR REPLACE PROCEDURE SNOWPARK_DBT.STG.REPLICATE_LIMIT(from_table STRING, to_table STRING, count INT)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'run'
COMMENT = 'Simple transformation Python Stored Procedure'
AS
$$
def run(session, from_table, to_table, count):
  session.table(from_table).limit(count).write.save_as_table(to_table)
  return "SUCCESS"
$$;

-- 5.- Creating a bit more complex Snowpark python Stored Procedure
USE ROLE SYSADMIN;
CREATE OR REPLACE PROCEDURE SNOWPARK_DBT.STG.TOP_IMDB_SCORE_MOVIES(table_credits STRING, table_titles STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('snowflake-snowpark-python', 'numpy', 'pandas')
HANDLER = 'run'
COMMENT = 'Getting top IMDB_SCORE movies'
AS
$$
def run(session, table_credits, table_titles):
  import pandas as pd
  # Loading tables
  sp_df_credits = session.table(table_credits)
  sp_df_titles = session.table(table_titles)

  # Transforming to pandas dfs
  df_credits = sp_df_credits.to_pandas()
  df_titles = sp_df_titles.to_pandas()

  # Merging the dataframes
  df_merge = pd.merge(df_titles, df_credits, on="ID", how="inner")
  df_merge['AGGREGATOR'] = 1
  df_merge = df_merge.groupby(['TITLE','RELEASE_YEAR','IMDB_SCORE']).agg({'AGGREGATOR': 'sum'}).sort_values(by = ['IMDB_SCORE'], ascending=[False])[1:50]
  df_merge.reset_index(inplace=True)
  df_merge.columns = ['TITLE', 'RELEASE_YEAR', 'IMDB_SCORE', 'NUMBER_OF_ACTORS']

  df_merge['TITLE'] = df_merge['TITLE'].apply(lambda x: x.upper())

  # Converting pandas df into a snowpark dataframe
  df = session.create_dataframe(df_merge)
  df.write.save_as_table(table_name='STG_TOP_IMDB_SCORE_MOVIES',mode="overwrite")

  return "SUCCESS"
$$;

USE ROLE SYSADMIN;
CREATE TABLE SNOWPARK_DBT_OTHER_DB.PUBLIC.SOURCE_TABLE_OTHER_DB (
   NAME VARCHAR(15),
   LAST_NAME VARCHAR(25)
);
INSERT INTO SNOWPARK_DBT_OTHER_DB.PUBLIC.SOURCE_TABLE_OTHER_DB (NAME, LAST_NAME) VALUES ('ENRIQUE','PLATA');
INSERT INTO SNOWPARK_DBT_OTHER_DB.PUBLIC.SOURCE_TABLE_OTHER_DB (NAME, LAST_NAME) VALUES ('HOPE','BLOOME');

USE ROLE USERADMIN;

CREATE USER IF NOT EXISTS DBTDEMO
 LOGIN_NAME = 'DBTDEMO'
 DISPLAY_NAME = 'DBTDEMO'
 PASSWORD = ''
 DEFAULT_ROLE = SYSTEMADMIN
 DEFAULT_WAREHOUSE = XSMALL_SNOWPARK_DBT
 DEFAULT_NAMESPACE = SNOWPARK_DBT
 MUST_CHANGE_PASSWORD = FALSE;

USE ROLE SECURITYADMIN;
GRANT ROLE SYSADMIN TO USER DBTDEMO;
