{{
    config(
        tags=["Snowpark"],
        pre_hook = [
            "DROP TABLE IF EXISTS {{ this }};",
            "CALL STG.REPLICATE_LIMIT('{{ ref('stg_market_region') }}', '{{ this }}', 50);"
        ]
    )
}}
WITH LINEAGE AS (
    SELECT * FROM {{ ref('stg_market_region') }}
)
SELECT *
FROM {{ this }}
