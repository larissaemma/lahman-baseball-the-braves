--SOLO PROJECT

-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

SELECT playerid, namefirst || ' ' || namelast AS full_name, throws
FROM people
WHERE throws = 'L'
--3654 Lefties

SELECT playerid, namefirst || ' ' || namelast AS full_name, throws
FROM people
WHERE throws = 'R'
--14480 Righties
--18134 total

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
--37 times



-- WITH left_cy_award AS
-- 	((SELECT 
-- 	 playerid, 
-- 	 namefirst || ' ' || namelast AS full_name, 
-- 	 throws
-- 	FROM people
-- 	WHERE throws = 'L'
-- 	)
-- 	SELECT *
-- 	FROM lefties
-- 	INNER JOIN awardsplayers
-- 	USING (playerid)
-- 	WHERE awardid = 'Cy Young Award')),
	
-- 	lefties AS
-- 	(SELECT 
-- 	 playerid, 
-- 	 namefirst || ' ' || namelast AS full_name, 
-- 	 throws
-- 	FROM people
-- 	WHERE throws = 'L'
-- 	)
	
-- SELECT ROUND(
-- 	SELECT COUNT (playerid)
-- 	FROM left_cy_award)*100.0/
-- 	((SELECT COUNT (playerid)
-- 	 FROM lefties)),2)
	 
-- WITH lefties AS
-- 	(SELECT 
-- 	 playerid, 
-- 	 namefirst || ' ' || namelast AS full_name, 
-- 	 throws
-- 	FROM people
-- 	WHERE throws = 'L'
-- 	)	
-- SELECT ROUND(
-- 	 (SELECT COUNT(WITH lefties AS
-- 	(SELECT 
-- 	 playerid, 
-- 	 namefirst || ' ' || namelast AS full_name, 
-- 	 throws
-- 	FROM people
-- 	WHERE throws = 'L'
-- 	)
-- SELECT *
-- FROM lefties
-- INNER JOIN awardsplayers
-- USING (playerid)
-- WHERE awardid = 'Cy Young Award'(playerid))*100.0/
-- 	(SELECT COUNT (playerid)
-- 	FROM lefties)),2)

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
--75 times

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
--52 times

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
--231 times