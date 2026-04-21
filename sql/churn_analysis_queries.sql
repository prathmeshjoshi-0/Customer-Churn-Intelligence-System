-- ============================================================
-- Customer Churn Intelligence System — SQL Analysis
-- Author: Prathmesh Joshi
-- Database: MySQL
-- Table: customers (loaded from telco_churn_clean.csv)
-- ============================================================

-- NOTE: Run Notebook 01 first to create the 'customers' table in MySQL.
-- Or import the clean CSV directly into MySQL Workbench.


-- ============================================================
-- QUERY 1: Overall Churn Rate
-- ============================================================
SELECT
    COUNT(*)                                         AS total_customers,
    SUM(Churn)                                       AS total_churned,
    COUNT(*) - SUM(Churn)                            AS total_retained,
    ROUND(SUM(Churn) / COUNT(*) * 100, 2)            AS churn_rate_pct,
    ROUND(SUM(MonthlyCharges), 0)                    AS total_monthly_revenue,
    ROUND(SUM(CASE WHEN Churn = 1 THEN MonthlyCharges ELSE 0 END), 0) AS revenue_at_risk
FROM customers;


-- ============================================================
-- QUERY 2: Churn Rate by Contract Type
-- One of the most important business findings
-- ============================================================
SELECT
    Contract,
    COUNT(*)                                         AS total_customers,
    SUM(Churn)                                       AS churned,
    ROUND(SUM(Churn) / COUNT(*) * 100, 2)            AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2)                    AS avg_monthly_charges,
    ROUND(AVG(tenure), 1)                            AS avg_tenure_months
FROM customers
GROUP BY Contract
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- QUERY 3: Cohort Analysis — Churn by Tenure Bucket
-- Shows which stage of customer lifecycle has highest churn
-- ============================================================
SELECT
    CASE
        WHEN tenure BETWEEN 0  AND 12 THEN '0-12 months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 months'
        ELSE '49+ months'
    END                                              AS tenure_bucket,
    COUNT(*)                                         AS customers,
    SUM(Churn)                                       AS churned,
    ROUND(SUM(Churn) / COUNT(*) * 100, 2)            AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2)                    AS avg_monthly_charges
FROM customers
GROUP BY tenure_bucket
ORDER BY
    CASE tenure_bucket
        WHEN '0-12 months'   THEN 1
        WHEN '13-24 months'  THEN 2
        WHEN '25-48 months'  THEN 3
        ELSE 4
    END;


-- ============================================================
-- QUERY 4: Churn by Payment Method
-- Electronic check users churn at much higher rates
-- ============================================================
SELECT
    PaymentMethod,
    COUNT(*)                                         AS total_customers,
    SUM(Churn)                                       AS churned,
    ROUND(SUM(Churn) / COUNT(*) * 100, 2)            AS churn_rate_pct
FROM customers
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- QUERY 5: Revenue at Risk Segmentation
-- How much monthly revenue is at risk from churners?
-- ============================================================
SELECT
    Contract,
    CASE
        WHEN MonthlyCharges < 35  THEN 'Low (<$35)'
        WHEN MonthlyCharges < 65  THEN 'Medium ($35–$65)'
        ELSE 'High (>$65)'
    END                                              AS charge_tier,
    COUNT(*)                                         AS customers,
    SUM(Churn)                                       AS churned,
    ROUND(SUM(Churn) / COUNT(*) * 100, 2)            AS churn_rate_pct,
    ROUND(SUM(CASE WHEN Churn = 1 THEN MonthlyCharges ELSE 0 END), 0) AS monthly_revenue_at_risk
FROM customers
GROUP BY Contract, charge_tier
ORDER BY monthly_revenue_at_risk DESC;


-- ============================================================
-- QUERY 6: CTE — Customer Risk Tier Segmentation
-- Segments each customer into High / Medium / Low risk
-- Based on contract type + tenure + charges
-- ============================================================
WITH risk_scoring AS (
    SELECT
        customerID,
        Contract,
        tenure,
        MonthlyCharges,
        Churn,
        -- Simple rule-based risk score (0-3)
        (CASE WHEN Contract = 'Month-to-month' THEN 1 ELSE 0 END +
         CASE WHEN tenure < 12 THEN 1 ELSE 0 END +
         CASE WHEN MonthlyCharges > 65 THEN 1 ELSE 0 END) AS risk_score
    FROM customers
),
risk_tiers AS (
    SELECT
        *,
        CASE
            WHEN risk_score >= 2 THEN 'High Risk'
            WHEN risk_score = 1  THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_tier
    FROM risk_scoring
)
SELECT
    risk_tier,
    COUNT(*)                                         AS customers,
    SUM(Churn)                                       AS actual_churned,
    ROUND(SUM(Churn) / COUNT(*) * 100, 2)            AS actual_churn_pct,
    ROUND(SUM(MonthlyCharges), 0)                    AS total_monthly_revenue,
    ROUND(SUM(CASE WHEN Churn = 1 THEN MonthlyCharges ELSE 0 END), 0) AS revenue_at_risk
FROM risk_tiers
GROUP BY risk_tier
ORDER BY
    CASE risk_tier
        WHEN 'High Risk'   THEN 1
        WHEN 'Medium Risk' THEN 2
        ELSE 3
    END;


-- ============================================================
-- QUERY 7: Window Function — Rank Customers by Monthly Charges
-- Within each contract type (who are the high-value churners?)
-- ============================================================
SELECT
    customerID,
    Contract,
    tenure,
    MonthlyCharges,
    Churn,
    RANK() OVER (PARTITION BY Contract ORDER BY MonthlyCharges DESC) AS spend_rank_in_contract,
    ROUND(AVG(MonthlyCharges) OVER (PARTITION BY Contract), 2)       AS avg_charges_in_contract,
    ROUND(MonthlyCharges - AVG(MonthlyCharges) OVER (PARTITION BY Contract), 2) AS diff_from_contract_avg
FROM customers
WHERE Churn = 1
ORDER BY Contract, spend_rank_in_contract
LIMIT 30;


-- ============================================================
-- QUERY 8: Churn Rate by Internet Service Type
-- ============================================================
SELECT
    InternetService,
    COUNT(*)                                         AS customers,
    SUM(Churn)                                       AS churned,
    ROUND(SUM(Churn) / COUNT(*) * 100, 2)            AS churn_rate_pct
FROM customers
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- QUERY 9: High-Risk Customer List for CRM Export
-- These are the customers to target FIRST for retention outreach
-- ============================================================
SELECT
    customerID,
    Contract,
    tenure,
    MonthlyCharges,
    TotalCharges,
    PaymentMethod,
    InternetService,
    Churn
FROM customers
WHERE
    Contract = 'Month-to-month'
    AND tenure < 12
    AND MonthlyCharges > 50
    AND Churn = 0     -- These are still ACTIVE customers — intervene now!
ORDER BY MonthlyCharges DESC
LIMIT 50;


-- ============================================================
-- QUERY 10: Executive Summary Query
-- Single query that gives leadership the full picture
-- ============================================================
SELECT
    'Total Customers'           AS metric, COUNT(*)                                  AS value FROM customers UNION ALL
SELECT 'Overall Churn Rate %',       ROUND(SUM(Churn)/COUNT(*)*100, 1)              FROM customers UNION ALL
SELECT 'Avg Tenure (months)',         ROUND(AVG(tenure), 1)                          FROM customers UNION ALL
SELECT 'Avg Monthly Charges ($)',     ROUND(AVG(MonthlyCharges), 2)                  FROM customers UNION ALL
SELECT 'Total Monthly Revenue ($)',   ROUND(SUM(MonthlyCharges), 0)                  FROM customers UNION ALL
SELECT 'Revenue at Risk ($/month)',   ROUND(SUM(CASE WHEN Churn=1 THEN MonthlyCharges ELSE 0 END), 0) FROM customers UNION ALL
SELECT 'Month-to-Month Churn %',      ROUND(SUM(CASE WHEN Contract='Month-to-month' AND Churn=1 THEN 1 ELSE 0 END) /
                                            NULLIF(SUM(CASE WHEN Contract='Month-to-month' THEN 1 ELSE 0 END),0)*100, 1) FROM customers;
