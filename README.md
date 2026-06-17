# Tech Salary & Skill Analytics (Data Analyst Market Study)

## 📌 Project Overview
As the tech landscape shifts, prioritizing which technical skills to learn can make or break a career transition. This project was developed to reverse-engineer the tech job market by analyzing thousands of data analyst job postings. By writing advanced SQL queries, this project uncovers the highest-paying roles, the most in-demand skills, and the optimal intersection where high demand meets top compensation.

### 🇮🇳 India Market Deep-Dive
While global trends offer a macro view, job markets are inherently local. A core pillar of this project is a dedicated, custom analysis targeting the **India market**. This section explores regional demand and salary dynamics to map out domestic hiring realities for data professionals.

---

## 🛠️ Key SQL Concepts Demonstrated
* **Common Table Expressions (CTEs):** Used to isolate logic, manage multi-step aggregations, and structure readable scripts.
* **Complex Joins:** Utilizing `LEFT JOIN` and multiple `INNER JOIN` operations to stitch fact tables to dimension datasets.
* **Data Aggregations:** Leveraging `COUNT()`, `AVG()`, and `ROUND()` functions to summarize market parameters.
* **Refactoring & Optimization:** Transforming verbose multi-step queries into high-performing single-block statements using `HAVING` clauses.

---

## 🔍 The Core Questions & SQL Code

### 1. The Global Top-Paying Roles
**Objective:** Identify the top 10 highest-paying Data Analyst roles globally to understand what specialized industries or senior positions yield the highest compensation.

```sql
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
LIMIT 10;
```
### 2. Skills Demanded by High-Paying Roles
**Objective:** Determine which specific skills are required for those top-paying jobs, showing what tools are worth a financial premium.

* **Technical Highlight:** Utilizes a **CTE** (`top_paying_jobs`) to capture top salary parameters before joining structural dimension tables.

```sql
WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        salary_year_avg,
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
)
SELECT
    top_paying_jobs.*,
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim AS sjd ON sjd.job_id = top_paying_jobs.job_id
INNER JOIN skills_dim AS sd ON sd.skill_id = sjd.skill_id
ORDER BY salary_year_avg DESC;
```
### 3. Most In-Demand Skills Globally
* **Objective**: Find out which skills appear most frequently across all postings, representing the absolute baseline requirements for the industry.

```sql
SELECT
    skills,
    COUNT(sjd.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim AS sjd ON sjd.job_id = job_postings_fact.job_id
INNER JOIN skills_dim AS sd ON sd.skill_id = sjd.skill_id
WHERE job_title_short = 'Data Analyst'
GROUP BY
    skills
ORDER BY
    demand_count DESC
LIMIT 5;
```
*Table of the demand for the top 5 skills in data analyst job postings*


| Skills   | Demand Count |
|----------|--------------|
| SQL      | 7291         |
| Excel    | 4611         |
| Python   | 4330         |
| Tableau  | 3745         |
| Power BI | 2609         |


### 4. High-Value Skills (Top Salaries)
* **Objective**: Analyze the average salary associated with individual skills to see which expertise drives higher paycheck values regardless of volume.

```sql
SELECT
    skills,
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
LIMIT 25;

```

*Table of the average salary for the top 10 paying skills for data analysts*

| Skills        | Average Salary ($) |
|---------------|-------------------:|
| pyspark       |            208,172 |
| bitbucket     |            189,155 |
| couchbase     |            160,515 |
| watson        |            160,515 |
| datarobot     |            155,486 |
| gitlab        |            154,500 |
| swift         |            153,750 |
| jupyter       |            152,777 |
| pandas        |            151,821 |
| elasticsearch |            145,000 |

*Table of the average salary for the top 10 paying skills for data analysts*
### 5. The Sweet Spot: Optimal Skills
* **Objective**: Find the "optimal" skills—those that have both a high volume of demand and command competitive, above-average salaries.
* **Technical Highlight**: This analysis showcases Query Optimization. The initial logic was developed using two independent CTEs joined together. It was then completely refactored into a concise single-block query utilizing a `HAVING` clause for identical performance and cleaner readability.

#### Approach A: Multi-CTE Architecture
```sql
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
LIMIT 25;
```

#### Approach B: Concise Single-Block Query (Refactored)
```sql
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
    sd.skill_id,
    sd.skills
HAVING
    COUNT(sjd.job_id) > 10
ORDER BY
    avg_salary DESC
LIMIT 25;
```
*Table of the most optimal skills for data analyst sorted by salary*

| Skill ID | Skills     | Demand Count | Average Salary ($) |
|----------|------------|--------------|-------------------:|
| 8        | go         | 27           |            115,320 |
| 234      | confluence | 11           |            114,210 |
| 97       | hadoop     | 22           |            113,193 |
| 80       | snowflake  | 37           |            112,948 |
| 74       | azure      | 34           |            111,225 |
| 77       | bigquery   | 13           |            109,654 |
| 76       | aws        | 32           |            108,317 |
| 4        | java       | 17           |            106,906 |
| 194      | ssis       | 12           |            106,683 |
| 233      | jira       | 20           |            104,918 |

### 6. Special Deep-Dive: India Market Analytics
* **Objective**: To break out of broad global averages, this query isolates job postings within India to map out local market realities, grouping findings by location to look for regional demand curves.

```sql
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
    job_location LIKE '%India%'
GROUP BY
    sd.skill_id,
    sd.skills,
    job_location
ORDER BY
    avg_salary DESC
LIMIT 25;
```

---

## 🧠 Key Takeaways & Strategic Conclusions

* **CTEs Structure Multi-Step Logic**: Utilizing CTEs proved essential for decoupling raw filtering tasks from subsequent joins, making scripts significantly easier to audit.
* **Refactoring Enhances Query Efficiency**: As demonstrated in the optimal skills analysis, structural knowledge of `HAVING` and `GROUP BY` allows long, nested subqueries/CTEs to be streamlined cleanly.
* **The Domestic Curve Matters**: Isolating Indian demand records a distinct pattern where specialized cloud platforms and data pipeline tools yield strong premiums relative to basic spreadsheet tracking.

### Closing Thoughts

This project enhanced my SQL skills and provided valuable insights into the data analyst job market. The findings from the analysis serve as a guide to prioritizing skill development and job search efforts. Aspiring data analysts can better position themselves in a competitive job market by focusing on high-demand, high-salary skills. This exploration highlights the importance of continuous learning and adaptation to emerging trends in the field of data analytics.

---


