## Gaming Revenue Metrics | SQL + Tableau

**Business goal:** Build an analytical pipeline to track revenue dynamics, 
user behavior, and key SaaS metrics for a gaming project — enabling product 
managers to monitor changes and identify growth/loss drivers.

**Data:** 2 tables — `games_payments` (transaction history) and `games_paid_users` (user demographics)

**Stack:** PostgreSQL · DBeaver · Tableau Public

**SQL:** 5 cascading CTEs calculating:
- MRR, ARPPU, New MRR
- Churned Revenue, Expansion/Contraction Revenue
- Churn Rate, LT, LTV

**Dashboards:**
- [Revenue and Users' Metrics](https://public.tableau.com/views/Finalproject-RevenueandUsersmetrics/REVENUEANDUSERSMETRICSINGAMINGPROJECTDashboard) — MRR trends, paid user dynamics, revenue change factors, ARPPU by month, LTV
- Age Groups Analysis — quarterly revenue, churn, LT/LTV by age cohort (14–23, 24–33, 34–44)

**Key findings:**
- Paid user base grew from 43 (Mar 2022) to 199 (Jan 2023)
- Churn rate stabilized at ~17–22% in H2 2022
- Age group 14–23 drives 66.88% of paid users
- ARPPU remained stable at $44–49 throughout the year
