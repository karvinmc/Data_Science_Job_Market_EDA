/*
 Question:
 Which Data Scientist skills in the United States 
 pay well and are in demand?
 */
WITH relevant_jobs AS (
    SELECT job_id,
        salary_year_avg
    FROM job_postings_fact
    WHERE job_title_short = 'Data Scientist'
        AND job_country = 'United States'
        AND salary_year_avg IS NOT NULL
),
skill_stats AS (
    SELECT sd.skills,
        COUNT(DISTINCT rj.job_id) AS job_count,
        ROUND(MEDIAN (rj.salary_year_avg), 2) AS median_salary
    FROM relevant_jobs AS rj
        INNER JOIN skills_job_dim AS sjd ON rj.job_id = sjd.job_id
        INNER JOIN skills_dim AS sd ON sjd.skill_id = sd.skill_id
    GROUP BY sd.skills
    HAVING COUNT(DISTINCT rj.job_id) >= 500
),
total_jobs AS (
    SELECT COUNT(*) AS total_job_count
    FROM relevant_jobs
)
SELECT ss.skills,
    ss.job_count,
    ROUND(100.0 * ss.job_count / tj.total_job_count, 2) AS demand_percentage,
    ss.median_salary
FROM skill_stats AS ss
    CROSS JOIN total_jobs AS tj
ORDER BY median_salary DESC
LIMIT 15;

/*
 OUTPUT:
 ┌──────────────┬───────────┬───────────────────┬───────────────┐
 │    skills    │ job_count │ demand_percentage │ median_salary │
 │   varchar    │   int64   │      double       │    double     │
 ├──────────────┼───────────┼───────────────────┼───────────────┤
 │ pytorch      │       959 │              9.54 │      145000.0 │
 │ go           │       520 │              5.17 │      140000.0 │
 │ scala        │       711 │              7.07 │      140000.0 │
 │ spark        │      1495 │             14.87 │      140000.0 │
 │ numpy        │       562 │              5.59 │      140000.0 │
 │ scikit-learn │       674 │               6.7 │      139375.0 │
 │ tensorflow   │      1187 │             11.81 │      138500.0 │
 │ pandas       │       762 │              7.58 │      137500.0 │
 │ snowflake    │       563 │               5.6 │      135000.0 │
 │ aws          │      1774 │             17.65 │      135000.0 │
 │ python       │      7304 │             72.65 │      132500.0 │
 │ sql          │      5509 │              54.8 │      131866.5 │
 │ azure        │      1244 │             12.37 │      130000.0 │
 │ r            │      4307 │             42.84 │      130000.0 │
 │ hadoop       │       886 │              8.81 │      129890.0 │
 └──────────────┴───────────┴───────────────────┴───────────────┘
 */