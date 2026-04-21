# Power BI Dashboard Build Guide
**Project:** Customer Churn Intelligence System — Telecom  
**File to load:** `data/telco_churn_scored.csv`

---

## Step 1: Load the Data

1. Open **Power BI Desktop**
2. Click **Home → Get Data → Text/CSV**
3. Navigate to `data/telco_churn_scored.csv` → Load
4. In Power Query editor, verify column types:
   - `tenure`, `MonthlyCharges`, `TotalCharges`, `churn_probability` → Decimal/Whole Number
   - `Churn`, `SeniorCitizen` → Whole Number
   - All text columns → Text
5. Click **Close & Apply**

---

## Step 2: Create These DAX Measures

In the Data pane, right-click the table → **New Measure**. Create each of these:

```dax
-- 1. Total Customers
Total Customers = COUNTROWS(customers)

-- 2. Total Churned
Total Churned = CALCULATE(COUNTROWS(customers), customers[Churn] = 1)

-- 3. Churn Rate %
Churn Rate % = DIVIDE([Total Churned], [Total Customers], 0)

-- 4. Monthly Revenue at Risk
Revenue at Risk = 
CALCULATE(
    SUM(customers[MonthlyCharges]),
    customers[Churn] = 1
)

-- 5. Average Tenure (months)
Avg Tenure = AVERAGE(customers[tenure])

-- 6. High Risk Customer Count
High Risk Count = 
CALCULATE(
    COUNTROWS(customers),
    customers[risk_tier] = "High Risk",
    customers[Churn] = 0
)

-- 7. Avg Churn Probability
Avg Churn Probability = AVERAGE(customers[churn_probability])
```

---

## Step 3: Build Page 1 — Executive Summary

**Layout:** 2 rows of KPI cards at top, charts below

### KPI Cards (Row 1 — 4 cards across)
| Card | Measure | Format |
|------|---------|--------|
| Total Customers | Total Customers | 7,043 |
| Churn Rate | Churn Rate % | 26.5% |
| Revenue at Risk | Revenue at Risk | $139K |
| High Risk Active | High Risk Count | 1,234 |

### Charts (Row 2)
- **Donut chart** — Churn Rate % (Churned vs Retained) → field: Churn
- **Bar chart** — Churn Rate by Contract Type → X: Contract, Y: Churn Rate % measure
- **Line chart** — Churn by Tenure Bucket → X: tenure_bucket, Y: Churn Rate %

---

## Step 4: Build Page 2 — Risk Tier Analysis

- **Clustered bar** — Risk Tier vs Customer Count → Axis: risk_tier, Value: Total Customers
- **Table visual** — Top 50 high-risk active customers:
  - Columns: customerID, Contract, tenure, MonthlyCharges, churn_probability, risk_tier
  - Filter: Churn = 0 (active only), risk_tier = High Risk
  - Sort by churn_probability descending
- **Treemap** — Revenue at Risk by Contract + risk_tier

---

## Step 5: Build Page 3 — Churn Drivers

- **Stacked bar** — Churn by Payment Method → X: PaymentMethod, Y: count, Legend: Churn
- **Scatter plot** — Monthly Charges vs Churn Probability → X: MonthlyCharges, Y: churn_probability, colour: risk_tier
- **Bar** — Churn by Internet Service Type

---

## Step 6: Add Slicers (Filters)

Add these slicers to Page 1 so the dashboard is interactive:
- **Contract type** — slicer (tile style)
- **risk_tier** — dropdown slicer
- **tenure_bucket** — dropdown slicer

---

## Step 7: Formatting Tips

- **Theme:** Use Power BI's built-in "Executive" or "Accessible Default" theme
- **Font:** Segoe UI throughout
- **Highlight colour:** Orange (#DD8452) for churned/risk items, Blue (#4472C4) for retained
- **Add a text box title** at the top of each page:
  - Page 1: `Customer Churn Intelligence Dashboard — IBM Telco`
  - Page 2: `Customer Risk Tier Analysis`
  - Page 3: `Churn Driver Breakdown`
- **Add your name** as a subtitle on Page 1: `Analyst: Prathmesh Joshi`

---

## Step 8: Export for GitHub

1. **Save the .pbix file** to `dashboard/telecom_churn_dashboard.pbix`
2. **Take a screenshot** of Page 1 → save as `images/dashboard_preview.png`
3. This screenshot goes into your README (there is already a placeholder for it)

---

*For Power BI help: docs.microsoft.com/power-bi*
