{{
    config(
     materialized='table'
    )
}}
WITH LINEAGE AS (
    SELECT * FROM {{ source('sources','source_table_other_db') }}
)
SELECT *, 'Adding this value' AS NEW_COLUMN FROM LINEAGE
