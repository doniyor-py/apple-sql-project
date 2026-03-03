-- ============================================================
--  Apple Global Sales
--  Theme: Sales Performance
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- Q1. What is the total revenue by year and quarter?
-- ─────────────────────────────────────────────────────────────
SELECT
  year,
  quarter,
  COUNT(*)                        AS transactions,
  SUM(units_sold)                 AS units_sold,
  ROUND(SUM(revenue_usd), 2)      AS revenue_usd
FROM apple_sales
GROUP BY year, quarter
ORDER BY year, quarter;

-- ─────────────────────────────────────────────────────────────
-- Q2. Which month consistently generates the highest revenue
--     across all years?
-- ─────────────────────────────────────────────────────────────
SELECT
  month,
  ROUND(SUM(CASE WHEN year = 2022 THEN revenue_usd ELSE 0 END), 2) AS rev_2022,
  ROUND(SUM(CASE WHEN year = 2023 THEN revenue_usd ELSE 0 END), 2) AS rev_2023,
  ROUND(SUM(CASE WHEN year = 2024 THEN revenue_usd ELSE 0 END), 2) AS rev_2024,
  ROUND(SUM(revenue_usd), 2)                                        AS total_revenue
FROM apple_sales
GROUP BY month
ORDER BY total_revenue DESC;

-- ─────────────────────────────────────────────────────────────
-- Q3. Which sales channel contributes the most revenue?
-- ─────────────────────────────────────────────────────────────
SELECT
  sales_channel,
  COUNT(*)                        AS transactions,
  ROUND(SUM(revenue_usd), 2)      AS revenue_usd,
  ROUND(SUM(revenue_usd) * 100.0 /
    SUM(SUM(revenue_usd)) OVER (), 2) AS revenue_pct,
  ROUND(AVG(discount_pct), 2)     AS avg_discount_pct,
  ROUND(AVG(customer_rating), 2)  AS avg_rating
FROM apple_sales
GROUP BY sales_channel
ORDER BY revenue_usd DESC;

-- ─────────────────────────────────────────────────────────────
-- Q4. What is the month-over-month revenue growth rate?
-- ─────────────────────────────────────────────────────────────
WITH monthly_revenue AS (
  SELECT
    year,
    month,
    DATE_FORMAT(sale_date, '%Y-%m-01')  AS month_start,
    ROUND(SUM(revenue_usd), 2)          AS revenue_usd
  FROM apple_sales
  GROUP BY year, month, DATE_FORMAT(sale_date, '%Y-%m-01')
),
with_lag AS (
  SELECT
    year,
    month,
    revenue_usd,
    LAG(revenue_usd) OVER (ORDER BY month_start) AS prev_month_revenue
  FROM monthly_revenue
)
SELECT
  year,
  month,
  revenue_usd,
  prev_month_revenue,
  ROUND((revenue_usd - prev_month_revenue)
    / prev_month_revenue * 100, 2)      AS mom_growth_pct
FROM with_lag
ORDER BY year, FIELD(month,
  'January','February','March','April','May','June',
  'July','August','September','October','November','December');

-- ─────────────────────────────────────────────────────────────
-- Q5. What % of transactions use a discount, and what is the
--     average discount by sales channel?
-- ─────────────────────────────────────────────────────────────

-- Overall discounted vs full price
SELECT
  SUM(CASE WHEN discount_pct > 0 THEN 1 ELSE 0 END)   AS discounted_txns,
  SUM(CASE WHEN discount_pct = 0 THEN 1 ELSE 0 END)   AS full_price_txns,
  COUNT(*)                                             AS total_txns,
  ROUND(SUM(CASE WHEN discount_pct > 0 THEN 1 ELSE 0 END)
    * 100.0 / COUNT(*), 2)                             AS discounted_pct
FROM apple_sales;

-- Average discount by channel
SELECT
  sales_channel,
  COUNT(*)                                             AS transactions,
  SUM(CASE WHEN discount_pct > 0 THEN 1 ELSE 0 END)   AS discounted_txns,
  ROUND(AVG(discount_pct), 2)                          AS avg_discount_pct,
  ROUND(SUM(CASE WHEN discount_pct > 0 THEN 1 ELSE 0 END)
    * 100.0 / COUNT(*), 2)                             AS discounted_txn_pct
FROM apple_sales
GROUP BY sales_channel
ORDER BY avg_discount_pct DESC;









