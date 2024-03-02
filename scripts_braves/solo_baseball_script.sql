--SOLO PROJECT

-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

SELECT playerid, namefirst || ' ' || namelast AS full_name, bats
FROM people
WHERE bats = 'L'
--4959 Lefties

SELECT playerid, namefirst || ' ' || namelast AS full_name, bats
FROM people
WHERE bats = 'R'
--11794 Righties
--16753 total

WITH lefties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 bats
	FROM people
	WHERE bats = 'L'
	),
	righties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 bats
	FROM people
	WHERE bats = 'R'
	)
SELECT ROUND(
	(SELECT COUNT (playerid)
	FROM lefties) *100.0/
	((SELECT COUNT (playerid)
	FROM righties) + (SELECT COUNT (playerid)
	FROM lefties)),2)
--29.60% Is this correct?


WITH lefties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 bats
	FROM people
	WHERE bats = 'L'
	)
SELECT *
FROM lefties
INNER JOIN awardsplayers
USING (playerid)
WHERE awardid = 'Cy Young Award'
--32 times

WITH righties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 bats
	FROM people
	WHERE bats = 'R'
	)
SELECT *
FROM righties
INNER JOIN awardsplayers
USING (playerid)
WHERE awardid = 'Cy Young Award'
--77 times

WITH lefties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 bats
	FROM people
	WHERE bats = 'L'
	)
SELECT *
FROM lefties
INNER JOIN halloffame
USING (playerid)
WHERE inducted = 'Y'
--88 times

WITH righties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 bats
	FROM people
	WHERE bats = 'R'
	)
SELECT *
FROM righties
INNER JOIN halloffame
USING (playerid)
WHERE inducted = 'Y'
--170 times