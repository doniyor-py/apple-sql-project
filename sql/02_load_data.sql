USE apple_sales_db;

SET GLOBAL local_infile = 1;

-- Step 2: Load the CSV
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
  -- Convert 'N/A' strings to proper NULLs
  storage            = NULLIF(TRIM(@storage_raw), 'N/A'),
  previous_device_os = NULLIF(TRIM(@prev_os_raw), 'N/A'),
  -- Convert empty strings / 'NaN' to NULL for the rating
  customer_rating    = NULLIF(NULLIF(TRIM(@rating_raw), ''), 'NaN');

-- ============================================================
--  OPTION B: MySQL Workbench Table Data Import Wizard (GUI)
--  Use this if LOAD DATA INFILE gives permission errors
-- ============================================================
--
--  1. Right-click apple_sales table → Table Data Import Wizard
--  2. Browse to: apple_global_sales_dataset.csv
--  3. Select "Use existing table" → apple_sales_db.apple_sales
--  4. Map columns (should auto-map by name)
--  5. Click Next → Finish
--
--  After import, run the SET NULLs cleanup below manually.

-- ============================================================
--  Post-import: Clean up 'N/A' and 'NaN' if using Workbench
--  (Skip if you used LOAD DATA — SETs above already handle it)
-- ============================================================

UPDATE apple_sales SET storage            = NULL WHERE storage            = 'N/A';
UPDATE apple_sales SET previous_device_os = NULL WHERE previous_device_os = 'N/A';
UPDATE apple_sales SET customer_rating    = NULL WHERE customer_rating    IS NULL;

-- ============================================================
--  Verify the import
-- ============================================================

-- Total row count (expect 11,500)
SELECT COUNT(*) AS total_rows FROM apple_sales;

-- Check NULLs are correct
SELECT
  COUNT(*) AS total,
  SUM(CASE WHEN storage IS NULL THEN 1 ELSE 0 END)            AS null_storage,
  SUM(CASE WHEN previous_device_os IS NULL THEN 1 ELSE 0 END) AS null_prev_os,
  SUM(CASE WHEN customer_rating IS NULL THEN 1 ELSE 0 END)    AS null_rating
FROM apple_sales;

-- Sample rows
SELECT * FROM apple_sales LIMIT 5;