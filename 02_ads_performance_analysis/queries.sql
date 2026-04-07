-- Query 1: Daily spend metrics by media source
-- ============================================
with FB_Ads_data as (
select ad_date, 
'Facebook_Ads' as media_source,
FB_campaign.campaign_name, 
FB_adset.adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from facebook_ads_basic_daily as FB_Basics

left join facebook_adset as FB_adset
on FB_Basics.adset_id = FB_adset.adset_id 

left join facebook_campaign as FB_campaign
on FB_Basics.campaign_id = FB_campaign.campaign_id),

Aggregated_Ads_data as 
(select ad_date,
'Facebook_Ads' as media_source,
campaign_name,
adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from FB_Ads_data

union all

select ad_date,
'Google_Ads' as media_source,
campaign_name,
adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from google_ads_basic_daily)

select ad_date,
media_source,
Round (AVG(spend),2)::numeric as Average_spend,
MIN(spend) as Minimum_spend,
Max(spend) as Maximum_spend
from Aggregated_Ads_data
group by ad_date, media_source
order by ad_date
-- ============================================

-- Query 2: Top 5 days by ROMI
-- ============================================
with FB_Ads_data as (
select ad_date, 
'Facebook_Ads' as media_source,
FB_campaign.campaign_name, 
FB_adset.adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from facebook_ads_basic_daily as FB_Basics

left join facebook_adset as FB_adset
on FB_Basics.adset_id = FB_adset.adset_id 

left join facebook_campaign as FB_campaign
on FB_Basics.campaign_id = FB_campaign.campaign_id),

Aggregated_Ads_data as 
(select ad_date,
'Facebook_Ads' as media_source,
campaign_name,
adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from FB_Ads_data

union all

select ad_date,
'Google_Ads' as media_source,
campaign_name,
adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from google_ads_basic_daily)

select ad_date,
Round(((SUM (value)- SUM (spend))/SUM (spend)::numeric)*100,3) as ROMI_percentage
from Aggregated_Ads_data
group by ad_date
having SUM (spend)>0
order by ROMI_percentage desc
limit 5
-- ============================================

-- Query 3: Campaign with the biggest weekly value
-- ============================================
with FB_Ads_data as (
select ad_date, 
'Facebook_Ads' as media_source,
FB_campaign.campaign_name, 
FB_adset.adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from facebook_ads_basic_daily as FB_Basics

left join facebook_adset as FB_adset
on FB_Basics.adset_id = FB_adset.adset_id 

left join facebook_campaign as FB_campaign
on FB_Basics.campaign_id = FB_campaign.campaign_id),

Aggregated_Ads_data as 
(select ad_date,
'Facebook_Ads' as media_source,
campaign_name,
adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from FB_Ads_data

union all

select ad_date,
'Google_Ads' as media_source,
campaign_name,
adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from google_ads_basic_daily)

select 
date_trunc('week', ad_date)::date as week_start,
campaign_name,
SUM (value) as total_value
from Aggregated_Ads_data
group by campaign_name, week_start
having campaign_name is not null
order by total_value desc
limit 1
-- ============================================

-- Query 4: The biggest by reach growth campaign
-- ============================================
with FB_Ads_data as (
select ad_date, 
'Facebook_Ads' as media_source,
FB_campaign.campaign_name, 
FB_adset.adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from facebook_ads_basic_daily as FB_Basics

left join facebook_adset as FB_adset
on FB_Basics.adset_id = FB_adset.adset_id 

left join facebook_campaign as FB_campaign
on FB_Basics.campaign_id = FB_campaign.campaign_id),

Aggregated_Ads_data as 
(select ad_date,
'Facebook_Ads' as media_source,
campaign_name,
adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from FB_Ads_data

union all

select ad_date,
'Google_Ads' as media_source,
campaign_name,
adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from google_ads_basic_daily),

Monthly_Reach_data as (
select 
date_trunc('month', ad_date)::date as Ad_month,
campaign_name,
SUM (reach) as current_month_reach
from Aggregated_Ads_data
group by ad_month, campaign_name)

select 
ad_month,
campaign_name,
current_month_reach,
coalesce(Lag(current_month_reach) over (partition by campaign_name order by ad_month),0) as Reach_in_previous_month,
coalesce(current_month_reach - lag(current_month_reach) over (partition by campaign_name order by ad_month),0) as monthly_change_of_Reach
from Monthly_Reach_data
group by ad_month, campaign_name, current_month_reach
order by monthly_change_of_Reach desc
limit 1
-- ============================================

-- Query 5: The longest shown campaign
-- ============================================
with FB_Ads_data as (
select ad_date, 
'Facebook_Ads' as media_source,
FB_campaign.campaign_name, 
FB_adset.adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from facebook_ads_basic_daily as FB_Basics

left join facebook_adset as FB_adset
on FB_Basics.adset_id = FB_adset.adset_id 

left join facebook_campaign as FB_campaign
on FB_Basics.campaign_id = FB_campaign.campaign_id),

Aggregated_Ads_data as 
(select ad_date,
'Facebook_Ads' as media_source,
campaign_name,
adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from FB_Ads_data

union all

select ad_date,
'Google_Ads' as media_source,
campaign_name,
adset_name,
spend, 
impressions, 
reach, 
clicks, 
leads, 
value 
from google_ads_basic_daily),

Longest_campaign_showing as  
(select 
ad_date,
adset_name,
ROW_NUMBER() OVER (PARTITION BY adset_name ORDER BY ad_date) AS row_number
from Aggregated_Ads_data
group by adset_name, ad_date),

CTE as
(select ad_date, adset_name, row_number,
ad_date - INTERVAL '1 day'*row_number as streak_group
from Longest_campaign_showing
group by adset_name, ad_date, row_number),

streak_lengths AS (
    SELECT 
        adset_name, streak_group,
        MIN(ad_date) AS start_date,
        MAX(ad_date) AS end_end, 
        Count(*) AS streak_length
    FROM CTE
    GROUP BY adset_name, streak_group
)

SELECT adset_name, start_date, end_end, streak_length
FROM streak_lengths
group by adset_name, streak_length, start_date, end_end
having adset_name is not null
order by streak_length desc
limit 1;
