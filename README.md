# Introduction
This project explores the intersection of salary and demand in the data analytics field. It aims to identify the top-paying job titles, the most in-demand skills, and the roles where high compensation aligns with high market demand.

SQL Queries? Find them here: [project_sql folder](/project_sql/)

# Tools I Used
- **SQL (PostgreSQL)**
- **Visual Studio Code**

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

| Job Title                                        | Posted Date | Avg. Yearly Salary (USD) |
|--------------------------------------------------|-------------|---------------------------|
| Data Analyst                                     | 2023-02-20  | $650,000.00               |
| Director of Analytics                            | 2023-08-23  | $336,500.00               |
| Associate Director - Data Insights               | 2023-06-18  | $255,829.50               |
| Data Analyst, Marketing                          | 2023-12-05  | $232,423.00               |
| Data Analyst (Hybrid/Remote)                     | 2023-01-17  | $217,000.00               |
| Principal Data Analyst (Remote)                  | 2023-08-09  | $205,000.00               |
| Director, Data Analyst - HYBRID                  | 2023-12-07  | $189,309.00               |
| Principal Data Analyst, AV Performance Analysis  | 2023-01-05  | $189,000.00               |
| Principal Data Analyst                           | 2023-07-11  | $186,000.00               |
| ERM Data Analyst                                 | 2023-06-09  | $184,000.00               |

*Table of top 10 paying data analyst jobs*

#### Insights:
- **Top-Paying Role**: A Data Analyst position listed at $650K/year stands out; most other high-paying roles range from $184K to $336K, especially at the Director and Principal levels.

- **Specialization Pays**: Roles like Marketing and ERM Data Analysts show strong compensation, highlighting demand for domain-specific expertise.

- **Remote Trend**: All jobs are remote, confirming continued high demand for flexible, location-independent data roles in 2023.

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

#### Insights:
- SQL and Python are foundational — appearing in most job postings.

- Tableau is the top visualization tool sought after.

- Knowledge of R adds value, especially in statistical or research-heavy roles.

- Cloud & collaboration tools like Snowflake, Azure, and Bitbucket are becoming increasingly relevant.

- Familiarity with Excel remains important, often in tandem with modern tools.

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

#### Insights:
- SQL leads the pack with 7,291 postings, confirming its role as the foundational skill for data analysts.

- Excel and Python follow closely, showing the balance between traditional tools and modern programming skills.

- Visualization tools like Tableau and Power BI are also highly valued, reflecting the need for clear data communication.

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
	ON skills_job_dim.skill_id = skills_dim.skill_id
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

#### Insights:
- PySpark tops the list with an average salary of $208K, highlighting the value of big data and distributed processing expertise.

- Tool-based skills like Bitbucket, GitLab, and Watson command high salaries, reflecting demand for version control and AI platforms.

- Popular data tools like Pandas, Jupyter, and ElasticSearch remain valuable, showing strong pay for hands-on analytical and data engineering skills.

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

#### Insights:
- Snowflake, Azure, and AWS stand out with 30+ job postings and salaries above $108K, making them highly balanced in value and demand.

- Go offers the highest salary in this group ($115K), though with lower demand—ideal for niche specialists.

- Tools like Confluence, Jira, and SSIS show strong salaries despite moderate demand, indicating their value in project and data pipeline management.