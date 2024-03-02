-- 1. What range of years for baseball games played does the provided database cover? 

SELECT MIN(yearid) AS start_year,
	MAX(yearid) AS most_recent_year
FROM appearances;

--ANSWER 1871-2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT height, namefirst, namelast, playerid
FROM people
ORDER BY height;

--ANSWER: Eddie Gaedel is the shortest player in the database.

SELECT g_all, teamid
FROM appearances
WHERE playerid = 'gaedeed01'

SELECT *
FROM teams
WHERE teamid = 'SLA';

--ANSWER: Eddie Gaedel played in one game and he played for SLA (St. Louis Browns).


-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT c.playerid, s.schoolid, s.schoolname, p.namefirst, p.namelast, SUM(salaries.salary) AS total_salary
FROM schools AS s
INNER JOIN collegeplaying AS c
ON s.schoolid = c.schoolid
INNER JOIN people AS p
ON c.playerid = p.playerid
INNER JOIN salaries
ON p.playerid= salaries.playerid
WHERE schoolname = 'Vanderbilt University'
GROUP BY p.namefirst, p.namelast, c.playerid, s.schoolid, s.schoolname
ORDER BY total_salary DESC

-- ANSWER David Price earned the highest total salary in the majors. $245,553,888

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.


SELECT
	COUNT(yearid),
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	ELSE 'Infield' END AS defensive_position
FROM fielding
WHERE yearid = 2016 AND pos IS NOT NULL
GROUP BY defensive_position;


   
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
 
SELECT (FLOOR(yearid / 10) * 10) AS Decade,
		ROUND (avg (so),2) as avg_so
FROM public.batting
WHERE yearid >= 1920
GROUP BY FLOOR(yearid/ 10)
ORDER BY decade;

SELECT (FLOOR(yearid / 10) * 10) AS Decade,
		ROUND (avg (hr),2) as avg_hr
FROM public.batting
WHERE yearid >= 1920
GROUP BY FLOOR(yearid/ 10)
ORDER BY decade;

SELECT
	sub.decade,
	sub.num_games,
	sub.strike_outs,
	ROUND(SUM(sub.strike_outs) / SUM(sub.num_games), 2) AS avg_so_per_game
FROM
	(SELECT
	 		SUM(g) AS num_games,
	 		SUM(so) AS strike_outs,
	 		CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
				WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
				WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
				WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
				WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
				WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
				WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
				WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
				WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
				WHEN yearid BETWEEN 2010 and 2019 THEN '2010s'
				ELSE '<=1910s' END AS decade
	FROM pitching
	GROUP BY decade
	ORDER BY decade ASC) AS sub
GROUP BY sub.num_games, sub.strike_outs, sub.decade
ORDER BY sub.decade ASC;

--Derek's query, so clean and simple!
SELECT 10 * FLOOR(yearid/10) AS decade,
		ROUND(SUM(so) / SUM(g)::NUMERIC, 2) AS avg_so_game,
		ROUND(SUM(hr) / SUM(g)::NUMERIC, 2) AS avg_hr_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;

--ANSWER There is a trend of strikeouts and homeruns per game continuing to increase each decade in the dataset.

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT
	people.namefirst,
	people.namelast,
	sub.playerid,
	sub.stolen_bases,
	sub.caught_stealing,
	sub.total_attempts,
	ROUND(SUM(sub.stolen_bases) / SUM(sub.total_attempts), 2) AS sb_success_rate
FROM (SELECT yearid,
	  		playerid,
			SUM(sb) AS stolen_bases,
			SUM(cs) AS caught_stealing,
			SUM(sb + cs) AS total_attempts
		FROM batting
		WHERE yearid = 2016
		GROUP BY playerid, yearid
		ORDER BY total_attempts DESC) AS sub
JOIN people
ON sub.playerid = people.playerid
WHERE sub.total_attempts >= 20 AND sub.yearid = 2016
GROUP BY people.namefirst, people.namelast, sub.playerid, sub.stolen_bases, sub.caught_stealing, 					sub.total_attempts, sub.yearid
ORDER BY sb_success_rate DESC;

--Dibran's
WITH full_batting AS (
	SELECT playerid, SUM(sb) AS sb, SUM(cs) AS cs
	FROM batting
	WHERE yearid = 2016
	GROUP BY playerid)
SELECT namefirst, namelast, sb, sb + cs AS attempts, sb * 100.0 / (sb + cs) AS sb_pct
FROM full_batting
INNER JOIN people
USING (playerid)
WHERE sb + cs >= 20
ORDER BY sb_pct DESC;

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT yearid, teamid, w, wswin
FROM teams
WHERE yearid >=1970 AND wswin = 'N'
ORDER BY w DESC;

--ANSWER Largest number of wins for a team that did not win the world series is 116.


-- SELECT yearid, teamid, w, wswin
-- FROM teams
-- WHERE yearid >=1970 AND wswin = 'Y'
-- ORDER BY w;

WITH largest_win AS (
	SELECT lt.yearid, MAX(lt.w) AS w
	FROM teams as lt
	WHERE yearid >=1970 AND yearid <> 1981
	GROUP BY lt.yearid
	ORDER BY lt.yearid
	),
	
	ws_team AS (
	SELECT lt.yearid, lt.teamid AS max_win_team, lt.wswin
	FROM teams as lt
	INNER JOIN largest_win
	USING (yearid, w))
SELECT ROUND(
	(SELECT COUNT (*)
	   FROM ws_team
	   WHERE wswin = 'Y')
	   *100.0/
	   (SELECT COUNT (*) 
	   FROM ws_team),2)
	   
--ANSWER 23.08%


-- SELECT yearid, teamid, MAX(w) AS w
-- FROM teams
-- WHERE yearid >= '1970'
-- GROUP BY yearid, teamid
-- ORDER BY yearid, w DESC
	
WITH smallest_win AS (
	SELECT st.yearid, st.teamid, st.w, st.wswin
	FROM teams as st
	WHERE yearid >=1970 AND yearid <>1981 AND wswin = 'Y'
	ORDER BY w
	)
	
SELECT DISTINCT teams.yearid, teams.teamid, teams.w, teams.wswin
FROM teams 
INNER JOIN largest_win
USING (teamid)
INNER JOIN smallest_win
USING (teamid)
WHERE teams.wswin IS NOT NULL AND teams.wswin = 'Y'
ORDER BY w;

--ANSWER Smallest number of wins for a team that did win the world series is 63.

WITH largest_win AS (
	SELECT lt.yearid, lt.teamid, lt.w, lt.wswin
	FROM teams as lt
	WHERE yearid >=1970 AND wswin = 'N'
	ORDER BY w DESC
	),
	
	smallest_win AS (
	SELECT st.yearid, st.teamid, st.w, st.wswin
	FROM teams as st
	WHERE yearid >=1970 AND yearid <>1981 AND wswin = 'Y'
	ORDER BY w
	),
	maxwins AS (
	SELECT yearid, MAX(w) AS max_wins
		FROM teams
		WHERE yearid BETWEEN 1970 AND 2016
		AND yearid != 1981
		GROUP BY yearid
	)
	
SELECT DISTINCT teams.yearid, COUNT(*) as num_years,
		ROUND(COUNT(*) * 100.0/
(SELECT COUNT(*) FROM maxwins), 2)AS percentage, teams.teamid, teams.w, teams.wswin 
FROM teams
INNER JOIN largest_win
USING (teamid)
INNER JOIN smallest_win
USING (teamid)
INNER JOIN maxwins
USING (yearid)

--Above query getting an error about yearid appearing more than once in left table

--Larissa's query

WITH worldse AS (
    SELECT
        MAX(CASE WHEN wswin = 'N' THEN w END) AS max_wins_no_world_series,
        MIN(CASE WHEN wswin = 'Y' THEN w END) AS min_wins_world_series,
        MAX(CASE WHEN yearid >= 1970 AND yearid <> 1981 AND wswin = 'Y' THEN w ELSE NULL END) AS max_wins_for_champ,
        COUNT(CASE WHEN wswin = 'Y' THEN 1 END) AS num_ws_champions,
        COUNT(*) AS total_teams
    FROM
        teams
    WHERE
        yearid BETWEEN 1970 AND 2016
)
SELECT
    max_wins_no_world_series,
    min_wins_world_series,
    max_wins_for_champ,
    num_ws_champions,
    (num_ws_champions * 100.0) / total_teams AS percentage
FROM
    worldse;

--Lauren's query
WITH maxwins AS
(
	SELECT yearid, MAX(w) AS max_wins
		FROM teams
		WHERE yearid BETWEEN 1970 AND 2016
		AND yearid != 1981
		GROUP BY yearid
)
SELECT COUNT(*) as num_years,
		ROUND(COUNT(*) * 100.0/
(SELECT COUNT(*) FROM maxwins), 2)
AS percentage
FROM maxwins
WHERE (yearid, max_wins) IN
(
	SELECT yearid, w
		FROM teams
	WHERE wswin = 'Y'
	AND yearid BETWEEN 1970 AND 2016
	AND yearid != 1981
);

SELECT yearid, w, wswin, COUNT(teamid)
FROM teams
WHERE yearid >=1970 AND wswin = 'Y'
GROUP BY yearid, w, wswin
ORDER BY w DESC;


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT ROUND(AVG(attendance/games),2) as avg_attendance, team, park, games
FROM homegames
GROUP BY team, park, games
ORDER BY avg_attendance DESC;

--ANSWER 65342.00	"CLE"	"CLE07"
      -- 57569.00	"COL"	"DEN01"
      -- 55348.00	"COL"	"DEN01"
      -- 55000.00	"TBA"	"TOK01"
      -- 55000.00	"NYN"	"TOK01"
	  
SELECT ROUND(AVG(attendance/games),2) as avg_attendance, team, park, games
FROM homegames
GROUP BY team, park, games
ORDER BY avg_attendance;

-- ANSWER 0.00	"CL6"	"COL02"
       -- 0.00	"PH4"	"PHI01"
       -- 0.00	"CHN"	"CHI06"
       -- 0.00	"SLN"	"STL05"
       -- 0.00	"CL2"	"CLE02"

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- SELECT *
-- FROM awardsmanagers
-- CASE WHEN playerid
-- WHERE awardid = 'TSN Manager of the Year' AND lgid = 'NL' OR lgid = 'AL'
-- ORDER BY playerid

-- SELECT am.playerid, am.awardid, am.lgid
-- FROM awardsmanagers as am
-- INNER JOIN (
-- 	SELECT playerid, awardid, lgid
-- 	FROM awardsmanagers
-- 	WHERE awardid = 'TSN Manager of the Year' AND lgid = 		'NL'
-- 	GROUP BY playerid, awardid, lgid) as sub
-- 	ON sub.lgid = am.lgid
-- WHERE am.awardid = 'TSN Manager of the Year' AND am.lgid='AL'

-- WITH NL AS 
-- 	(SELECT am.playerid, am.awardid, am.lgid, am.lgid
-- 	 FROM awardsmanagers as am
-- 	 WHERE awardid = 'TSN Manager of the Year' AND lgid = 'NL' 		),
-- 	 AL AS
-- 	 (SELECT am.playerid, am.awardid, am.lgid, am.lgid
-- 	 FROM awardsmanagers as am
-- 	 WHERE awardid = 'TSN Manager of the Year' AND lgid = 'AL' 		)
-- SELECT awardsmanagers.playerid, awardsmanagers.awardid, awardsmanagers.lgid
-- FROM awardsmanagers
-- FULL JOIN NL
-- USING (playerid)
-- FULL JOIN AL
-- USING (playerid)
-- WHERE awardsmanagers.awardid = 'TSN Manager of the Year'

WITH both_league_winners AS (
	SELECT
		playerid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year'
		AND lgid IN ('AL', 'NL')
	GROUP BY playerid
	HAVING COUNT(DISTINCT lgid) = 2
	)
SELECT DISTINCT people.namefirst, people.namelast, managers.teamid, managers.lgid, yearid
FROM people
INNER JOIN managers
USING (playerid)
INNER JOIN awardsmanagers
USING (playerid, yearid)
INNER JOIN both_league_winners
USING (playerid)

-- SELECT am.playerid, am.awardid, am.lgid
-- FROM awardsmanagers as am
-- WHERE awardid = 'TSN Manager of the Year'
-- GROUP BY am.playerid, am.awardid, am.lgid
-- HAVING lgid IN ('NL', 'AL')
-- ORDER BY am.playerid

--Larissa's Query
-- SELECT DISTINCT(playerid), namefirst, namelast, teamid
-- FROM awardsmanagers as a
-- INNER JOIN people
-- USING (playerid)
-- INNER JOIN managers
-- USING (playerid)
-- WHERE awardid = 'TSN Manager of the Year' AND a.lgid = 'AL' AND playerid IN (
--     SELECT playerid
--     FROM awardsmanagers as a
--     INNER JOIN people
-- 	USING (playerid)
-- 	INNER JOIN managers
-- 	USING (playerid)
-- 	WHERE awardid = 'TSN Manager of the Year' AND a.lgid = 'NL'
-- )


-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


-- SELECT playerid, yearid, hr
-- FROM batting
-- -- WHERE yearid = '2016'
-- ORDER BY hr DESC;

-- SELECT playerid, namefirst, namelast, hr
-- FROM batting 
-- INNER JOIN people
-- USING (playerid)
-- INNER JOIN (
--   SELECT playerid, count (yearid) as yearsplayed
--   FROM batting
--   INNER JOIN people as p
--   USING (playerid)
--   GROUP BY playerid
--   HAVING count (yearid)  >= 10
-- ) years
-- USING (playerid)
-- WHERE yearid= 2016 AND hr > 0
-- ORDER BY hr DESC;

-- SELECT *
-- FROM (
-- 	SELECT playerid, hr, yearid,      		
-- 	RANK() over (PARTITION BY playerid
-- 	ORDER BY hr DESC, yearid DESC) as rank
-- 	FROM batting
-- 	) as rank_table											WHERE hr >0 AND rank = 1
	
WITH players2016 AS
	(SELECT playerid, namefirst, namelast, hr
	FROM batting
	INNER JOIN people
	USING (playerid)
		INNER JOIN (
  		SELECT playerid, count (yearid) as yearsplayed
  		FROM batting
  		INNER JOIN people as p
  		USING (playerid)
  		GROUP BY playerid
 		 HAVING count (yearid)  >= 10
		) years
		USING (playerid)
		WHERE yearid= 2016 AND hr > 0
		ORDER BY hr DESC),
rawrh as
  		(SELECT playerid, MAX (hr) as hr
		FROM batting
		GROUP By playerid)
SELECT *
FROM players2016
INNER JOIN rawrh
USING (playerid, hr)

--Jessica's
SELECT
    p.namefirst || ' ' || p.namelast AS player_name,
    b.hr AS home_runs_2016
FROM batting AS b
INNER JOIN people AS p ON b.playerID = p.playerid
WHERE b.yearid = 2016
	AND hr > 0
	AND EXTRACT(YEAR FROM debut::date) <= 2016 - 9
    AND b.hr = (
        SELECT MAX(hr)
        FROM batting
        WHERE playerid = b.playerid)
ORDER BY home_runs_2016 DESC;

--Derek's
WITH highest_2016 AS
				/* return playerid and number of home runs if max was in 2016 */
			(SELECT  playerid,
						/* return hr when 2016 AND player hit their max hr */
						CASE WHEN hr = MAX(hr) OVER (PARTITION BY playerid) AND yearid = 2016 THEN hr
								END AS career_highest_2016
				FROM batting
				GROUP BY playerid, hr, yearid
				ORDER BY playerid)

SELECT  p.namefirst || ' ' || p.namelast AS name,
		h.career_highest_2016 AS num_hr
FROM highest_2016 AS h
LEFT JOIN people AS p
	ON h.playerid = p.playerid
WHERE h.career_highest_2016 IS NOT NULL
	AND h.career_highest_2016 > 0
	AND DATE_PART('year', p.debut::DATE) <= 2007
ORDER BY num_hr DESC;