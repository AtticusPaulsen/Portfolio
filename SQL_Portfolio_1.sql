-- In the below examples my Database is called 'DotaHeroPlayer' and there are two tables titled 'Player_Hero_Performance' and 'Hero Performance'
-- These were imported from csv files: https://www.datdota.com/players/hero-combos?default=true and https://www.datdota.com/heroes/performances?default=true
-- This was built in Azure Data Studio, Below are samples of functions in SQL on this data
-- This SQL Portfolio is located at https://github.com/AtticusPaulsen/SQL_Portfolio/blob/main/SQL_Portfolio_1.sql


--                                                                                  QUERIES
--Show total game count for all instances of heros in player hero combos in descending order
SELECT PHP.Hero, SUM(PHP.total_count) AS Total_game_Count, CONVERT(Decimal (10,2), AVG(PHP.Kills)) AS Kills
FROM DotaHeroPlayer.dbo.player_Hero_Performance AS PHP
GROUP BY PHP.Hero
ORDER BY Kills DESC

-- Help FY pick the best players for his team, he wants an Axe and Queen of Pain on his team or KuroKy
SELECT Player, Winrate, Hero
FROM dbo.player_Hero_Performance
WHERE Hero IN (
    SELECT Hero 
    FROM dbo.player_Hero_Performance 
    WHERE Hero='Queen of Pain' OR Hero='Axe') 
AND Player<>'Fy' AND Winrate>'60.00' OR Player='Kuroky'
ORDER BY Winrate DESC

-- Biggest hero earners in game with a confidence requirement of above 30 games recorded
SELECT Hero, Wins, Losses, Winrate, GPM, GS 
FROM dbo.Hero_Performance 
WHERE Total_Count >30
ORDER BY GPM DESC

-- Show all games where the player FY has a winrate of above 55% 
SELECT * 
FROM dbo.player_Hero_Performance 
WHERE Player='Fy' AND Winrate >'55.00'

-- Show top 5 heros of this seasons play that were both good as a player hero combo and hero generally. This should produce a cross sectional slice of good heroes in professional matches
SELECT TOP 5 Hero 
FROM dbo.Player_Hero_Performance 
WHERE Hero IN (
    SELECT TOP 10 Hero 
    FROM dbo.Player_Hero_Performance 
    WHERE total_count > 60 
    ORDER BY Winrate DESC) 
AND Total_Count > 100
GROUP BY Hero


--                                                                                     VIEWS
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


--                                                                                     JOINS
---- Shows Total View Count aggregated from Player Hero Combos inner joined with total game count from hero performances in Descending order on hero performances
SELECT View1.Hero, View1.TGC, HP.Total_count 
FROM View1
INNER JOIN DotaHeroPlayer.dbo.Hero_Performance AS HP ON HP.Hero = View1.Hero
WHERE HP.Total_Count >5
ORDER BY HP.Total_count DESC

--                                                                                    TEMP TABLES
---- Here we are creating the finalists for Fys new teammates, this could be used in a visualisation in Tableau or PowerBI
DROP Table if exists #TempTable1#
Create Table #TempTable1#
(
Finalist_Possible_Teammates NVARCHAR(300),
Finalist_Hero NVARCHAR(300)
)

Insert into #TempTable1#
SELECT Player AS Finalist_Possible_Teammates, Hero AS Finalist_Hero
FROM dbo.player_Hero_Performance
WHERE Hero IN (SELECT Hero FROM dbo.player_Hero_Performance WHERE Hero='Queen of Pain' OR Hero='Axe') AND Player<>'Fy' AND Winrate>'60.00' OR Player='Kuroky'

Select * From #TempTable1#

--                                                                                    OBSCURE FUNCTIONS
-- Creating an index on Hero Performance
CREATE INDEX Hero_Player_Key
ON DotaHeroPlayer.dbo.Hero_Performance (Hero)

-- Dropping that index because it's titled incorrectly
DROP INDEX Hero_Player_Key

-- Backing up the Database
BACKUP DATABASE DotaHeroPlayer
TO DISK = 'C:/Users/Attic/Documents/DotaHeroPlayer.bak'

-- Random Value/Variable Declaration
Declare @A NUMERIC
Declare @B NUMERIC

SET @A = Cast(DotaHeroPlayer.dbo.Hero_Performance.Wins as Decimal(10,2))
SET @B = Cast(DotaHeroPlayer.dbo.Hero_Performance.Losses as Decimal(10,2))

-- Composite Key Creation
ALTER TABLE dbo.player_Hero_Performance DROP COLUMN PlayerHeroKey
ALTER TABLE dbo.Player_Hero_Performance ADD PlayerHeroKey AS (Player + Hero)
