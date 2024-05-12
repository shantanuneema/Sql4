-- Solution to Problem 1.
WITH CTE_rsum AS (
    SELECT 
        employee_id, 
        experience, 
        SUM(salary) OVER (PARTITION BY experience ORDER BY salary 
                          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'rsum'
    FROM Candidates
)
SELECT 'Senior' AS experience, COUNT(employee_id) AS accepted_candidates
FROM CTE_rsum
WHERE rsum <= 70000 AND experience = 'Senior'
UNION
SELECT 'Junior' AS experience, COUNT(employee_id) as accepted_candidates
FROM CTE_rsum
WHERE rsum <= 70000 - IFNULL((SELECT MAX(rsum) FROM CTE_rsum 
                              WHERE experience = 'Senior' AND rsum <= 70000), 0) 
                              AND experience = 'Junior'

-- Solution to Problem 2.
WITH CTE AS (
    SELECT home_team_id AS r1, away_team_id AS r2, home_team_goals AS g1, away_team_goals AS g2
    FROM Matches
    UNION ALL
    SELECT away_team_id AS r1, home_team_id AS r2, away_team_goals AS g1, home_team_goals AS g2
    FROM Matches
)
SELECT t.team_name, COUNT(r1) AS 'matches_played', SUM(
    CASE
       WHEN c.g1>c.g2 THEN 3
       WHEN c.g1 = c.g2 THEN 1
       ELSE 0
       END) AS 'points', SUM(c.g1) AS 'goal_for', SUM(c.g2) AS 'goal_against', SUM(c.g1) - SUM(c.g2) AS 'goal_diff' 
    FROM Teams t JOIN CTE c ON t.team_id = c.r1 GROUP BY c.r1 ORDER BY points DESC, goal_diff DESC, t.team_name;

-- Solution to Problem 3.
WITH CTE AS (
    SELECT o.com_id, o.sales_id, o.amount FROM Orders o 
    LEFT JOIN Company c ON c.com_id = o.com_id
    WHERE c.com_id = (SELECT com_id FROM Company WHERE name = 'RED')
)
SELECT name FROM SalesPerson
WHERE sales_id NOT IN (SELECT sales_id FROM CTE)

-- Solution to Problem 4.
WITH CTE AS (
    SELECT requester_id AS id FROM RequestAccepted
    UNION ALL
    SELECT accepter_id AS id FROM RequestAccepted
)

SELECT id, COUNT(*) AS 'num'
FROM CTE GROUP BY id ORDER BY num DESC LIMIT 1;

