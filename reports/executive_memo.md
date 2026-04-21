# Executive Memo: Customer Churn Analysis
**To:** Head of Customer Success / VP Operations  
**From:** Prathmesh Joshi, Data Analyst  
**Date:** April 2026  
**Re:** Churn drivers and retention strategy — 3 actionable recommendations

---

## Situation

Our telecom customer base of 7,043 accounts shows a **26.5% churn rate** — nearly 1 in 4 customers is leaving. Monthly revenue at risk from churning customers totals approximately **$139,130/month** ($1.67M annualised). Since customer acquisition costs 5× more than retention, even a modest reduction in churn has a significant revenue impact.

---

## Key Findings

| Finding | Data |
|---------|------|
| Month-to-month customers churn at **42.7%** | vs 11.3% on 1-year, 2.8% on 2-year contracts |
| New customers (0–12 months tenure) churn at **47.7%** | The highest-risk lifecycle window |
| Electronic check users churn at **45.3%** | 2.4× higher than auto-pay customers (16.7%) |
| High-spend customers (>$65/month) with no add-ons show elevated churn | Paying more but getting less perceived value |
| Top churn predictors (model) | Contract type, tenure, monthly charges, internet service type |

---

## Recommendations

### 1. Launch a Month-3 Retention Offer (Priority: High)
Target all month-to-month customers in months 1–6 with a proactive loyalty incentive (10% discount or free service upgrade). A/B test simulation projects an **18% reduction in churn** in this segment.

- **Effort:** Low — CRM campaign, no infrastructure change
- **Impact:** ~180 customers saved per quarter, ~$12,600/month revenue protected

### 2. Auto-Pay Migration Campaign (Priority: Medium)
Electronic check customers churn at 2.4× the rate of auto-pay customers. Offer a **$5/month discount** to switch to auto-pay. The discount pays for itself if it prevents even 1 churn per 10 converted customers.

- **Effort:** Low — billing team + email campaign
- **Impact:** Highest ROI intervention in the dataset

### 3. Deploy Weekly Churn Risk Dashboard (Priority: High)
The prediction model assigns a churn probability score (0–100) to every active customer. Customer Success team should receive a weekly Power BI report flagging all customers crossing the **65% risk threshold** for proactive outreach.

- **Effort:** Medium — Power BI refresh automation (already built)
- **Impact:** Enables intervention before churn happens, not after

---

## Projected Impact

If all 3 recommendations are implemented together, projected monthly churn reduction: **~15–20%**, protecting an estimated **$20,000–$28,000/month** in recurring revenue.

---

*Analysis conducted on IBM Telco Customer Churn dataset (7,043 records). Model: Logistic Regression, ROC-AUC: ~0.84. Full methodology in GitHub repository.*
