-- 1A. Duplicates
SELECT sale_id, COUNT(*) AS occurrences
FROM apple_sales GROUP BY sale_id HAVING COUNT(*) > 1;

-- 1B. NULL audit
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN storage IS NULL THEN 1 ELSE 0 END) AS null_storage,
  SUM(CASE WHEN previous_device_os IS NULL THEN 1 ELSE 0 END) AS null_prev_os,
  SUM(CASE WHEN customer_rating IS NULL THEN 1 ELSE 0 END) AS null_rating
FROM apple_sales;

-- 1C. Whitespace check
SELECT COUNT(*) AS whitespace_issues FROM apple_sales
WHERE country != TRIM(country) OR city != TRIM(city)
   OR product_name != TRIM(product_name) OR category != TRIM(category);

-- 1D. Date range check
SELECT MIN(sale_date) AS earliest, MAX(sale_date) AS latest FROM apple_sales;
SELECT COUNT(*) AS year_mismatches FROM apple_sales WHERE year != YEAR(sale_date);
SELECT COUNT(*) AS quarter_mismatches FROM apple_sales WHERE quarter != CONCAT('Q', QUARTER(sale_date));

-- 1E. Revenue logic check (discounted_price x units = revenue?)
SELECT COUNT(*) AS revenue_mismatches FROM apple_sales
WHERE ABS(revenue_usd - ROUND(discounted_price_usd * units_sold, 2)) > 0.05;

-- 1F. Bad numeric values
SELECT COUNT(*) AS bad_units FROM apple_sales WHERE units_sold < 1 OR units_sold > 8;
SELECT COUNT(*) AS bad_ratings FROM apple_sales
WHERE customer_rating IS NOT NULL AND (customer_rating < 3.0 OR customer_rating > 5.0);

-- 2A. Trim all whitespace
UPDATE apple_sales SET
  sale_id = TRIM(sale_id), country = TRIM(country), region = TRIM(region),
  city = TRIM(city), product_name = TRIM(product_name), category = TRIM(category),
  color = TRIM(color), sales_channel = TRIM(sales_channel),
  payment_method = TRIM(payment_method), customer_segment = TRIM(customer_segment),
  customer_age_group = TRIM(customer_age_group), return_status = TRIM(return_status);

-- 2B. Standardise month capitalisation
UPDATE apple_sales
SET month = CONCAT(UPPER(LEFT(month,1)), LOWER(SUBSTRING(month,2)));

SELECT COUNT(*) AS total, COUNT(DISTINCT sale_id) AS unique_ids FROM apple_sales;

SELECT 'Cleaning complete' AS status;

