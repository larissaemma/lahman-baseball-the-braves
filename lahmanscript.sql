--7.From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
WITH maxwins AS
	(SELECT yearid, MAX (w) as w
	FROM teams
	WHERE yearid >= 1970 AND yearid != 1981
	GROUP BY yearid),
flagteams AS
	(SELECT teams.name, teams.wswin, maxwins.yearid, maxwins.w
	FROM maxwins
	INNER JOIN teams
	USING (yearid, w))
SELECT (SELECT count(*)
	   FROM flagteams
	   WHERE wswin = 'Y') *100.0/ count (*)
FROM flagteams


--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT * FROM
(SELECT
	park_name,
	homegames.attendance,
	name,
	games,
	homegames.attendance/games AS attendance_per_game,
	'top_5' AS flag
 FROM homegames
 INNER JOIN parks
 USING (park)
 INNER JOIN teams
 ON team = teamid AND year = yearid
 WHERE year = 2016 AND games >= 10
 ORDER BY attendance_per_game DESC
 LIMIT 5
 ) as top_5
 
 UNION 
 SELECT *
 FROM (
 SELECT
 	park_name,
		homegames.attendance,
		name,
		games,
		homegames.attendance / games AS attendance_per_game,
		'bottom_5' AS flag
FROM homegames
INNER JOIN parks
USING (park)
INNER JOIN teams
ON team = teamid AND year = yearid
WHERE year = 2016 AND games >= 10
ORDER BY attendance_per_game asc
LIMIT 5) bottom_5
 
 




-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
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

--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH careerhigh AS (
    SELECT
        playerid,
        MAX(hr) AS career_high_hr
    FROM
        batting
    GROUP BY
        playerid
    HAVING
        COUNT(DISTINCT yearid) >= 10
),
maxhr2016 AS (
    SELECT
        playerid,
        MAX(hr) AS max_hr_2016
    FROM
        batting
    WHERE
        yearid = 2016
    GROUP BY
        playerid
    HAVING
        MAX(hr) > 0
)
SELECT DISTINCT
    m.playerid,
    p.namefirst AS first_name,
    p.namelast AS last_name,
    m.max_hr_2016 AS home_runs_2016
FROM
    maxhr2016 m
JOIN
    careerhigh c ON m.playerid = c.playerid AND m.max_hr_2016 = c.career_high_hr
JOIN
    people p ON m.playerid = p.playerid;
	





Select * 
from teams

select distinct playerid
from people




SELECT *
FROM people p
JOIN appearances a ON p.playerid = a.playerid
JOIN teams t ON a.teamid = t.teamid
WHERE (p.bats = 'R' AND p.throws = 'L') OR (p.bats = 'L' AND p.throws = 'R')


SELECT DISTINCT p.playerid
FROM people p
JOIN appearances a ON p.playerid = a.playerid
JOIN teams t ON a.teamid = t.teamid
WHERE (p.bats = 'R' AND p.throws = 'L')
   OR (p.bats = 'L' AND p.throws = 'R')
   AND t.wswin = 'Y';



SELECT DISTINCT p.playerid
FROM people p
JOIN appearances a ON p.playerid = a.playerid
JOIN teams t ON a.teamid = t.teamid
WHERE ((p.bats = 'R' AND p.throws = 'L') OR (p.bats = 'L' AND p.throws = 'R'))
AND t.teamid IN (
    SELECT teamid FROM teams WHERE wswin = 'Y'
);



WITH BatThrowPlayers AS (
    SELECT DISTINCT p.playerid
    FROM people p
    JOIN appearances a ON p.playerid = a.playerid
    JOIN teams t ON a.teamid = t.teamid
    WHERE (p.bats = 'R' AND p.throws = 'L')
       OR (p.bats = 'L' AND p.throws = 'R')
)
SELECT playerid
FROM BatThrowPlayers
WHERE playerid IN (
    SELECT DISTINCT p.playerid
    FROM people p
    JOIN appearances a ON p.playerid = a.playerid
    JOIN teams t ON a.teamid = t.teamid
    WHERE t.wswin = 'Y'
);




WITH BatThrowPlayers AS (
    SELECT DISTINCT p.playerid, p.nameFirst, p.nameLast
    FROM people p
    JOIN appearances a ON p.playerid = a.playerid
    JOIN teams t ON a.teamid = t.teamid
    WHERE (p.bats = 'R' AND p.throws = 'L')
       OR (p.bats = 'L' AND p.throws = 'R')
)
SELECT bt.playerid, bt.nameFirst, bt.nameLast
FROM BatThrowPlayers bt
WHERE bt.playerid IN (
    SELECT DISTINCT p.playerid
    FROM people p
    JOIN appearances a ON p.playerid = a.playerid
    JOIN teams t ON a.teamid = t.teamid
    WHERE t.wswin = 'Y'
);


SELECT p.*, t.wswin
FROM people p
JOIN appearances a ON p.playerid = a.playerid
JOIN teams t ON a.teamid = t.teamid
WHERE ((p.bats = 'R' AND p.throws = 'L') OR (p.bats = 'L' AND p.throws = 'R'))
  AND t.wswin = 'Y';
