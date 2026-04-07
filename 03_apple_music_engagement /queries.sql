-- Query 1: Unique users who streamed a recommended artist after recommendation date
select count (DISTINCT user_streams.user_id) as unique_users
from user_streams
left join artist_recommendations as rec
on user_streams.user_id=rec.user_id AND
  user_streams.artist_id=rec.artist_id
where stream_date>=recommendation_date


-- Query 2: Average number of streams per recommended artist per user (May 2024)
with cte as 
(select rec.artist_id, rec.user_id, count(stream_id) as total_number_of_streams
from user_streams as str
inner join artist_recommendations as rec
on str.user_id=rec.user_id AND
str.artist_id=rec.artist_id
where stream_date>=recommendation_date 
   and stream_date BETWEEN '2024-05-01' and '2024-05-31'
   group by rec.user_id, rec.artist_id)
select avg(total_number_of_streams) as avg_number_of_times
from cte

-- Query 3: Average number of distinct recommended artists listened to per user
with cte AS
  (select rec.user_id, count (DISTINCT rec.artist_id) as unique_artists
from user_streams as str
inner join artist_recommendations as rec
on str.artist_id=rec.artist_id AND
str.user_id=rec.user_id
where stream_date>=recommendation_date
  group by rec.user_id)
select avg(unique_artists)
from cte
