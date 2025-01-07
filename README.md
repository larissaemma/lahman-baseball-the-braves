# MLB Data Analysis

This repository contains two distinct projects showcasing MLB data:

## Table of Contents
1. [Solo Project: Japanese Baseball Players in MLB Dataset](#solo-project-japanese-baseball-players-in-mlb-dataset)
   - [Project Overview](#project-overview)
   - [Key Insights](#key-insights)
   - [Resources](#resources)
   - [Script Highlights](#script-highlights)
   - [SQL Scripts](#sql-scripts)
2. [Classroom Project: Lahman Baseball Database Analysis](#classroom-project-lahman-baseball-database-analysis)
   - [Questions and Answers](#questions-and-answers)

---

# Solo Project: Japanese Baseball Players in MLB Dataset

### Project Overview
This project dives into the representation of Japanese baseball players in an MLB dataset. Inspired by my teaching experience in Japan and my students' admiration for Ohtani Shouhei, the project explores:
- The geographical origins of players in the dataset.
- Insights into the popularity of baseball in Japan.
- Analysis of top Japanese players and their contributions to MLB.

### Key Insights
- **Rankings by Country:** Japan ranks 8th in the dataset for the number of MLB players.
- **Cultural Context:** Baseball in Japan rose to prominence due to American influence, media coverage, and international success.
- **Top Players:** Profiles of prominent Japanese MLB players like Ichiro Suzuki, Hideki Matsui, and Masahiro Tanaka.
- **Geographical Analysis:** Examination of Japanese prefectures (birthstates) and their unique contributions.

### Resources
- [Presentation Link](https://www.canva.com/design/DAF-sC7YpuA/5tVEilobpyM40GAx_G-tzg/view?utm_content=DAF-sC7YpuA&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h132b8ad385): Full visual presentation.
- **Script Highlights:** See below for the full narrative accompanying the presentation.

### Script Highlights

Good evening, everyone. My presentation will be about Japanese players in our dataset.

**Slide 1:** When I was a teacher in Japan, my students often asked about a famous baseball player named Ohtani Shouhei. At the time, I didn’t know who he was, but their persistent questions led me to research him. While Ohtani is not in our dataset, this sparked my curiosity about other Japanese baseball players who might be included.

**Slide 2:** I analyzed the dataset and found that Japan ranks 8th for the number of MLB players. This discovery highlighted how baseball has transcended geographical boundaries. Additionally, a significant cluster of players originates from regions in or near the Caribbean, possibly indicating localized baseball cultures or scouting networks.

**Slide 3:** Baseball’s popularity in Japan stems from its introduction by American educators in the late 19th century, extensive media coverage, and Japan’s international success. Today, baseball rivals traditional sports like sumo and is considered one of Japan’s top three sports, alongside soccer and tennis. I’ve also highlighted some of Japan’s most beloved MLB players.

**Slide 4:** Here are the top salary players born in Japan from our dataset:
- **Suzuki Ichiro:** Iconic outfielder with over 3,000 MLB hits.
- **Kuroda Hiroki:** Known for consistent pitching.
- **Matsui Hideki:** Nicknamed "Godzilla," World Series MVP with the Yankees.
- **Tanaka Masahiro:** Represented Japan internationally and played for the Yankees.
- **Matsuzaka Daisuke:** Contributed to the Red Sox’s 2007 World Series win.

**Slide 5:** I also analyzed the prefectures (birthstates) of Japanese players. Japan has 47 prefectures, and many players originate from prominent areas. I included unique recommendations (osusume) for each prefecture.

In conclusion, exploring Japanese players in the dataset revealed fascinating intersections between baseball and culture. I hope you enjoyed the presentation. Feel free to reach out if you have questions!

### SQL Scripts

#### Top Countries People Are From
```sql
SELECT birthcountry, count(birthcountry) 
FROM people
GROUP BY birthcountry
ORDER BY count(birthcountry) DESC
LIMIT 10;
```

#### Left-Handed and Right-Handed Players from Japan
```sql
-- Right-handed batters and throwers
SELECT count(throws), count(bats) 
FROM people
WHERE birthcountry = 'Japan' AND 
      bats = 'R' AND 
      throws = 'R';

-- Left-handed batters and throwers
SELECT count(bats) 
FROM people
WHERE birthcountry = 'Japan' AND 
      bats = 'L' AND 
      throws = 'L';

-- Left-handed throwers
SELECT count(throws)
FROM people
WHERE birthcountry = 'Japan' AND
      throws = 'L';
```

#### Prefecture with the Most Players
```sql
SELECT birthstate, count(birthstate)
FROM people 
WHERE birthcountry = 'Japan' 
GROUP BY birthstate
ORDER BY count(birthstate) DESC;
```

#### Highest Total Paid Japanese Player in the Dataset
```sql
-- Top paid players
SELECT namelast, namefirst, birthstate, weight, height, sum(salary)
FROM people
INNER JOIN salaries 
USING (playerid)
WHERE birthcountry = 'Japan'
GROUP BY namelast, namefirst, birthstate, weight, height
ORDER BY sum(salary) DESC
LIMIT 8;

-- Alternative query for total salary
SELECT namefirst, namelast, SUM(s.salary) 
FROM people
INNER JOIN salaries AS s
USING (playerid)
WHERE playerid IN (
  SELECT DISTINCT playerid
  FROM people
  WHERE birthcountry = 'Japan'
)
GROUP BY namefirst, namelast
ORDER BY sum(s.salary) DESC;

-- Specific player salary
SELECT sum(salary)
FROM salaries
WHERE playerid = 'suzukic01';
```

#### Birth Year and Country Analysis
```sql
-- Birth country details
SELECT birthcountry, birthyear
FROM people;

-- Birth year and country counts
SELECT birthyear, birthcountry, count(birthcountry)
FROM people
GROUP BY birthyear, birthcountry
ORDER BY birthyear;
```

---

# Classroom Project: Lahman Baseball Database Analysis

### Questions and Answers

1. **Range of Years for Baseball Games Played**
   - **Query:**
     ```sql
     SELECT MIN(yearid) AS starting_year, MAX(yearid) AS latest_year FROM teams;
     ```
   - **Answer:** Baseball games in the database span from **1871 to 2016**.

2. **Shortest Player, Games Played, and Team**
   - **Query:**
     ```sql
     SELECT p.namefirst, p.namelast, p.height, a.g_all, t.name
     FROM people p
     LEFT JOIN appearances a ON p.playerid = a.playerid
     LEFT JOIN teams t ON a.teamid = t.teamid
     WHERE p.height = (SELECT MIN(height) FROM people)
     ORDER BY p.height ASC
     LIMIT 1;
     ```
   - **Answer:** The shortest player’s details are dynamically retrieved based on the `MIN(height)` function.

3. **Vanderbilt University Players and Total Salary Earned**
   - **Query:**
     ```sql
     SELECT p.namefirst, p.namelast, SUM(s.salary) AS total_salary
     FROM people p
     INNER JOIN salaries s USING (playerid)
     WHERE p.playerid IN (
       SELECT DISTINCT playerid FROM collegeplaying WHERE schoolid = 'vandy'
     )
     GROUP BY p.namefirst, p.namelast
     ORDER BY total_salary DESC;
     ```
   - **Answer:** **David Price** is the top earner among Vanderbilt players, with a total salary of **\$245,553,888**.

4. **Fielding Group Analysis for 2016**
   - **Query:**
     ```sql
     SELECT
       SUM(po) AS total_putouts,
       CASE
         WHEN pos = 'OF' THEN 'Outfield'
         WHEN pos IN ('P', 'C') THEN 'Battery'
         ELSE 'Infield'
       END AS defensive_group
     FROM fielding
     WHERE yearid = 2016 AND pos IS NOT NULL
     GROUP BY defensive_group;
     ```
   - **Answer:** The defensive groups (Outfield, Battery, Infield) and their total putouts for 2016 are dynamically calculated.

5. **Strikeouts and Home Runs Per Game by Decade Since 1920**
   - **Query:**
     ```sql
     SELECT
       (FLOOR(yearid / 10) * 10) AS decade,
       ROUND(AVG(so::float / g), 2) AS avg_strikeouts,
       ROUND(AVG(hr::float / g), 2) AS avg_home_runs
     FROM pitching
     WHERE yearid >= 1920
     GROUP BY decade
     ORDER BY decade;
     ```
   - **Answer:** The avg runs go up and down as the number of strikers go up or down

6. **Most Successful Base Stealer in 2016 (Minimum 20 Attempts)**
   - **Query:**
     ```sql
     SELECT
       p.namefirst, p.namelast,
       ROUND(CAST(b.sb AS DECIMAL) / CAST((b.sb + b.cs) AS DECIMAL) * 100, 2) AS success_rate
     FROM batting b
     INNER JOIN people p USING (playerid)
     WHERE (b.sb + b.cs) >= 20 AND yearid = 2016
     ORDER BY success_rate DESC
     LIMIT 1;
     ```
   - **Answer:** The most successful base stealer in 2016 is dynamically determined with a success rate calculation.

7. **Largest Wins Without a World Series Win and Smallest Wins for World Series Champions (1970–2016)**
   - **Query (Largest Wins):**
     ```sql
     SELECT name, MAX(w) AS wins FROM teams WHERE yearid BETWEEN 1970 AND 2016 AND wswin = 'N';
     ```
   - **Query (Smallest Wins):**
     ```sql
     SELECT name, MIN(w) AS wins FROM teams WHERE yearid BETWEEN 1970 AND 2016 AND wswin = 'Y';
     ```
   - **Answer:**
     - **Seattle Mariners (116 wins):** Largest wins without a World Series win.
     - **Los Angeles Dodgers (63 wins):** Smallest wins as World Series champions.

8. **Top and Bottom 5 Parks for Attendance in 2016**
   - **Query:**
     ```sql
     SELECT
       park_name, t.name AS team_name,
       ROUND(SUM(attendance) * 1.0 / SUM(games), 2) AS avg_attendance
     FROM homegames h
     INNER JOIN teams t ON h.team = t.teamid AND h.year = t.yearid
     INNER JOIN parks p ON h.park = p.parkid
     WHERE h.year = 2016 AND games >= 10
     GROUP BY park_name, t.name
     ORDER BY avg_attendance DESC
     LIMIT 5;
     ```
   - **Answer:** The top and bottom 5 parks for attendance are dynamically calculated based on average attendance.

9. **Managers Who Won TSN Manager of the Year in Both Leagues**
   - **Query:**
     ```sql
     WITH dual_winners AS (
       SELECT playerid FROM awardsmanagers
       WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL', 'NL')
       GROUP BY playerid HAVING COUNT(DISTINCT lgid) = 2
     )
     SELECT DISTINCT p.namefirst, p.namelast, m.teamid, m.yearid
     FROM dual_winners dw
     JOIN people p ON dw.playerid = p.playerid
     JOIN managers m ON dw.playerid = m.playerid;
     ```
   - **Answer:** The managers who won this award in both leagues are identified dynamically through the query.

10. **Strikeouts by Pitcher with 500+ Innings**
    - **Query:**
      ```sql
      SELECT
        p.namefirst, p.namelast,
        ROUND(SUM(p.so) * 1.0 / SUM(p.ipouts / 3), 2) AS k_per_inning
      FROM pitching p
      INNER JOIN people pl ON p.playerid = pl.playerid
      WHERE (p.ipouts / 3) >= 500
      GROUP BY pl.namefirst, pl.namel
 - **Answer:** The top pitcher with the highest



## Lahman Baseball Database Exercise
- this data has been made available [online](http://www.seanlahman.com/baseball-archive/statistics/) by Sean Lahman
- A data dictionary is included with the files for this project.

**Directions:**  
* Within your repository, create a directory named "scripts" which will hold your scripts.
* Create a branch to hold your work.
* For each question, write a query to answer.
* Complete the initial ten questions before working on the open-ended ones.

**Initial Questions**

1. What range of years for baseball games played does the provided database cover? 

2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
   

3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
	

4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
   
5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
   

6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
	

7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?


8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


**Open-ended questions**

11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

12. In this question, you will explore the connection between number of wins and attendance.
  *  Does there appear to be any correlation between attendance at home games and number of wins? </li>
  *  Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  
