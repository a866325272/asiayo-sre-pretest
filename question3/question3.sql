SELECT class.class
FROM score
JOIN class ON score.name = class.name
ORDER BY score.score DESC
LIMIT 1 OFFSET 1;
