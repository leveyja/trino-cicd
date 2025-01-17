-- PRs per author
WITH
prs_per_author AS (
    SELECT p.user_login, count(*) AS num_prs
    FROM unique_pulls p
    GROUP BY 1
)
, histogram AS (
    SELECT
        num_prs AS key
        , width_bucket(num_prs, ARRAY[1, 2, 3, 4, 5, 10, 100, 1000]) AS bucket
        , count(*) AS value
    FROM prs_per_author
    GROUP BY 1
)
, grouped AS (
    SELECT
        bucket
        , element_at(ARRAY['1', '2', '3', '4', '5 to 10', '10 to 100', '100 to 1000', 'over 1000'], bucket) AS range
        , sum(value) AS value
    FROM histogram
    GROUP BY 1, 2
)
SELECT
  range AS "Number of PRs per author"
  , value AS "Number of authors"
  , bar(value / CAST(max(value) OVER () AS double), 20, rgb(0, 155, 0), rgb(255, 0, 0)) AS "Chart"
FROM grouped
ORDER BY bucket
;
