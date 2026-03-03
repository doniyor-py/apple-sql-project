-- ============================================================
--  Q26–Q30: Advanced — Window Functions & CTEs
-- ============================================================

-- Q26. Rank products by revenue within each region
SELECT
  region,
  product_name,
  category,
  ROUND(SUM(revenue_usd), 2) AS revenue_usd,
  RANK() OVER (
    PARTITION BY region
    ORDER BY SUM(revenue_usd) DESC
  ) AS revenue_rank
FROM apple_sales
GROUP BY region, product_name, category
ORDER BY region, revenue_rank
LIMIT 30;

-- Q27. 3-month rolling average of revenue
WITH monthly AS (
  SELECT
    DATE_FORMAT(sale_date, '%Y-%m-01') AS month_start,
    ROUND(SUM(revenue_usd), 2)         AS revenue_usd
  FROM apple_sales
  GROUP BY DATE_FORMAT(sale_date, '%Y-%m-01')
)
SELECT
  month_start,
  revenue_usd,
  ROUND(AVG(revenue_usd) OVER (
    ORDER BY month_start
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ), 2) AS rolling_3mo_avg,
  ROUND(revenue_usd - AVG(revenue_usd) OVER (
    ORDER BY month_start
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ), 2) AS diff_from_avg
FROM monthly
ORDER BY month_start;

-- Q28. Top 3 cities per region by units sold
WITH city_units AS (
  SELECT
    region,
    city,
    country,
    SUM(units_sold)  AS units_sold,
    ROUND(SUM(revenue_usd), 2) AS revenue_usd,
    ROW_NUMBER() OVER (
      PARTITION BY region
      ORDER BY SUM(units_sold) DESC
    ) AS rn
  FROM apple_sales
  GROUP BY region, city, country
)
SELECT
  region,
  rn AS rank_in_region,
  city,
  country,
  units_sold,
  revenue_usd
FROM city_units
WHERE rn <= 3
ORDER BY region, rn;

-- Q29. Running total of revenue by sales channel per year
SELECT
  year,
  sales_channel,
  month,
  ROUND(SUM(revenue_usd), 2) AS monthly_revenue,
  ROUND(SUM(SUM(revenue_usd)) OVER (
    PARTITION BY year, sales_channel
    ORDER BY FIELD(month,
      'January','February','March','April','May','June',
      'July','August','September','October','November','December')
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ), 2) AS running_total
FROM apple_sales
GROUP BY year, sales_channel, month
ORDER BY year, sales_channel, FIELD(month,
  'January','February','March','April','May','June',
  'July','August','September','October','November','December');

-- Q30. For each product, find the quarter where it hit
--      its peak revenue
WITH product_quarterly AS (
  SELECT
    product_name,
    category,
    year,
    quarter,
    ROUND(SUM(revenue_usd), 2) AS revenue_usd
  FROM apple_sales
  GROUP BY product_name, category, year, quarter
),
with_rank AS (
  SELECT
    product_name,
    category,
    year,
    quarter,
    revenue_usd,
    RANK() OVER (
      PARTITION BY product_name
      ORDER BY revenue_usd DESC
    ) AS rnk
  FROM product_quarterly
)
SELECT
  product_name,
  category,
  year        AS peak_year,
  quarter     AS peak_quarter,
  revenue_usd AS peak_revenue
FROM with_rank
WHERE rnk = 1
ORDER BY peak_revenue DESC;