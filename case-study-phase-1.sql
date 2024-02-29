select count(*) from olympics_history;
select count(*) from olympics_history_noc_regions;

-- 1. How many olympics games have been held?
select count(distinct(games)) as total_olympics_played
from olympics_history;

-- 2. List down all Olympics games held so far.
select distinct(year), season,city 
from olympics_history
order by year;

-- 3. Mention the total no of nations who participated in each olympics game?
select games, count(distinct region) as total_country
from olympics_history oh 
join olympics_history_noc_regions ohn on ohn.noc = oh.noc
group by games order by games;

-- 4. Which year saw the highest and lowest no of countries participating in olympics
(select 'highest - '|| games as games,count(distinct region) as total_participant
from olympics_history oh 
join olympics_history_noc_regions ohn on ohn.noc = oh.noc
group by games order by total_participant desc
limit 1)
union all
(select 'lowest - '|| games as games,count(distinct region) as total_participant
from olympics_history oh 
join olympics_history_noc_regions ohn on ohn.noc = oh.noc
group by games order by total_participant asc
limit 1);

-- 5. Which nation has participated in all of the olympic games
with cte as (select region, count(distinct(games)) as total_olympics_played 
from olympics_history oh
join olympics_history_noc_regions onc on onc.noc = oh.noc 
group by region
order by total_olympics_played
)
select * from cte
where total_olympics_played = (select max(total_olympics_played) from cte);

-- 5 using window function
WITH OlympicCounts AS (
  SELECT region, COUNT(DISTINCT games) AS total_olympics_played,
         RANK() OVER (ORDER BY COUNT(DISTINCT games) DESC) AS r
  FROM olympics_history oh
  JOIN olympics_history_noc_regions onc ON onc.noc = oh.noc
  GROUP BY region
)

SELECT region, total_olympics_played
FROM OlympicCounts
WHERE r = 1;

