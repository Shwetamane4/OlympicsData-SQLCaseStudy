-- 6. Identify the sport which was played in all summer olympics.

SELECT sport, COUNT(distinct games) AS no_of_games
FROM (
  SELECT DISTINCT games, sport
  FROM olympics_history
  WHERE season = 'Summer'
) AS t2
GROUP BY sport
HAVING COUNT(distinct games) = (
  SELECT COUNT(DISTINCT games)
  FROM olympics_history
  WHERE season = 'Summer'
)


-- 7. Which Sports were just played only in one olympics season.
with cte as (select sport, count(distinct games) as no_of_season_played
from olympics_history
group by sport
order by sport,no_of_season_played
)
select * from cte where no_of_season_played =1;

-- using window function 
select sport,no_of_season_played 
from(select sport, count(distinct games) no_of_season_played,
rank() over(order by count(distinct games)) as r
from olympics_history
group by sport)
where r = 1
order by sport;

-- 8. Fetch the total no of sports played in each olympic games.
select games,count(distinct sport) as total_games_played
from olympics_history 
group by games
order by games;

-- 9. Fetch oldest athletes to win a gold medal
with cte as (select *,case when age = 'NA' then NULL else age end as new_age
from olympics_history where medal = 'Gold'),
cte2 as(select *,dense_rank() over(order by new_age desc) as rnk from cte
)
select name,age,team,games,event,medal
from cte2 where rnk = 2;

-- 10. Find the Ratio of male and female athletes participated in all olympic games.
SELECT (select concat('1:',(SELECT COUNT(sex)::NUMERIC FROM olympics_history WHERE sex = 'M') / 
(SELECT COUNT(sex) FROM olympics_history WHERE sex = 'F')))
;
