with Basic_Revenue_data as (
SELECT gp.user_id, 
DATE_TRUNC('month', gp.payment_date::date)::date as payment_month,
sum(gp.revenue_amount_usd) as total_revenue
from games_payments gp
group by payment_month, gp.user_id),
Monthly_users as (
SELECT payment_month,
COUNT(DISTINCT user_id) as paid_users
FROM Basic_Revenue_data
GROUP BY payment_month),
	Additional_calculations as (
select *,
date(payment_month + interval '1' month) as next_month,
date(payment_month - interval '1' month) as previous_month,
lag(total_revenue) over (partition by user_id order by payment_month) as revenue_in_previous_paid_month,
lag(payment_month) over (partition by user_id order by payment_month) as previous_paid_month,
lead(payment_month) over (partition by user_id order by payment_month) as next_paid_month
from Basic_Revenue_data
join Monthly_users using (payment_month)
group by basic_revenue_data.user_id, basic_revenue_data.payment_month, 
basic_revenue_data.total_revenue, monthly_users.paid_users),
	Next_metrics as (
select user_id, paid_users,
payment_month, 
total_revenue::float,
sum(total_revenue) over (partition by payment_month)::float as MRR,
coalesce((case when previous_paid_month is null 
then 1 end),0) as new_paid_users,
(case when previous_paid_month is null 
then total_revenue end)::float as new_MRR,
coalesce((case when next_paid_month is null or next_paid_month != next_month 
then 1 end),0) as churned_users,
(case when next_paid_month is null or next_paid_month != next_month 
then total_revenue end)::float as churned_revenue,
(case when next_paid_month is null or next_paid_month!= next_month 
then next_month end)::date as churned_month,
(case when previous_paid_month = previous_month and total_revenue > revenue_in_previous_paid_month 
then total_revenue - revenue_in_previous_paid_month 
end)::float as Expansion_revenue,
(case when previous_paid_month = previous_month and total_revenue < revenue_in_previous_paid_month 
then total_revenue - revenue_in_previous_paid_month
end)::float as Contraction_revenue
from Additional_calculations),
	Monthly_churn AS (
    SELECT payment_month,
SUM(churned_users) as total_churned,
MAX(paid_users) as paid_users_count,
SUM(churned_users)::float / 
LAG(MAX(paid_users)) OVER (ORDER BY payment_month) as churn_rate
FROM Next_metrics
GROUP BY payment_month
),
	Final_metrics as (
select *, (MRR/paid_users)::float as ARPPU,
(churned_revenue/ lag(total_revenue) over (partition by user_id order by payment_month)) as revenue_churned_rate
from Next_metrics)
select *
from Final_metrics
left join project.games_paid_users as PD_users
on Final_metrics.user_id = PD_users.user_id
left join Monthly_churn using (payment_month)
group by Final_metrics.user_id, paid_users, payment_month, total_revenue, ARPPU, MRR, new_paid_users, new_mrr, 
churned_users, churned_revenue, churned_month, Expansion_revenue, Contraction_revenue, churn_rate, revenue_churned_rate, 
PD_users.user_id, PD_users.game_name, PD_users.language, pd_users.has_older_device_model, pd_users.age, 
monthly_churn.total_churned, monthly_churn.paid_users_count
order by payment_month 
