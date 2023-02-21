{{
    config(
     materialized='ephemeral'
    )
}}
WITH LINEAGE AS (
    SELECT * FROM {{ ref('stg_market_region_enhance') }}
)
SELECT MARKET_REGION_NAME, COUNT(*) AS NUMBER_REGION
FROM LINEAGE
GROUP BY MARKET_REGION_NAME
HAVING COUNT(*)>4
