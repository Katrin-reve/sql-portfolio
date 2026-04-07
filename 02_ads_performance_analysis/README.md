## Ads Performance Analysis | SQL (PostgreSQL)

**Business goal:** Analyze Facebook and Google Ads performance across campaigns 
and adsets — identifying top ROMI days, best-performing campaigns by reach 
growth and weekly value, and longest continuously running adsets.

**Data:** 4 tables — `facebook_ads_basic_daily`, `google_ads_basic_daily`, 
`facebook_adset`, `facebook_campaign`

**Stack:** PostgreSQL · DBeaver

**SQL covers:**
- UNION ALL to combine Facebook and Google data into unified source
- Aggregated spend metrics (AVG, MIN, MAX) by media source and date
- ROMI calculation: `(value - spend) / spend * 100`
- Month-over-month reach growth using LAG + COALESCE
- Weekly campaign value with date_trunc
- **Gap-and-island algorithm** using ROW_NUMBER + date arithmetic 
  to find the longest continuously running adset

**Queries:**
1. Daily spend metrics by media source (AVG/MIN/MAX)
2. Top 5 days by ROMI across both channels
3. Campaign with highest single-week value
4. Biggest month-over-month reach growth by campaign
5. Longest uninterrupted adset run (streak detection)
