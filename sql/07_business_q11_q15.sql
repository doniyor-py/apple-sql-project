-- ============================================================
--  Q11–Q15: Product Analysis
-- ============================================================

-- Q11. Revenue contribution % per category
SELECT
  category,
  COUNT(*) AS transactions,
  SUM(units_sold) AS units_sold,
  ROUND(SUM(revenue_usd), 2) AS revenue_usd,
  ROUND(SUM(revenue_usd) * 100.0 /
    SUM(SUM(revenue_usd)) OVER (), 2) AS revenue_pct,
  ROUND(AVG(unit_price_usd), 2) AS avg_unit_price
FROM apple_sales
GROUP BY category
ORDER BY revenue_usd DESC;

-- Q12. Top 5 revenue products per category
WITH ranked_products AS (
  SELECT
    category, product_name,
    COUNT(*) AS transactions,
    SUM(units_sold) AS units_sold,
    ROUND(SUM(revenue_usd), 2) AS revenue_usd,
    ROUND(AVG(unit_price_usd), 2) AS avg_price,
    RANK() OVER (PARTITION BY category ORDER BY SUM(revenue_usd) DESC) AS rnk
  FROM apple_sales
  GROUP BY category, product_name
)
SELECT category, rnk, product_name, transactions, units_sold, revenue_usd, avg_price
FROM ranked_products
WHERE rnk <= 5
ORDER BY category, rnk;

-- Q13. Storage variants for iPhones and iPads
SELECT
  category, storage,
  COUNT(*) AS transactions,
  SUM(units_sold) AS units_sold,
  ROUND(SUM(revenue_usd), 2) AS revenue_usd,
  ROUND(SUM(units_sold) * 100.0 /
    SUM(SUM(units_sold)) OVER (PARTITION BY category), 2) AS units_pct
FROM apple_sales
WHERE category IN ('iPhone', 'iPad') AND storage IS NOT NULL
GROUP BY category, storage
ORDER BY category, units_sold DESC;

-- Q14. Top 3 colors per category
WITH ranked_colors AS (
  SELECT
    category, color,
    SUM(units_sold) AS units_sold,
    ROUND(SUM(revenue_usd), 2) AS revenue_usd,
    RANK() OVER (PARTITION BY category ORDER BY SUM(units_sold) DESC) AS rnk
  FROM apple_sales
  GROUP BY category, color
)
SELECT category, rnk, color, units_sold, revenue_usd
FROM ranked_colors
WHERE rnk <= 3
ORDER BY category, rnk;

-- Q15. Category revenue share shift year over year
WITH yearly AS (
  SELECT year, category,
    ROUND(SUM(revenue_usd), 2) AS revenue_usd
  FROM apple_sales
  GROUP BY year, category
),
with_pct AS (
  SELECT year, category, revenue_usd,
    ROUND(revenue_usd * 100.0 / SUM(revenue_usd) OVER (PARTITION BY year), 2) AS revenue_pct
  FROM yearly
),
with_lag AS (
  SELECT year, category, revenue_usd, revenue_pct,
    LAG(revenue_usd) OVER (PARTITION BY category ORDER BY year) AS prev_revenue,
    LAG(revenue_pct) OVER (PARTITION BY category ORDER BY year) AS prev_pct
  FROM with_pct
)
SELECT
  year, category, revenue_usd, revenue_pct AS share_pct,
  prev_revenue, prev_pct AS prev_share_pct,
  ROUND(revenue_usd - prev_revenue, 2) AS revenue_change,
  ROUND(revenue_pct - prev_pct, 2) AS share_change_pts
FROM with_lag
ORDER BY category, year;