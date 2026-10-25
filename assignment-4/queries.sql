SELECT m.match_date                                       AS date,
       h.name                                             AS home_team,
       COALESCE(m.home_goals || ':' || m.away_goals, '-') AS score,
       a.name                                             AS away_team
FROM matches m
JOIN teams h ON h.id = m.home_team_id
JOIN teams a ON a.id = m.away_team_id
WHERE h.name = '11A' OR a.name = '11A'
ORDER BY m.match_date, m.id;



WITH results AS (
  SELECT home_team_id AS team_id, home_goals AS scored, away_goals AS conceded
  FROM matches
  WHERE home_goals IS NOT NULL
  UNION ALL
  SELECT away_team_id, away_goals, home_goals
  FROM matches
  WHERE home_goals IS NOT NULL
)
SELECT t.name                    AS team,
       COUNT(r.team_id)          AS matches_played,
       COALESCE(SUM(CASE WHEN r.scored > r.conceded THEN 3
                         WHEN r.scored = r.conceded THEN 1
                         ELSE 0
                    END), 0)     AS points,
       COALESCE(SUM(r.scored), 0)   AS goals_scored,
       COALESCE(SUM(r.conceded), 0) AS goals_conceded
FROM teams t
LEFT JOIN results r ON r.team_id = t.id
GROUP BY t.id, t.name
ORDER BY points DESC,
         COALESCE(SUM(r.scored - r.conceded), 0) DESC,
         t.name;