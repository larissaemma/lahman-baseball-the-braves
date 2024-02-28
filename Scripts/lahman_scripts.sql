
--1. What range of years for baseball games played does the provided database cover?


SELECT MIN(yearid) as starting_year,
		MAX (yearid) as latest_year
FROM teams

--answer: 1871; 2016




--2.Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?


SELECT playerid, namefirst, namelast, height
FROM people
ORDER BY height ASC
LIMIT 1;

SELECT g_all, teamid
FROM appearances
WHERE playerid = 'gaedeed01'


--3.Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT *
FROM public.collegeplaying


SELECT *
FROM public.schools


SELECT *
FROM public.schools
WHERE schoolname = 'Vanderbilt University'

SELECT p.namefirst, p.namelast, SUM (s.salary)
FROM public.collegeplaying as c
INNER JOIN public.people as p
USING (playerid)
INNER JOIN salaries as s
USING (playerid)
WHERE schoolid = 'vandy'
GROUP BY p.namefirst, p.namelast
ORDER BY SUM (s.salary) DESC

--answer: "David Price"; 245553888

--4.Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

