-- Top job skills query

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



/*
Key Insights:

- SQL and Python are foundational — appearing in most job postings.

- Tableau is the top visualization tool sought after.

- Knowledge of R adds value, especially in statistical or research-heavy roles.

- Cloud & collaboration tools like Snowflake, Azure, and Bitbucket are becoming increasingly relevant.

- Familiarity with Excel remains important, often in tandem with modern tools.
*/