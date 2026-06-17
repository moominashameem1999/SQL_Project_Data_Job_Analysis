/*
Question: What are the top-paying data analyst jobs?
- Identify the top 10 highest-paying Data Analyst roles that are available remotely.
- Focuses on job postings with specified salaries (remove nulls).
- Why? Highlight the top-paying opportunities for Data Analysts, offering insights into employment op
*/

SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    job_work_from_home,
    name AS company_name
FROM
    job_postings_fact AS jpf
LEFT JOIN
    company_dim AS cd ON  jpf.company_id = cd.company_id
WHERE
    job_title_short = 'Data Analyst' AND
    job_work_from_home IS TRUE AND
    salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 10