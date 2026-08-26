/*
Question:
What skills are most in demand for Data Scientist jobs
in the United States?
 */
SELECT
    sd.skills,
    COUNT(DISTINCT jpf.job_id) AS job_count
FROM
    job_postings_fact jpf
    INNER JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
    INNER JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
WHERE
    jpf.job_title_short = 'Data Scientist'
    AND jpf.job_country = 'United States'
GROUP BY
    sd.skills
ORDER BY
    job_count DESC
LIMIT
    10;

/*
OUTPUT:
┌────────────┬───────────┐
│   skills   │ job_count │
│  varchar   │   int64   │
├────────────┼───────────┤
│ python     │     76602 │
│ sql        │     53882 │
│ r          │     44859 │
│ tableau    │     23694 │
│ aws        │     19680 │
│ spark      │     17103 │
│ tensorflow │     13884 │
│ azure      │     13380 │
│ java       │     12595 │
│ sas        │     12242 │
└────────────┴───────────┘
 */