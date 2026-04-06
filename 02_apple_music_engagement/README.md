## User Engagement with Artist Recommendations | SQL

**Business goal:** Evaluate the effectiveness of Apple Music's artist 
recommendation algorithm by analyzing user interactions with recommended artists.

**Data:** 2 tables — "user_streams" (streaming history) and 
"artist_recommendations" (recommendation log with dates)

**Stack:** PostgreSQL · Interview Master platform

**SQL covers:**
- COUNT DISTINCT with date-filtered JOIN conditions
- CTE + aggregation for average engagement metrics
- Multi-condition JOIN logic (user_id + artist_id + date threshold)

**Key queries:**
- Unique users who streamed a recommended artist on or after recommendation date
- % of recommended artists actually streamed per user
- Average number of distinct recommended artists listened to per user
