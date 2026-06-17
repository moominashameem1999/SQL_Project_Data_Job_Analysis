/*
Answer: What are the most optimal skills to learn (aka it’s in high demand and a high-paying skill)?
- Identify skills in high demand and associated with high average salaries for Data Analyst roles
- Concentrates on remote positions with specified salaries
- Why? Targets skills that offer job security (high demand) and financial benefits (high salaries), 
    offering strategic insights for career development in data analysis
*/
WITH skills_demand AS (
    SELECT
        sd.skills,
        sd.skill_id,
        COUNT(sjd.job_id) AS demand_count
    FROM job_postings_fact
    INNER JOIN skills_job_dim AS sjd ON sjd.job_id = job_postings_fact.job_id
    INNER JOIN skills_dim AS sd ON sd.skill_id = sjd.skill_id
    WHERE job_title_short = 'Data Analyst'
    GROUP BY
        skills
    ORDER BY
        demand_count DESC
), 
average_salary AS (
    SELECT
        skills,
        skills_dim.skill_id,
        ROUND(AVG(salary_year_avg), 0) AS avg_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim AS sjd ON sjd.job_id = job_postings_fact.job_id
    INNER JOIN skills_dim AS sd ON sd.skill_id = sjd.skill_id
    WHERE 
        job_title_short = 'Data Analyst' AND
        salary_year_avg IS NOT NULL
    GROUP BY
        skills
    ORDER BY
        avg_salary DESC
)
SELECT
    skills_demand.skill_id,
    skills_demand.skills,
    skills_demand.demand_count,
    average_salary.avg_salary
FROM skills_demand
INNER JOIN average_salary ON skills_demand.skill_id = average_salary.skill_id
WHERE demand_count > 10
ORDER BY
    demand_count DESC,
    average_salary DESC
LIMIT 25

-- rewriting this same query more concisely

SELECT
    sd.skill_id,
    sd.skills,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary,
    COUNT(sjd.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim AS sjd ON sjd.job_id = job_postings_fact.job_id
INNER JOIN skills_dim AS sd ON sd.skill_id = sjd.skill_id
WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL
GROUP BY
    sd.skill_id
HAVING
    COUNT(sjd.job_id) > 10
ORDER BY
    avg_salary DESC
LIMIT 25