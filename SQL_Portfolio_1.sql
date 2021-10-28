-- In the below examples my Database is called 'DotaHeroPlayer' and there are two tables titled 'Player_Hero_Performance' and 'Hero Performance'
-- These were imported from csv files: https://www.datdota.com/players/hero-combos?default=true and https://www.datdota.com/heroes/performances?default=true
-- This was built in Azure Data Studio, Below are samples of functions in SQL on this data


--QUERIES
--Show total game count for all instances of heros in player hero combos in descending order

SELECT PHP.Hero, SUM(PHP.total_count) AS 'Total Game Count'
FROM DotaHeroPlayer.dbo.player_Hero_Performance AS PHP
GROUP BY PHP.Hero
ORDER BY 'Total Game Count' DESC

-- Show all games where the player FY has a winrate of above 55% 

SELECT * 
FROM dbo.player_Hero_Performance 
WHERE Player='Fy' AND Winrate >'55.00'


-- VIEWS
-- View Creation for sum of total game counts from player hero combos

CREATE view View1 AS
SELECT PHP.Hero, SUM(PHP.total_count) AS 'TGC'
FROM DotaHeroPlayer.dbo.player_Hero_Performance AS PHP
GROUP BY PHP.Hero


-- Conditional View Creation 

CREATE View best_heroes AS 
SELECT Hero, Winrate 
FROM dbo.player_Hero_Performance 
WHERE winrate >'60.00'


-- Replace View and add new column and AND statement

ALTER View best_heroes AS 
SELECT Hero, Winrate, kills 
FROM Dbo.dbo.player_Hero_Performance 
WHERE winrate >'60.00' AND kills>'1'


--JOINS
---- Shows Total View Count aggregated from Player Hero Combos inner joined with total game count from hero performances in Descending order on hero performances

SELECT View1.Hero, View1.TGC, HP.Total_count 
FROM View1
INNER JOIN DotaHeroPlayer.dbo.Hero_Performance AS HP ON HP.Hero = View1.Hero
WHERE HP.Total_Count >5
ORDER BY HP.Total_count DESC


