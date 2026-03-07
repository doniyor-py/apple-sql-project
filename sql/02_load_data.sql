SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '/Users/mac/Desktop/SQL_project/apple_global_sales_dataset.csv'
INTO TABLE apple_sales
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS                         
(
  sale_id,
  sale_date,
  year,
  quarter,
  month,
  country,
  region,
  city,
  product_name,
  category,
  @storage_raw,
  color,
  unit_price_usd,
  discount_pct,
  units_sold,
  discounted_price_usd,
  revenue_usd,
  currency,
  fx_rate_to_usd,
  revenue_local_currency,
  sales_channel,
  payment_method,
  customer_segment,
  customer_age_group,
  @prev_os_raw,
  @rating_raw,
  return_status
)
SET

UPDATE apple_sales SET storage            = NULL WHERE storage            = 'N/A';
UPDATE apple_sales SET previous_device_os = NULL WHERE previous_device_os = 'N/A';
UPDATE apple_sales SET customer_rating    = NULL WHERE customer_rating    IS NULL;

-- Total row count (expect 11,500)
SELECT COUNT(*) AS total_rows FROM apple_sales;

SELECT
  COUNT(*) AS total,
  SUM(CASE WHEN storage IS NULL THEN 1 ELSE 0 END)            AS null_storage,
  SUM(CASE WHEN previous_device_os IS NULL THEN 1 ELSE 0 END) AS null_prev_os,
  SUM(CASE WHEN customer_rating IS NULL THEN 1 ELSE 0 END)    AS null_rating
FROM apple_sales;

SELECT * FROM apple_sales LIMIT 5;
