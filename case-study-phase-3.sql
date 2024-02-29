-- 11. Fetch the top 5 athletes who have won the most gold medals.
with cte as (select name,team,
count(medal),dense_rank() over(order by count(medal) desc) as rnk 
from olympics_history
where medal = 'Gold'
group by name,team)
select * from cte where rnk<6;

--12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

with cte as (select name,team,
count(medal),dense_rank() over(order by count(medal) desc) as rnk 
from olympics_history
where medal in(select medal from olympics_history where medal not like 'NA')
group by name,team)
select * from cte where rnk<6;

-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
with cte as (select region,
count(medal),dense_rank() over(order by count(medal) desc) as rnk 
from olympics_history oh
JOIN olympics_history_noc_regions onc ON onc.noc = oh.noc
where medal in(select medal from olympics_history where medal not like 'NA')
group by region)
select * from cte where rnk<6;

-- 14. List down total gold, silver and bronze medals won by each country.
select region,
count(case when medal = 'Gold' then 1 end) as gold,
count(case when medal = 'Silver' then 1 end) as silver,
count(case when medal = 'Bronze' then 1 end) as bronze
from olympics_history oh
JOIN olympics_history_noc_regions onc ON onc.noc = oh.noc
group by region
order by gold desc,silver desc,bronze desc;

-- 15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
with cte as(
select oh.games,onc.region,oh.medal,count(*) as medal_count,
dense_rank() over (partition by games, medal order by count(*) desc) as rank
from olympics_history oh
join olympics_history_noc_regions onc on oh.noc = onc.noc
where oh.medal IN ('Gold', 'Silver', 'Bronze')
group by oh.games, onc.region, oh.medal)
select games,
max(case when medal = 'Gold' and rank = 1 then region || ' ' || cast(medal_count AS varchar) end) as max_gold,
max(case when medal = 'Silver' and rank = 1 then region || ' ' || cast(medal_count AS varchar) end) as max_silver,
max(case when medal = 'Bronze' and rank = 1 then region || ' ' || cast(medal_count AS varchar) end) as max_bronze
from cte
group by games
order by games;
