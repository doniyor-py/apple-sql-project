-- ============================================================
--  Q21–Q25: Returns & Ratings
-- ============================================================

-- Q21. What is the return rate by product category?
SELECT
  category,
  COUNT(*) AS total_transactions,
  SUM(CASE WHEN return_status = 'Returned'  THEN 1 ELSE 0 END) AS returned,
  SUM(CASE WHEN return_status = 'Exchanged' THEN 1 ELSE 0 END) AS exchanged,
  SUM(CASE WHEN return_status = 'Kept'      THEN 1 ELSE 0 END) AS kept,
  ROUND(SUM(CASE WHEN return_status = 'Returned' THEN 1 ELSE 0 END)
    * 100.0 / COUNT(*), 2) AS return_rate_pct,
  ROUND(SUM(CASE WHEN return_status != 'Kept' THEN 1 ELSE 0 END)
    * 100.0 / COUNT(*), 2) AS return_exchange_rate_pct
FROM apple_sales
GROUP BY category
ORDER BY return_rate_pct DESC;

-- Q22. Do heavily discounted products get returned more often?
SELECT
  discount_pct,
  COUNT(*) AS total_transactions,
  SUM(CASE WHEN return_status = 'Returned'  THEN 1 ELSE 0 END) AS returned,
  SUM(CASE WHEN return_status = 'Exchanged' THEN 1 ELSE 0 END) AS exchanged,
  ROUND(SUM(CASE WHEN return_status = 'Returned' THEN 1 ELSE 0 END)
    * 100.0 / COUNT(*), 2) AS return_rate_pct,
  ROUND(SUM(CASE WHEN return_status != 'Kept' THEN 1 ELSE 0 END)
    * 100.0 / COUNT(*), 2) AS return_exchange_rate_pct
FROM apple_sales
GROUP BY discount_pct
ORDER BY discount_pct;

-- Q23. What is the avg customer rating per category?
SELECT
  category,
  COUNT(customer_rating)          AS rated_transactions,
  COUNT(*) - COUNT(customer_rating) AS unrated_transactions,
  ROUND(AVG(customer_rating), 2)  AS avg_rating,
  ROUND(MIN(customer_rating), 1)  AS min_rating,
  ROUND(MAX(customer_rating), 1)  AS max_rating,
  SUM(CASE WHEN customer_rating >= 4.5 THEN 1 ELSE 0 END) AS five_star_txns,
  SUM(CASE WHEN customer_rating < 3.5  THEN 1 ELSE 0 END) AS low_rating_txns
FROM apple_sales
GROUP BY category
ORDER BY avg_rating DESC;

-- Q24. Is there a correlation between customer rating
--      and return status?
SELECT
  return_status,
  COUNT(customer_rating)          AS rated_transactions,
  ROUND(AVG(customer_rating), 2)  AS avg_rating,
  ROUND(MIN(customer_rating), 1)  AS min_rating,
  ROUND(MAX(customer_rating), 1)  AS max_rating,
  SUM(CASE WHEN customer_rating >= 4.5 THEN 1 ELSE 0 END) AS high_ratings,
  SUM(CASE WHEN customer_rating < 3.5  THEN 1 ELSE 0 END) AS low_ratings
FROM apple_sales
WHERE customer_rating IS NOT NULL
GROUP BY return_status
ORDER BY avg_rating DESC;

-- Q25. Which sales channel has the worst return rate?
SELECT
  sales_channel,
  COUNT(*) AS total_transactions,
  SUM(CASE WHEN return_status = 'Returned'  THEN 1 ELSE 0 END) AS returned,
  SUM(CASE WHEN return_status = 'Exchanged' THEN 1 ELSE 0 END) AS exchanged,
  SUM(CASE WHEN return_status = 'Kept'      THEN 1 ELSE 0 END) AS kept,
  ROUND(SUM(CASE WHEN return_status = 'Returned' THEN 1 ELSE 0 END)
    * 100.0 / COUNT(*), 2) AS return_rate_pct,
  ROUND(SUM(CASE WHEN return_status != 'Kept' THEN 1 ELSE 0 END)
    * 100.0 / COUNT(*), 2) AS return_exchange_rate_pct,
  ROUND(AVG(customer_rating), 2)  AS avg_rating
FROM apple_sales
GROUP BY sales_channel
ORDER BY return_rate_pct DESC;