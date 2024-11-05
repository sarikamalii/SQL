SELECT
    b.*,
    CASE
        WHEN b.height NOT BETWEEN b.lcl AND b.ucl THEN 1
        ELSE 0
    END AS alert
FROM (
    SELECT
        a.*,
        a.avg_height + (3 * a.stddev_height / SQRT(5)) AS ucl,
        a.avg_height - (3 * a.stddev_height / SQRT(5)) AS lcl
    FROM (
        SELECT 
            operator,
            ROW_NUMBER() OVER (PARTITION BY operator ORDER BY item_no) AS row_number,
            item_no,
            height,
            AVG(height) OVER (PARTITION BY operator ORDER BY item_no ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS avg_height,
            STDEV(height) OVER (PARTITION BY operator ORDER BY item_no ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS stddev_height
        FROM parts
    ) AS a
    WHERE a.row_number >= 5
) AS b
ORDER BY b.item_no;
