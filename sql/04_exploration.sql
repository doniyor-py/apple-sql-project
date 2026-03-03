-- ============================================================
--  1. DATASET OVERVIEW
-- ============================================================

-- 1A. Total rows, date range, years covered
SELECT
  COUNT(*)                    AS total_transactions,
  MIN(sale_date)              AS first_sale,
  MAX(sale_date)              AS last_sale,
  COUNT(DISTINCT year)        AS years_covered,
  COUNT(DISTINCT country)     AS countries,
  COUNT(DISTINCT city)        AS cities,
  COUNT(DISTINCT product_name)AS unique_products,
  COUNT(DISTINCT category)    AS categories
FROM apple_sales;

-- 1B. Transactions and revenue per year
SELECT
  year,
  COUNT(*)                        AS transactions,
  SUM(units_sold)                 AS total_units,
  ROUND(SUM(revenue_usd), 2)      AS total_revenue_usd,
  ROUND(AVG(revenue_usd), 2)      AS avg_transaction_usd
FROM apple_sales
GROUP BY year
ORDER BY year;

-- 1C. Transactions per quarter across all years
SELECT
  year,
  quarter,
  COUNT(*)                        AS transactions,
  ROUND(SUM(revenue_usd), 2)      AS revenue_usd
FROM apple_sales
GROUP BY year, quarter
ORDER BY year, quarter;

-- ============================================================
--  2. REVENUE SUMMARY
-- ============================================================

-- 2A. Overall revenue stats
SELECT
  ROUND(SUM(revenue_usd), 2)      AS total_revenue_usd,
  ROUND(AVG(revenue_usd), 2)      AS avg_revenue_per_txn,
  ROUND(MIN(revenue_usd), 2)      AS min_transaction,
  ROUND(MAX(revenue_usd), 2)      AS max_transaction,
  ROUND(STDDEV(revenue_usd), 2)   AS stddev_revenue
FROM apple_sales;

-- 2B. Revenue by month (all years combined)
SELECT
  month,
  COUNT(*)                        AS transactions,
  ROUND(SUM(revenue_usd), 2)      AS revenue_usd,
  ROUND(AVG(revenue_usd), 2)      AS avg_revenue
FROM apple_sales
GROUP BY month
ORDER BY FIELD(month,
  'January','February','March','April','May','June',
  'July','August','September','October','November','December');

-- ============================================================
--  3. PRODUCT & CATEGORY BREAKDOWN
-- ============================================================

-- 3A. Revenue and units by category
SELECT
  category,
  COUNT(*)                                                          AS transactions,
  SUM(units_sold)                                                   AS units_sold,
  ROUND(SUM(revenue_usd), 2)                                        AS revenue_usd,
  ROUND(SUM(revenue_usd) * 100.0 / SUM(SUM(revenue_usd)) OVER (), 2) AS revenue_pct,
  ROUND(AVG(unit_price_usd), 2)                                     AS avg_unit_price
FROM apple_sales
GROUP BY category
ORDER BY revenue_usd DESC;

-- 3B. Top 10 products by revenue
SELECT
  product_name,
  category,
  COUNT(*)                        AS transactions,
  SUM(units_sold)                 AS units_sold,
  ROUND(SUM(revenue_usd), 2)      AS revenue_usd,
  ROUND(AVG(unit_price_usd), 2)   AS avg_price
FROM apple_sales
GROUP BY product_name, category
ORDER BY revenue_usd DESC
LIMIT 10;

-- 3C. Bottom 5 products by revenue
SELECT
  product_name,
  category,
  COUNT(*)                        AS transactions,
  ROUND(SUM(revenue_usd), 2)      AS revenue_usd
FROM apple_sales
GROUP BY product_name, category
ORDER BY revenue_usd ASC
LIMIT 5;

-- ============================================================
--  4. GEOGRAPHY BREAKDOWN
-- ============================================================

-- 4A. Revenue by region
SELECT
  region,
  COUNT(DISTINCT country)         AS countries,
  COUNT(*)                        AS transactions,
  ROUND(SUM(revenue_usd), 2)      AS revenue_usd,
  ROUND(AVG(revenue_usd), 2)      AS avg_transaction
FROM apple_sales
GROUP BY region
ORDER BY revenue_usd DESC;

-- 4B. Top 10 countries by revenue
SELECT
  country,
  region,
  COUNT(*)                        AS transactions,
  ROUND(SUM(revenue_usd), 2)      AS revenue_usd
FROM apple_sales
GROUP BY country, region
ORDER BY revenue_usd DESC
LIMIT 10;

-- 4C. Top 10 cities by revenue
SELECT
  city,
  country,
  COUNT(*)                        AS transactions,
  ROUND(SUM(revenue_usd), 2)      AS revenue_usd
FROM apple_sales
GROUP BY city, country
ORDER BY revenue_usd DESC
LIMIT 10;

-- ============================================================
--  5. SALES CHANNEL & PAYMENT
-- ============================================================

-- 5A. Revenue by sales channel
SELECT
  sales_channel,
  COUNT(*)                        AS transactions,
  ROUND(SUM(revenue_usd), 2)      AS revenue_usd,
  ROUND(AVG(discount_pct), 2)     AS avg_discount_pct,
  ROUND(AVG(customer_rating), 2)  AS avg_rating
FROM apple_sales
GROUP BY sales_channel
ORDER BY revenue_usd DESC;

-- 5B. Payment method distribution
SELECT
  payment_method,
  COUNT(*)                        AS transactions,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM apple_sales), 2) AS pct,
  ROUND(SUM(revenue_usd), 2)      AS revenue_usd
FROM apple_sales
GROUP BY payment_method
ORDER BY transactions DESC;

-- ============================================================
--  6. CUSTOMER PROFILE
-- ============================================================

-- 6A. Revenue by customer segment
SELECT
  customer_segment,
  COUNT(*)                        AS transactions,
  ROUND(SUM(revenue_usd), 2)      AS revenue_usd,
  ROUND(AVG(revenue_usd), 2)      AS avg_transaction,
  ROUND(AVG(units_sold), 2)       AS avg_units
FROM apple_sales
GROUP BY customer_segment
ORDER BY revenue_usd DESC;

-- 6B. Revenue by age group
SELECT
  customer_age_group,
  COUNT(*)                        AS transactions,
  ROUND(SUM(revenue_usd), 2)      AS revenue_usd,
  ROUND(AVG(unit_price_usd), 2)   AS avg_unit_price
FROM apple_sales
GROUP BY customer_age_group
ORDER BY FIELD(customer_age_group,
  '18–24','25–34','35–44','45–54','55+');

-- 6C. Previous OS of iPhone buyers
SELECT
  previous_device_os,
  COUNT(*)                        AS iphone_buyers,
  ROUND(COUNT(*) * 100.0 /
    (SELECT COUNT(*) FROM apple_sales WHERE category = 'iPhone'), 2) AS pct
FROM apple_sales
WHERE category = 'iPhone'
GROUP BY previous_device_os
ORDER BY iphone_buyers DESC;

-- ============================================================
--  7. DISCOUNTS & RETURNS
-- ============================================================

-- 7A. Discount distribution
SELECT
  discount_pct,
  COUNT(*)                        AS transactions,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM apple_sales), 2) AS pct,
  ROUND(SUM(revenue_usd), 2)      AS revenue_usd
FROM apple_sales
GROUP BY discount_pct
ORDER BY discount_pct;

-- 7B. Return status overview
SELECT
  return_status,
  COUNT(*)                        AS transactions,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM apple_sales), 2) AS pct,
  ROUND(AVG(customer_rating), 2)  AS avg_rating
FROM apple_sales
GROUP BY return_status
ORDER BY transactions DESC;

-- 7C. Return rate by category
SELECT
  category,
  COUNT(*)                        AS total_transactions,
  SUM(CASE WHEN return_status = 'Returned' THEN 1 ELSE 0 END)  AS returned,
  SUM(CASE WHEN return_status = 'Exchanged' THEN 1 ELSE 0 END) AS exchanged,
  ROUND(SUM(CASE WHEN return_status != 'Kept' THEN 1 ELSE 0 END)
    * 100.0 / COUNT(*), 2)        AS return_exchange_rate_pct
FROM apple_sales
GROUP BY category
ORDER BY return_exchange_rate_pct DESC;

-- ============================================================
--  8. RATINGS OVERVIEW
-- ============================================================

SELECT
  ROUND(AVG(customer_rating), 2)  AS overall_avg_rating,
  ROUND(MIN(customer_rating), 1)  AS min_rating,
  ROUND(MAX(customer_rating), 1)  AS max_rating,
  COUNT(customer_rating)          AS rated_transactions,
  COUNT(*) - COUNT(customer_rating) AS unrated_transactions
FROM apple_sales;

-- Rating distribution
SELECT
  FLOOR(customer_rating) AS rating_floor,
  COUNT(*)               AS count,
  ROUND(COUNT(*) * 100.0 / COUNT(COUNT(*)) OVER (), 2) AS pct
FROM apple_sales
WHERE customer_rating IS NOT NULL
GROUP BY FLOOR(customer_rating)
ORDER BY rating_floor;