/*## Lahman Baseball Database Exercise
- this data has been made available [online](http://www.seanlahman.com/baseball-archive/statistics/) by Sean Lahman
- A data dictionary is included with the files for this project.

### Use SQL queries to find answers to the *Initial Questions*. If time permits, choose one (or more) of the *Open-Ended Questions*. Toward the end of the bootcamp, we will revisit this data if time allows to combine SQL, Excel Power Pivot, and/or Python to answer more of the *Open-Ended Questions*.*/

--**Initial Questions**

--1. What range of years for baseball games played does the provided database cover? 

SELECT MAX(yearID) AS max_year,
MIN(yearID) AS min_year
FROM teams

--Answer: 1871 to 2016

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT namegiven, namelast, g_all, name, MIN(height) AS min_height
FROM people
LEFT JOIN appearances 
USING (playerid)
LEFT JOIN teams
USING (teamid)
GROUP BY namegiven, namelast, g_all, name
ORDER BY min_height ASC
LIMIT 1;

--Answer: Edward Carl Gaedel, played in one game, played for St. Louis Browns

--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT namefirst, namelast, schoolid, SUM(salary) AS sum_salary
FROM people
LEFT JOIN salaries
USING (playerid)
LEFT JOIN collegeplaying
USING (playerid)
WHERE schoolid LIKE 'vandy' AND salary IS NOT NULL
GROUP BY namefirst, namelast, schoolid
ORDER BY sum_salary DESC

--Answer: David Price

--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT SUM(PO) AS total_putouts,
CASE 
	WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos = 'SS' THEN 'Infield'
	WHEN pos = '1B' THEN 'Infield'
	WHEN pos = '2B' THEN 'Infield'
	WHEN pos = '3B' THEN 'Infield'
	WHEN pos = 'P' THEN 'Battery'
	WHEN pos = 'C' THEN 'Battery'
	END AS position_label 
FROM fielding
WHERE yearID = '2016'
GROUP BY
CASE 
	WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos = 'SS' THEN 'Infield'
	WHEN pos = '1B' THEN 'Infield'
	WHEN pos = '2B' THEN 'Infield'
	WHEN pos = '3B' THEN 'Infield'
	WHEN pos = 'P' THEN 'Battery'
	WHEN pos = 'C' THEN 'Battery'
	END
ORDER BY total_putouts 

/*Answer: Infield - Total Putouts: 58,934
Answer: Battery - Total Putouts: 41,424
Answer: Outfield - Total Putouts: 29,560
*/

--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT
    TO_CHAR(SUM(SOA)::numeric / SUM(G)::numeric, 'FM999999999.00') AS avg_strikeouts,
    TO_CHAR(SUM(R)::numeric / SUM(G)::numeric, 'FM999999999.00') AS avg_runs,
    (EXTRACT('decade' FROM MAKE_DATE(yearid, 1, 1)) * 10)::int AS decade
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade ASC

--Answer: Strikeouts have increased significantly since the 1920s

--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT namefirst, namelast, SUM(SB)*100/SUM(SB+CS) AS percentage_stolen
FROM batting
LEFT JOIN people
USING (playerid)
GROUP BY namefirst, namelast, yearid
HAVING yearID = '2016' AND SUM(SB) >= 20
ORDER BY percentage_stolen DESC

--Answer: Chris Owings

--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

--Most wins but did not win WS:

SELECT name, yearid, WSWin, SUM(W) AS wins, SUM(L) AS losses
FROM teams
GROUP BY name, yearid, WSWin
HAVING yearid >= 1970 AND yearid != '1981' AND yearid !=1994 AND WSWin = 'N'
ORDER BY wins DESC

--Answer: Seattle Mariners in 2001

--Fewest wins but did win WS:

SELECT name, yearid, WSWin, SUM(W) AS wins, SUM(L) AS losses
FROM teams
GROUP BY name, yearid, WSWin
HAVING yearid >= 1970 AND yearid != '1981' AND yearid !=1994 AND WSWin = 'Y'
ORDER BY wins ASC

--Answer: St. Louis Cardinals in 2006

--Attempt to combine two queries above

WITH most_wins_did_not_win AS (
SELECT name, yearid, WSWin, SUM(W) AS wins, SUM(L) AS losses
FROM teams
GROUP BY name, yearid, WSWin
HAVING yearid >= 1970 AND yearid != '1981' AND yearid !=1994 AND WSWin = 'N'
ORDER BY wins DESC),

fewest_wins_did_win AS (
SELECT name, yearid, WSWin, SUM(W) AS wins, SUM(L) AS losses
FROM teams
GROUP BY name, yearid, WSWin
HAVING yearid >= 1970 AND yearid != '1981' AND yearid !=1994 AND WSWin = 'Y'
ORDER BY wins ASC) 

SELECT 
FROM most_wins_did_not_win
LEFT JOIN fewest_wins_did_win
USING (name, yearid, WSWin)


--UPDATED percentage script:
			 
WITH WS_max_wins AS (
    SELECT
        teams.wswin,
		yearid, 
        MAX(W) AS ws_wins
    FROM
        teams
    WHERE
        WSWin = 'Y'
    GROUP BY
        yearid, wswin
HAVING yearid >= 1970 AND yearid != '1981' AND yearid !='1994'
),
most_wins_WS_win AS (
SELECT yearid, MAX(W) AS wins,
CASE
	WHEN ws_wins = MAX(W) THEN 1
	ELSE 0
	END AS most_wins_WS
FROM teams
LEFT JOIN WS_max_wins
USING (yearid)
GROUP BY ws_wins, yearid
HAVING yearid >= 1970 AND yearid != '1981' AND yearid !='1994'
),
most_wins_did_not_win AS (
SELECT yearid, MAX(W) AS wins,
CASE
	WHEN ws_wins != MAX(W) THEN 1
	ELSE 0
	END AS most_wins_did_not_winWS
FROM teams
LEFT JOIN WS_max_wins
USING (yearid)
GROUP BY ws_wins, yearid
HAVING yearid >= 1970 AND yearid != '1981' AND yearid !='1994'
),
totals AS (
SELECT 
SUM(CAST(most_wins_ws AS FLOAT)) AS most_wins_only,
SUM(CAST((most_wins_did_not_winWS + most_wins_ws) AS FLOAT)) AS all_wins
FROM WS_max_wins
LEFT JOIN most_wins_WS_win
USING (yearid)
LEFT JOIN most_wins_did_not_win
USING (yearid)
GROUP BY ws_max_wins.wswin
)			
SELECT
  most_wins_only / NULLIF(all_wins, 0) AS percentage
FROM totals;

----Team with the most wins won the WS 26.6% of the time.

--OLD Percentage Script:

WITH WS_max_wins AS (
    SELECT
        yearid, 
        MAX(W) AS ws_wins
    FROM
        teams
    WHERE
        WSWin = 'Y'
    GROUP BY
        yearid
)
SELECT yearid, MAX(W) AS wins, ws_wins,
CASE
	WHEN ws_wins = MAX(W) THEN 1
	ELSE 0
	END AS most_wins_WS_win
FROM teams
LEFT JOIN WS_max_wins
USING (yearid)
GROUP BY yearid, ws_wins
HAVING yearid >= 1970 AND yearid != '1981' AND yearid !='1994'
ORDER BY most_wins_ws_win DESC
			 
--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT team, park_name, games, SUM(attendance) AS attendance, SUM(attendance)/SUM(games) AS avg_attendance
FROM homegames
LEFT JOIN parks
USING (park)
WHERE games >= 10 AND year = 2016
GROUP BY team, park_name, games																	 
ORDER BY avg_attendance DESC
LIMIT 5;
																	 
--Answer in descending order: LAN, SLN, TOR, SFN, CHN
																	 
SELECT team, park_name, games, SUM(attendance) AS attendance, SUM(attendance)/SUM(games) AS avg_attendance
FROM homegames
LEFT JOIN parks
USING (park)
WHERE games >= 10 AND year = 2016
GROUP BY team, park_name, games																	 
ORDER BY avg_attendance ASC
LIMIT 5;
														 
--Answer in ascending order: TBA, OAK, CLE, MIA, CHA
																	 
-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

WITH NL_Wins AS (
    SELECT
        playerid,
        COUNT(*) AS NL_count
    FROM
        awardsmanagers
    WHERE
        awardid = 'TSN Manager of the Year' AND lgid = 'NL'
    GROUP BY
        playerid
),
	AL_Wins AS (
    SELECT
        playerid,
        COUNT(*) AS AL_count
    FROM
        awardsmanagers
    WHERE
        awardid = 'TSN Manager of the Year' AND lgid = 'AL'
    GROUP BY
        playerid
)
SELECT awardsmanagers.playerid, namefirst, namelast, awardid, teamid, awardsmanagers.lgid, awardsmanagers.yearid, name, tie, franchid,
CASE
        WHEN NL_Wins.NL_count > 0 AND AL_Wins.AL_count > 0 THEN 'Both Leagues'
        ELSE 'Single League'
    END AS WinType
FROM awardsmanagers
LEFT JOIN managers
USING (playerid, yearid)
LEFT JOIN people
USING (playerid)
LEFT JOIN teams
USING (teamid, yearid)
LEFT JOIN
    NL_Wins
ON
    awardsmanagers.playerid = NL_Wins.playerid
LEFT JOIN
    AL_Wins
ON
    awardsmanagers.playerid = AL_Wins.playerid
GROUP BY awardsmanagers.playerid, namefirst, namelast, awardid, teamid, awardsmanagers.lgid, awardsmanagers.yearid, name, tie, franchid, nl_wins.nl_count, al_wins.al_count
HAVING awardid LIKE 'TSN Manager of the Year' AND (awardsmanagers.lgid = 'NL' OR awardsmanagers.lgid = 'AL') AND (NL_Wins.NL_count > 0 AND AL_Wins.AL_count > 0)
ORDER BY wintype ASC

--Answer: Davey Johnson	won both - won AL managing Baltimore Orioles and NL managing Washinton Nationals.

--Jim Leyland also won both, won AL managing Detroit Tigers and NL managing Pittsburgh Pirates.

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH number_years AS 
(
	SELECT playerid,
	COUNT(DISTINCT yearid) AS distinct_years
	FROM appearances
	GROUP BY playerid
),
homeruns_in_2016 AS
(
	SELECT playerid,
	MAX(HR) AS hr_in_2016
	FROM batting
	WHERE yearid = '2016' AND HR >= 1
	GROUP BY playerid
),
homeruns_pre_2016 AS
(
	SELECT playerid,
	MAX(HR) AS max_hr_pre_2016
	FROM batting
	WHERE yearid < 2016
	GROUP BY playerid
)
SELECT playerid, namefirst, namelast, appearances.yearid, distinct_years, max_hr_pre_2016, hr_in_2016
FROM batting
LEFT JOIN people
USING (playerid)
LEFT JOIN appearances
USING (playerid, yearid)
LEFT JOIN number_years
USING (playerid)
LEFT JOIN homeruns_in_2016
USING (playerid)
LEFT JOIN homeruns_pre_2016
USING (playerid)
WHERE distinct_years >= 10 AND hr_in_2016 IS NOT NULL AND (hr_in_2016 >= max_hr_pre_2016) AND yearid = 2016
GROUP BY playerid, namefirst, namelast, appearances.yearid, distinct_years, max_hr_pre_2016, hr_in_2016
ORDER BY playerid DESC

/*Answer:

Adam Wainwright: 2 HR in 2016
Justin Upton: 31 HR in 2016
Angel Pagan: 12 HR in 2016
Mike Napoli: 34 HR in 2016
Francisco Liriano: 1 HR in 2016
Edwin Encarnacion: 1 HR in 2016
Rajai Davis: 12 HR in 2016
Bartolo Colon: 1 HR in 2016
Robinson Cano: 39 HR in 2016*/

--**Open-ended questions**

--11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

--12. In this question, you will explore the connection between number of wins and attendance.
      --Does there appear to be any correlation between attendance at home games and number of wins? </li>
      --Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.
    
--13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?
