/*
 Question:
 Which skills show up most often in the highest-paying
 Data Scientist jobs in the United States?
 
 "Highest-paying" = top 25% of reported salaries.
 */
WITH salary_threshold AS (
    SELECT QUANTILE_CONT (salary_year_avg, 0.75) AS high_salary_threshold
    FROM job_postings_fact
    WHERE job_title_short = 'Data Scientist'
        AND job_country = 'United States'
        AND salary_year_avg IS NOT NULL
),
relevant_jobs AS (
    SELECT jpf.job_id,
        CASE
            WHEN jpf.salary_year_avg >= st.high_salary_threshold THEN 'High Paying'
            ELSE 'Other'
        END AS salary_segment
    FROM job_postings_fact AS jpf
        CROSS JOIN salary_threshold AS st
    WHERE jpf.job_title_short = 'Data Scientist'
        AND jpf.job_country = 'United States'
        AND jpf.salary_year_avg IS NOT NULL
),
skill_job_counts AS (
    SELECT sd.skills,
        COUNT(
            DISTINCT CASE
                WHEN rj.salary_segment = 'High Paying' THEN rj.job_id
            END
        ) AS high_paying_jobs,
        COUNT(DISTINCT rj.job_id) AS total_jobs
    FROM relevant_jobs AS rj
        INNER JOIN skills_job_dim AS sjd ON rj.job_id = sjd.job_id
        INNER JOIN skills_dim AS sd ON sjd.skill_id = sd.skill_id
    GROUP BY sd.skills
),
segment_totals AS (
    SELECT COUNT(*) AS total_jobs,
        COUNT(
            CASE
                WHEN salary_segment = 'High Paying' THEN 1
            END
        ) AS high_paying_jobs
    FROM relevant_jobs
)
SELECT sjc.skills,
    sjc.high_paying_jobs,
    sjc.total_jobs,
    ROUND(
        100.0 * sjc.high_paying_jobs / st.high_paying_jobs,
        2
    ) AS high_paying_demand_pct,
    ROUND(100.0 * sjc.total_jobs / st.total_jobs, 2) AS overall_demand_pct,
    ROUND(
        (sjc.high_paying_jobs * 1.0 / st.high_paying_jobs) / (sjc.total_jobs * 1.0 / st.total_jobs),
        2
    ) AS demand_lift
FROM skill_job_counts AS sjc
    CROSS JOIN segment_totals AS st
WHERE sjc.total_jobs >= 500
    AND sjc.high_paying_jobs >= 50
ORDER BY demand_lift DESC
LIMIT 15;

/*
 OUTPUT:
 ┌──────────────┬──────────────────┬────────────┬────────────────────────┬────────────────────┬─────────────┐
 │    skills    │ high_paying_jobs │ total_jobs │ high_paying_demand_pct │ overall_demand_pct │ demand_lift │
 │   varchar    │      int64       │   int64    │         double         │       double       │   double    │
 ├──────────────┼──────────────────┼────────────┼────────────────────────┼────────────────────┼─────────────┤
 │ scala        │              264 │        711 │                  10.48 │               7.07 │        1.48 │
 │ pytorch      │              347 │        959 │                  13.78 │               9.54 │        1.44 │
 │ spark        │              494 │       1495 │                  19.62 │              14.87 │        1.32 │
 │ tensorflow   │              390 │       1187 │                  15.49 │              11.81 │        1.31 │
 │ numpy        │              171 │        562 │                   6.79 │               5.59 │        1.21 │
 │ go           │              154 │        520 │                   6.12 │               5.17 │        1.18 │
 │ scikit-learn │              196 │        674 │                   7.78 │                6.7 │        1.16 │
 │ python       │             1987 │       7304 │                  78.91 │              72.65 │        1.09 │
 │ sql          │             1481 │       5509 │                  58.82 │               54.8 │        1.07 │
 │ aws          │              475 │       1774 │                  18.86 │              17.65 │        1.07 │
 │ r            │             1108 │       4307 │                   44.0 │              42.84 │        1.03 │
 │ pandas       │              197 │        762 │                   7.82 │               7.58 │        1.03 │
 │ hadoop       │              209 │        886 │                    8.3 │               8.81 │        0.94 │
 │ snowflake    │              127 │        563 │                   5.04 │                5.6 │         0.9 │
 │ gcp          │              113 │        534 │                   4.49 │               5.31 │        0.84 │
 └──────────────┴──────────────────┴────────────┴────────────────────────┴────────────────────┴─────────────┘
 */