-- ============================================================
--  Q16–Q20: Customer Insights
-- ============================================================

-- Q16. Which customer segment generates the most revenue?
SELECT
  customer_segment,
  COUNT(*) AS transactions,
  SUM(units_sold) AS units_sold,
  ROUND(SUM(revenue_usd), 2) AS revenue_usd,
  ROUND(SUM(revenue_usd) * 100.0 /
    SUM(SUM(revenue_usd)) OVER (), 2) AS revenue_pct,
  ROUND(AVG(revenue_usd), 2) AS avg_transaction_usd
FROM apple_sales
GROUP BY customer_segment
ORDER BY revenue_usd DESC;

-- Q17. Preferred payment method by age group
SELECT
  customer_age_group,
  payment_method,
  COUNT(*) AS transactions,
  ROUND(COUNT(*) * 100.0 /
    SUM(COUNT(*)) OVER (PARTITION BY customer_age_group), 2) AS pct_within_age_group
FROM apple_sales
GROUP BY customer_age_group, payment_method
ORDER BY FIELD(customer_age_group,
  '18–24','25–34','35–44','45–54','55+'),
  transactions DESC;

-- Q18. Which age group buys the most premium products?
SELECT
  customer_age_group,
  COUNT(*) AS transactions,
  ROUND(AVG(unit_price_usd), 2) AS avg_unit_price,
  ROUND(MAX(unit_price_usd), 2) AS max_unit_price,
  ROUND(SUM(revenue_usd), 2) AS total_revenue,
  SUM(CASE WHEN unit_price_usd >= 1000 THEN 1 ELSE 0 END) AS premium_txns,
  ROUND(SUM(CASE WHEN unit_price_usd >= 1000 THEN 1 ELSE 0 END)
    * 100.0 / COUNT(*), 2) AS premium_pct
FROM apple_sales
GROUP BY customer_age_group
ORDER BY FIELD(customer_age_group,
  '18–24','25–34','35–44','45–54','55+');

-- Q19. What % of iPhone buyers were previously on Android vs iOS?
SELECT
  previous_device_os,
  COUNT(*) AS iphone_buyers,
  ROUND(COUNT(*) * 100.0 /
    SUM(COUNT(*)) OVER (), 2) AS pct
FROM apple_sales
WHERE category = 'iPhone'
  AND previous_device_os IS NOT NULL
GROUP BY previous_device_os
ORDER BY iphone_buyers DESC;

-- Q20. Which customer segment has the highest return rate?
SELECT
  customer_segment,
  COUNT(*) AS total_transactions,
  SUM(CASE WHEN return_status = 'Returned'  THEN 1 ELSE 0 END) AS returned,
  SUM(CASE WHEN return_status = 'Exchanged' THEN 1 ELSE 0 END) AS exchanged,
  SUM(CASE WHEN return_status != 'Kept'     THEN 1 ELSE 0 END) AS total_not_kept,
  ROUND(SUM(CASE WHEN return_status = 'Returned' THEN 1 ELSE 0 END)
    * 100.0 / COUNT(*), 2) AS return_rate_pct,
  ROUND(SUM(CASE WHEN return_status != 'Kept' THEN 1 ELSE 0 END)
    * 100.0 / COUNT(*), 2) AS return_exchange_rate_pct
FROM apple_sales
GROUP BY customer_segment
ORDER BY return_rate_pct DESC;