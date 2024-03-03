--SOLO PROJECT

-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?


-- Number of lefties in database:

SELECT playerid, namefirst || ' ' || namelast AS full_name, throws
FROM people
WHERE throws = 'L'
--3654 Lefties


--Number of righties in database:

SELECT playerid, namefirst || ' ' || namelast AS full_name, throws
FROM people
WHERE throws = 'R'
--14480 Righties
--18134 total


--Percentage of total lefties vs. total righties:

WITH lefties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 throws
	FROM people
	WHERE throws = 'L'
	),
	righties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 throws
	FROM people
	WHERE throws = 'R'
	)
SELECT ROUND(
	(SELECT COUNT (playerid)
	FROM lefties) *100.0/
	((SELECT COUNT (playerid)
	FROM righties) + (SELECT COUNT (playerid)
	FROM lefties)),2)
--20.15% 


--Number of lefties who rec'd Cy Young Award (using CTE):

WITH lefties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 throws
	FROM people
	WHERE throws = 'L'
	)
SELECT *
FROM lefties
INNER JOIN awardsplayers
USING (playerid)
WHERE awardid = 'Cy Young Award'
--37 pitchers


--Another way to find the number of lefties who won the Cy Young Award (using inner join)

SELECT p.playerid, p.namefirst || ' ' || p.namelast AS full_name, p.throws, ap.awardid 
FROM people AS p
INNER JOIN awardsplayers AS ap
USING (playerid)
WHERE p.throws = 'L' AND ap.awardid = 'Cy Young Award'
--37 pitchers


--Number of right-handed pitchers who rec'd Cy Young Award:

WITH righties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 throws
	FROM people
	WHERE throws = 'R'
	)
SELECT *
FROM righties
INNER JOIN awardsplayers
USING (playerid)
WHERE awardid = 'Cy Young Award'
--75 pitchers


--Percentage of left-handed pitchers who have rec'd Cy Young Award:

WITH cy_award AS
	(
		SELECT p.playerid, p.namefirst || ' ' || p.namelast AS 			full_name, p.throws, ap.awardid 
		FROM people AS p
		INNER JOIN awardsplayers AS ap
		USING (playerid)
		WHERE p.throws = 'L' AND ap.awardid = 'Cy Young Award'
		),
	lefties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 throws
	FROM people
	WHERE throws = 'L'
	)
SELECT ROUND((SELECT COUNT (playerid)
			 FROM cy_award)*100.0/
			((SELECT COUNT (playerid)
			 FROM lefties)),2)
--1.01% of Left-handed pitchers received the Cy Young Award


--Percentage of righty pitchers who rec'd Cy Young Award:

WITH cy_award AS
	(
		SELECT p.playerid, p.namefirst || ' ' || p.namelast AS 			full_name, p.throws, ap.awardid 
		FROM people AS p
		INNER JOIN awardsplayers AS ap
		USING (playerid)
		WHERE p.throws = 'R' AND ap.awardid = 'Cy Young Award'
		),
	righties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 throws
	FROM people
	WHERE throws = 'R'
	)
SELECT ROUND((SELECT COUNT (playerid)
			 FROM cy_award)*100.0/
			((SELECT COUNT (playerid)
			 FROM righties)),2)
-- .52% of right-handed pitchers have received the Cy Young Award


--Number of lefty pitchers in the Hall of Fame:

WITH lefties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 throws
	FROM people
	WHERE throws = 'L'
	)
SELECT *
FROM lefties
INNER JOIN halloffame
USING (playerid)
WHERE inducted = 'Y'
--52 lefty pitchers


--Number of righty pitchers in the Hall of Fame:

WITH righties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 throws
	FROM people
	WHERE throws = 'R'
	)
SELECT *
FROM righties
INNER JOIN halloffame
USING (playerid)
WHERE inducted = 'Y'
--231 right pitchers in the Hall of Fame


--Percentage of lefty pitchers in the Hall of Fame:

WITH hof AS
	(
		SELECT p.playerid, p.namefirst || ' ' || p.namelast AS 		full_name, p.throws, hf.inducted
	FROM people AS p
	INNER JOIN halloffame AS hf
	USING (playerid)
	WHERE throws = 'L' AND hf.inducted = 'Y'
		),
	lefties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 throws
	FROM people
	WHERE throws = 'L'
	)
SELECT ROUND((SELECT COUNT (playerid)
			 FROM hof)*100.0/
			((SELECT COUNT (playerid)
			 FROM lefties)),2)
-- 1.42% of left-handed pitchers are in the Hall of Fame


--Percentage of right-handed pitchers in the Hall of Fame:

WITH hof AS
	(
		SELECT p.playerid, p.namefirst || ' ' || p.namelast AS 		full_name, p.throws, hf.inducted
	FROM people AS p
	INNER JOIN halloffame AS hf
	USING (playerid)
	WHERE throws = 'R' AND hf.inducted = 'Y'
		),
	righties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS full_name, 
	 throws
	FROM people
	WHERE throws = 'R'
	)
SELECT ROUND((SELECT COUNT (playerid)
			 FROM hof)*100.0/
			((SELECT COUNT (playerid)
			 FROM righties)),2)
--1.60% of right-handed pitchers are in the Hall of Fame


--Lefties ERA:

SELECT p.playerid, p.namefirst || ' ' || p.namelast AS full_name, p.throws, ptch.era
FROM people AS p
INNER JOIN pitching AS ptch
USING (playerid)
WHERE p.throws = 'L' AND era IS NOT NULL AND era > '0'
ORDER BY era;
--Top 5 lefty eras = 0.45, 0.49, 0.5, 0.51, 0.53


--Righties ERA:

SELECT p.playerid, p.namefirst || ' ' || p.namelast AS full_name, p.throws, ptch.era
FROM people AS p
INNER JOIN pitching AS ptch
USING (playerid)
WHERE p.throws = 'R' AND era IS NOT NULL AND era > '0'
ORDER BY era;
--Top 5 righty eras = 0.31, 0.38, 0.38, 0.38, 0.39


SELECT p.playerid, ptch.bfp, ptch.era, p.namefirst || ' ' || p.namelast AS full_name, p.throws 
FROM pitching AS ptch
INNER JOIN people AS p
USING (playerid)
WHERE bfp IS NOT NULL AND p.throws = 'L'