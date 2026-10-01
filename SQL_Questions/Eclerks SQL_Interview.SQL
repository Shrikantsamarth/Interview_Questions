
Q) IF i WANT TO FIND THE YOY GROWTH OF PRODUCTS IN TWO TABLES .
TABLE 1  is A1 - YEAR 2025, PRODUCTS, SALES 
TABLE 2 is B1 - YEAR 2026, PRODUCTS, SALES

----------Solution----------

WITH s25 AS (
    SELECT products, SUM(sales) AS sales_2025
    FROM A1
    GROUP BY products
),
s26 AS (
    SELECT products, SUM(sales) AS sales_2026
    FROM B1
    GROUP BY products
)
SELECT
    COALESCE(s25.products, s26.products)   AS products,
    COALESCE(s25.sales_2025, 0)            AS sales_2025,
    COALESCE(s26.sales_2026, 0)            AS sales_2026,
    COALESCE(s26.sales_2026, 0)
      - COALESCE(s25.sales_2025, 0)        AS sales_difference,
    ROUND(
        (COALESCE(s26.sales_2026, 0) - COALESCE(s25.sales_2025, 0)) * 100.0
        / NULLIF(s25.sales_2025, 0), 2
    ) AS yoy_growth_pct
FROM s25
FULL OUTER JOIN s26
    ON s25.products = s26.products
ORDER BY yoy_growth_pct DESC NULLS LAST;
