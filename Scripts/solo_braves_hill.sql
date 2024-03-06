/*Success of left handed pitchers verse right handed pitchers*/
SELECT MIN(yearid) AS first_year,
	MAX(yearid) AS most_recent_year
FROM appearances;
--What percentage of pitchers were left handed compared to right handed?
--lefties
WITH lefties AS
	(SELECT playerid,
		throws
	FROM people
	WHERE throws = 'L'),
--righties
righties AS
	(SELECT playerid,
		throws
	FROM people
	WHERE throws = 'R')
--divide the count of lefties by righties+lefties = percentage of left handed pitchers
SELECT
	ROUND(
		(SELECT COUNT(playerid)
		FROM lefties) * 100.0 / (
		(SELECT COUNT(playerid)
		FROM righties) + (SELECT COUNT(playerid)
		FROM lefties)), 2) AS percentage_of_lefties;
--ANSWER: 20.15% of pitchers from 

--How many left handed pitchers have won the CY Young Award?
WITH lefties AS
	(SELECT 
	 playerid, 
	 namefirst || ' ' || namelast AS lefty_name, 
	 throws
	FROM people
	WHERE throws = 'L')
	
SELECT lefty_name
FROM lefties
INNER JOIN awardsplayers
USING (playerid)
WHERE awardid = 'Cy Young Award'
--ANSWER: 37

--What percentage of Cy Young Award winners were left handed?
--Left Handed + Cy Young Award Winner
WITH lefties AS
	 	(SELECT
		 	COUNT(awardid)::NUMERIC AS awards1
		FROM awardsplayers
		INNER JOIN people
		USING (playerid)
		WHERE awardid = 'Cy Young Award'
 			AND throws = 'L'),
--ALL Cy Young Award Winners
total AS
	(SELECT
	 	COUNT(awardid)::NUMERIC AS awards2
	FROM awardsplayers
	WHERE awardid = 'Cy Young Award')
--lefties/total=percentage of winners that are left handed	 
SELECT
	 	lefties.awards1::NUMERIC,
		total.awards2::NUMERIC,
	 	ROUND((awards1 / awards2) * 100, 2) || '%' AS 																		percentage_of_cy_youngs_won_by_lefties
FROM lefties
NATURAL JOIN total
--ANSWER: 33.04% of Cy Young Award winners have been left handed

--What percentage of Hall of Fame pitchers are left handed?
--HOF + LEFTY
WITH hof_lefty_pitchers AS
	(SELECT
		COUNT(inducted)::NUMERIC AS inducted1
	FROM halloffame
	INNER JOIN people
	USING (playerid)
	WHERE inducted = 'Y'
		AND throws = 'L'
		AND category = 'Player'),
--ALL HOF PITCHERS		
all_hof_pitchers AS
	(SELECT
		COUNT(inducted)::NUMERIC AS inducted2
	FROM halloffame
	WHERE inducted = 'Y'
		AND category = 'Player')
--Divide lefties by total to get percentage that are lefties		
SELECT
	 	hof_lefty_pitchers.inducted1::NUMERIC,
		all_hof_pitchers.inducted2::NUMERIC,
	 	ROUND((inducted1 / inducted2) * 100, 2) || '%' AS 																		percentage_of_hof_pitchers_that_are_lefties
FROM hof_lefty_pitchers
NATURAL JOIN all_hof_pitchers;
--ANSWER: 18.8%
SELECT namefirst|| ' ' ||namelast AS name,
	MAX(salary) AS max_salary,
	throws
FROM people
RIGHT JOIN pitching
USING (playerid)
LEFT JOIN salaries
USING (playerid)
WHERE salary IS NOT NULL
GROUP BY name, throws
ORDER BY max_salary DESC;