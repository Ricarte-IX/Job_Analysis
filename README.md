# Introduction
This project explores the intersection of salary and demand in the data analytics field. It aims to identify the top-paying job titles, the most in-demand skills, and the roles where high compensation aligns with high market demand.

SQL Queries? Find them here: [project_sql folder](/project_sql/)

# Tools I Used
- **SQL (PostgreSQL)**
- **Visual Studio Code**
- **Git & GitHub**

# The Analysis
### 1. Top-Paying Data Analyst Jobs
Filtered data analyst positions by average yearly salary and location, focusing on remote jobs.

```sql
SELECT
	job_title,
	CASE 
    	WHEN job_location = 'Anywhere' THEN 'Remote'
  	END AS job_location,
  	job_posted_date::DATE,
  	salary_year_avg
FROM job_postings_fact
WHERE 
	job_title_short = 'Data Analyst' AND 
	job_location = 'Anywhere' AND
	salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;
```
### 2. Skills for Top-Paying Jobs
Joined the job postings with the skills data providing the skills that employers value for high-compensation roles
```sql
WITH top_paying_jobs AS (
	SELECT
		job_id,
		job_title,
		salary_year_avg
	FROM job_postings_fact
	WHERE 
		job_title_short = 'Data Analyst' AND 
		job_location = 'Anywhere' AND
		salary_year_avg IS NOT NULL
	ORDER BY salary_year_avg DESC
	LIMIT 10)

SELECT top_paying_jobs.*,
	skills
FROM top_paying_jobs
INNER JOIN skills_job_dim
	ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim
	ON  skills_job_dim.skill_id = skills_dim.skill_id;
```
### 3. In-demand Skills
Identifies the skills most frequently requested in job postings 
```sql
SELECT
	skills,
	COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim
	ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim
	ON  skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
	job_title_short = 'Data Analyst' AND
	job_location LIKE '%Germany%'
GROUP BY skills
ORDER BY demand_count DESC
LIMIT 5;
```
| Skill     | Demand Count |
|-----------|--------------|
| SQL       | 7,291        |
| Excel     | 4,611        |
| Python    | 4,330        |
| Tableau   | 3,745        |
| Power BI  | 2,609        |

*Table of the demand for the top 5 skills in data analyst postings*

### 4. Top-Paying Skills
Explored the average salaries associated with different skills revealed which skills are the highest paying
```sql
SELECT
	skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim
	ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim
	ON  skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
	job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL AND
    job_work_from_home = TRUE
GROUP BY
    skills
ORDER BY avg_salary DESC
LIMIT 10;
```
| Skill         | Average Salary ($) |
|---------------|--------------------|
| PySpark       | 208,172            |
| Bitbucket     | 189,155            |
| Watson        | 160,515            |
| Couchbase     | 160,515            |
| DataRobot     | 155,486            |
| GitLab        | 154,500            |
| Swift         | 153,750            |
| Jupyter       | 152,777            |
| Pandas        | 151,821            |
| Elasticsearch | 145,000            |

*Table of the average salary for the top 10 paying skills for data analyst*
### 5. Most Optimal Skills
Combined insights from demand and salary data, this query aimed to pinpoint skills that are both in high demand and have high salaries
```sql
SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(salary_year_avg), 0) AS average_salary
FROM
    job_postings_fact
INNER JOIN skills_job_dim
        ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim
        ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL AND
    job_work_from_home = TRUE
GROUP BY
    skills_dim.skill_id
HAVING 
    COUNT(skills_job_dim.job_id) > 10
ORDER BY 
    average_salary DESC,
    demand_count DESC
LIMIT 25;
```
| Skill ID | Skill       | Demand Count | Average Salary ($) |
|----------|-------------|---------------|---------------------|
| 8        | Go          | 27            | 115,320             |
| 234      | Confluence  | 11            | 114,210             |
| 97       | Hadoop      | 22            | 113,193             |
| 80       | Snowflake   | 37            | 112,948             |
| 74       | Azure       | 34            | 111,225             |
| 77       | BigQuery    | 13            | 109,654             |
| 76       | AWS         | 32            | 108,317             |
| 4        | Java        | 17            | 106,906             |
| 194      | SSIS        | 12            | 106,683             |
| 233      | Jira        | 20            | 104,918             |

*Table of the most optimal skills for data analyst sorted by salary*