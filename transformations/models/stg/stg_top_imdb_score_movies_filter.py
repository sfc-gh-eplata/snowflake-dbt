from snowflake.snowpark.functions import col


def model(dbt, session):
    dbt.config(materialized="table", transient=False, tags=["Snowpark"])

    # Selecting columns and filter rows
    df = dbt.ref("stg_top_imdb_score_movies").select(("RELEASE_YEAR", "NUMBER_OF_ACTORS"))\
        .filter((col("RELEASE_YEAR") >= 2000))

    # Grouping and getting MAX values
    df = df.groupBy(col("RELEASE_YEAR")).max(col("NUMBER_OF_ACTORS")).sort(col("RELEASE_YEAR"))
    df = df.select(col("RELEASE_YEAR"), col("MAX(NUMBER_OF_ACTORS)").as_("NUMBER_OF_ACTORS"))

    return df
