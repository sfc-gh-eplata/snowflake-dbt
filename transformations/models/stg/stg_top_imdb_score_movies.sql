{{
    config(
        tags=["Snowpark"],
        transient=false,
        pre_hook = [
            "DROP TABLE IF EXISTS {{ this }};",
            "CALL STG.TOP_IMDB_SCORE_MOVIES('{{ ref('raw_credits') }}', '{{ ref('raw_titles') }}');"
        ]
    )
}}
WITH credits AS (
    SELECT * FROM {{ ref('raw_credits') }}
),
titles AS (
    SELECT * FROM {{ ref('raw_titles') }}
)
SELECT *
FROM {{ this }}
