/*
Question: What are the highest-paying and most in-demand skills for Data Analysts in India?
- Identify the top 25 skills based on average salary and find their corresponding job count.
- Group the results by specific locations within India to uncover localized market demands.
- Why? This provides regional insights into the domestic tech landscape, helping to target high-value skills for local hiring.
*/
SELECT
    sd.skill_id,
    sd.skills,
    job_postings_fact.job_location AS local_demand,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary,
    COUNT(sjd.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim AS sjd ON sjd.job_id = job_postings_fact.job_id
INNER JOIN skills_dim AS sd ON sd.skill_id = sjd.skill_id
WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL AND
    job_location LIKE '%India' AND
    job_location NOT LIKE '%Indianapolis%'
GROUP BY
    sd.skill_id,
    job_location
HAVING
    COUNT(sjd.job_id) > 6
ORDER BY
    avg_salary DESC
LIMIT 25