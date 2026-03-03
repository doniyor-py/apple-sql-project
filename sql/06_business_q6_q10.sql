-- ============================================================
--  Q6–Q10: Geography
-- ============================================================

-- Q6. Top 10 cities by revenue
SELECT
  city, country, region,
  COUNT(*) AS transactions,
  SUM(units_sold) AS units_sold,
  ROUND(SUM(revenue_usd), 2) AS revenue_usd,
  ROUND(SUM(revenue_usd) * 100.0 / SUM(SUM(revenue_usd)) OVER (), 2) AS revenue_pct
FROM apple_sales
GROUP BY city, country, region
ORDER BY revenue_usd DESC
LIMIT 10;

-- Q7. Which region has the highest avg transaction value?
SELECT
  region,
  COUNT(*) AS transactions,
  ROUND(SUM(revenue_usd), 2) AS total_revenue_usd,
  ROUND(AVG(revenue_usd), 2) AS avg_transaction_usd,
  ROUND(SUM(revenue_usd) / SUM(units_sold), 2) AS avg_revenue_per_unit
FROM apple_sales
GROUP BY region
ORDER BY avg_transaction_usd DESC;

-- Q8. Which countries have the highest return rates?
SELECT
  country, region,
  COUNT(*) AS total_transactions,
  SUM(CASE WHEN return_status = 'Returned'  THEN 1 ELSE 0 END) AS returned,
  SUM(CASE WHEN return_status = 'Exchanged' THEN 1 ELSE 0 END) AS exchanged,
  ROUND(SUM(CASE WHEN return_status != 'Kept' THEN 1 ELSE 0 END)
    * 100.0 / COUNT(*), 2) AS return_rate_pct
FROM apple_sales
GROUP BY country, region
HAVING COUNT(*) >= 50
ORDER BY return_rate_pct DESC
LIMIT 10;

-- Q9. Revenue split across regions per product category
SELECT
  region, category,
  ROUND(SUM(revenue_usd), 2) AS revenue_usd,
  ROUND(SUM(revenue_usd) * 100.0 /
    SUM(SUM(revenue_usd)) OVER (PARTITION BY region), 2) AS pct_within_region
FROM apple_sales
GROUP BY region, category
ORDER BY region, revenue_usd DESC;

-- Q10. Strongest currency markets by revenue
SELECT
  currency, country,
  COUNT(*) AS transactions,
  ROUND(AVG(fx_rate_to_usd), 4) AS avg_fx_rate,
  ROUND(SUM(revenue_usd), 2) AS revenue_usd,
  ROUND(SUM(revenue_usd) / COUNT(*), 2) AS avg_txn_usd
FROM apple_sales
GROUP BY currency, country
ORDER BY revenue_usd DESC
LIMIT 10;