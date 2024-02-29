-- 16. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
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
max(case when medal = 'Bronze' and rank = 1 then region || ' ' || cast(medal_count AS varchar) end) as max_bronze,
(select region || ' '|| cast(sum(medal_count) as varchar) from cte c where c.games = cte.games group by games,region
order by games,sum(medal_count) desc
limit 1) as season_max_medal
from cte 
group by games
order by games;


-- 17. Which countries have never won gold medal but have won silver/bronze medals?
with cte as(
select region,
count(case when medal = 'Gold' then 1 end) as gold,
count(case when medal = 'Silver' then 1 end) as silver,
count(case when medal = 'Bronze' then 1 end) as bronze
from olympics_history oh
JOIN olympics_history_noc_regions onc ON onc.noc = oh.noc
group by region
)
select * from cte where gold = 0 and (silver>0 or bronze >0);

-- 18. In which Sport/event, India has won highest medals.
with ind_max_medal_sport as(
select sport,
count(medal) as medal_won,
dense_rank() over(order by count(medal) desc) as rnk
from olympics_history oh
join olympics_history_noc_regions onc ON onc.noc = oh.noc
where team = 'India' and medal<>'NA'
group by sport
)
select sport,medal_won
from ind_max_medal_sport 
where rnk = 1;

-- 19. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games
select team,games,count(medal) as hockey_medal
from olympics_history
where sport = 'Hockey' and team = 'India' and medal<>'NA'
group by team,games
order by games;
