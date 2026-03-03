-- ============================================================
--  Apple Global Sales Dataset — MySQL Schema
--  Database : apple_sales_db
--  Table    : apple_sales
--  Rows     : 11,500
--  Generated for: End-to-End SQL Project
-- ============================================================

-- 1. Create & select the database
CREATE DATABASE IF NOT EXISTS apple_sales_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE apple_sales_db;

-- 3. Create table
CREATE TABLE apple_sales (

  -- ── Identifiers & Time ──────────────────────────────────
  sale_id               CHAR(13)        NOT NULL,          -- e.g. APPL-00000001
  sale_date             DATE            NOT NULL,
  year                  SMALLINT        NOT NULL,          -- 2022 / 2023 / 2024
  quarter               CHAR(2)         NOT NULL,          -- Q1 / Q2 / Q3 / Q4
  month                 VARCHAR(10)     NOT NULL,          -- Full month name

  -- ── Geography ───────────────────────────────────────────
  country               VARCHAR(20)     NOT NULL,
  region                VARCHAR(15)     NOT NULL,
  city                  VARCHAR(25)     NOT NULL,

  -- ── Product ─────────────────────────────────────────────
  product_name          VARCHAR(35)     NOT NULL,
  category              VARCHAR(15)     NOT NULL,          -- iPhone / iPad / Mac / Apple Watch / AirPods / Accessories
  storage               VARCHAR(15)     NULL,              -- NULL for non-storage products
  color                 VARCHAR(20)     NOT NULL,

  -- ── Pricing ─────────────────────────────────────────────
  unit_price_usd        DECIMAL(10,2)   NOT NULL,
  discount_pct          DECIMAL(5,2)    NOT NULL DEFAULT 0.00,  -- 0, 2, 3, 5, 7, 10, 15
  units_sold            TINYINT         NOT NULL,          -- 1–8
  discounted_price_usd  DECIMAL(10,2)   NOT NULL,
  revenue_usd           DECIMAL(12,2)   NOT NULL,

  -- ── Currency ────────────────────────────────────────────
  currency              CHAR(3)         NOT NULL,
  fx_rate_to_usd        DECIMAL(12,4)   NOT NULL,
  revenue_local_currency DECIMAL(16,2)  NOT NULL,

  -- ── Transaction Details ──────────────────────────────────
  sales_channel         VARCHAR(25)     NOT NULL,
  payment_method        VARCHAR(20)     NOT NULL,

  -- ── Customer ────────────────────────────────────────────
  customer_segment      VARCHAR(15)     NOT NULL,          -- Individual / Business / Education / Government
  customer_age_group    VARCHAR(6)      NOT NULL,          -- 18–24 / 25–34 / 45–54 / 55+
  previous_device_os    VARCHAR(10)     NULL,              -- iPhone buyers only; NULL for others
  customer_rating       DECIMAL(3,1)    NULL,              -- 3.0–5.0; ~30% are NULL
  return_status         VARCHAR(10)     NOT NULL,          -- Kept / Returned / Exchanged

  -- ── Constraints ─────────────────────────────────────────
  PRIMARY KEY (sale_id),

  CONSTRAINT chk_quarter        CHECK (quarter IN ('Q1','Q2','Q3','Q4')),
  CONSTRAINT chk_category       CHECK (category IN ('iPhone','iPad','Mac','Apple Watch','AirPods','Accessories')),
  CONSTRAINT chk_discount       CHECK (discount_pct IN (0, 2, 3, 5, 7, 10, 15)),
  CONSTRAINT chk_units_sold     CHECK (units_sold BETWEEN 1 AND 8),
  CONSTRAINT chk_return_status  CHECK (return_status IN ('Kept','Returned','Exchanged')),
  CONSTRAINT chk_rating         CHECK (customer_rating IS NULL OR customer_rating BETWEEN 3.0 AND 5.0)

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Apple global sales transactions 2022–2024';


CREATE INDEX idx_sale_date      ON apple_sales (sale_date);
CREATE INDEX idx_year_quarter   ON apple_sales (year, quarter);
CREATE INDEX idx_region_country ON apple_sales (region, country);
CREATE INDEX idx_city           ON apple_sales (city);
CREATE INDEX idx_category       ON apple_sales (category);
CREATE INDEX idx_product_name   ON apple_sales (product_name);
CREATE INDEX idx_sales_channel  ON apple_sales (sales_channel);
CREATE INDEX idx_cust_segment   ON apple_sales (customer_segment);


DESCRIBE apple_sales;

