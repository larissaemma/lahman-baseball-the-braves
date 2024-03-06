--1. What range of years for baseball games played does the provided database cover?

SELECT MIN(yearid) AS starting_year,
	MAX(yearid) AS most_current_year
FROM public.appearances;

--ANSWER: 1871-2016

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT people.namefirst,
	people.namelast,
	MIN(people.height) AS height_in_inches,
	appearances.g_all AS games_played,
	teams.name
FROM people
LEFT JOIN appearances
ON people.playerid = appearances.playerid
LEFT JOIN teams
ON appearances.teamid = teams.teamid
GROUP BY people.namefirst, people.namelast, people.height, appearances.g_all, teams.name
ORDER BY people.height ASC
LIMIT 1;

--ANSWER: Eddie Gaedel, 43" tall, Played in 1 game, St. Louis Browns

--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT namefirst, namelast, SUM(s.salary)
FROM people
	INNER JOIN salaries AS s
		USING (playerid)
WHERE playerid IN(SELECT DISTINCT playerid
		FROM collegeplaying
		WHERE schoolid = 'vandy')
GROUP BY namefirst, namelast;

--ANSWER: David Price, $81,851,296

--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT
	SUM(po) AS total_putouts,
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	ELSE 'Infield' END AS defensive_position
FROM fielding
WHERE yearid = 2016 AND pos IS NOT NULL
GROUP BY defensive_position;

--ANSWER: Battery-938, Infield-661, Outfield- 354

--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT 10 * FLOOR(yearid/10) AS decade,
		ROUND(SUM(so) / SUM(g)::NUMERIC, 2) AS avg_so_game,
		ROUND(SUM(hr) / SUM(g)::NUMERIC, 2) AS avg_hr_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;

--6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

SELECT
	people.namefirst,
	people.namelast,
	sub.playerid,
	sub.stolen_bases,
	sub.caught_stealing,
	sub.total_attempts,
	ROUND(SUM(sub.stolen_bases) / SUM(sub.total_attempts)*100, 2) AS sb_success_rate
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

--ANSWER: Chris Owings had 21 stolen bases out of 23 attempts resulting in a 91% success rate.

--7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

WITH maxwins AS
	(SELECT yearid,
		MAX(w) AS w
	FROM teams
	WHERE yearid >= 1970
	 	AND yearid <> 1981
	GROUP BY yearid),
flagteams AS
	(SELECT teams.name,
	 	teams.wswin,
	 	maxwins.yearid,
	 	maxwins.w
	FROM maxwins
	INNER JOIN teams
	USING (yearid, w))
SELECT (SELECT COUNT (*)
		FROM flagteams
		WHERE wswin = 'Y') * 100.0/ COUNT(*)
FROM flagteams

--ANSWER:
	--a.) 2001 SEA with 116 wins and no WS
	--b.) 1981 LAN with 63 wins and won the World Series (player strike shortened season)
	--c.) SEE CODE
	--d.) One time= .02%

--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

(SELECT 'Top 5' AS top_or_bottom,
 	RANK() OVER(ORDER BY SUM(homegames.attendance) / SUM(games) DESC) AS rank,
	teams.name AS team_name,
	park_name,
	SUM(homegames.attendance) / SUM(games) AS avg_attendance
FROM homegames
LEFT JOIN parks
USING(park)
LEFT JOIN teams
ON teams.teamid = homegames.team AND teams.yearid = homegames.year
WHERE year = 2016
	AND games >= 10
GROUP BY teams.name, park_name	
ORDER BY avg_attendance DESC
LIMIT 5)
UNION
(SELECT 'Bottom 5',
	RANK() OVER(ORDER BY SUM(homegames.attendance) / SUM(games)) AS rank,
 	teams.name,
	park_name,
	SUM(homegames.attendance) / SUM(games) AS avg_attendance
FROM homegames
LEFT JOIN parks
USING(park)
LEFT JOIN teams
ON teams.teamid = homegames.team AND teams.yearid = homegames.year
WHERE year = 2016
	AND games >= 10
GROUP BY teams.name, park_name	
ORDER BY avg_attendance
LIMIT 5)
ORDER BY avg_attendance DESC;

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
	
WITH both_league_winners AS (
	SELECT
		playerid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year'
		AND lgid IN ('AL', 'NL')
	GROUP BY playerid
	HAVING COUNT(DISTINCT lgid) = 2
	)
SELECT DISTINCT people.namefirst|| ' ' || people.namelast AS name,
		managers.teamid,
		managers.lgid, yearid
FROM people
INNER JOIN managers
USING (playerid)
INNER JOIN awardsmanagers
USING (playerid, yearid)
INNER JOIN both_league_winners
USING (playerid)

--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH players2016 AS
	(SELECT playerid,
	 namefirst|| ' ' || namelast AS name,
	 hr
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

--11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

SELECT sub.year AS year,
	ROUND(SUM(sub.wins_per_year) / SUM(sub.team), 2) AS avg_wins_per_year,
	RANK() OVER(ORDER BY ROUND(SUM(sub.wins_per_year) / SUM(sub.team), 2) DESC) AS rank_avg_wins_per_year,
	MAX(sub.total_wins) AS max_total_wins,
	RANK() OVER(ORDER BY MAX(sub.total_wins) DESC) AS rank_max_total_wins,
	ROUND(SUM(sub.annual_salary)::NUMERIC / SUM(sub.team)::NUMERIC, 2) AS avg_annual_team_salary,
	RANK() OVER(ORDER BY ROUND(SUM(sub.annual_salary)::NUMERIC / SUM(sub.team)::NUMERIC, 2) DESC) AS 				rank_avg_annual_team_salary,
	ROUND(MAX(sub.annual_salary)::NUMERIC, 2) AS highest_team_salary,
	RANK() OVER(ORDER BY ROUND(MAX(sub.annual_salary)::NUMERIC, 2) DESC) AS rank_highest_team_salary
FROM
	(SELECT DISTINCT(t.yearid) AS year,
	 		t.w AS total_wins,
	 		COUNT(DISTINCT t.teamid) AS team,
	 		s.teamid AS teamid,
	 	AVG(t.W) AS wins_per_year,
	 	SUM(s.salary) AS annual_salary
	FROM teams AS t
	JOIN salaries AS s
	USING (teamid, yearid)
	WHERE yearid >= 2000
	GROUP BY t.yearid, s.teamid, total_wins) AS sub
GROUP BY year
ORDER BY year ASC;

--12. In this question, you will explore the connection between number of wins and attendance.

--a. Does there appear to be any correlation between attendance at home games and number of wins?

--b. Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

--13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?