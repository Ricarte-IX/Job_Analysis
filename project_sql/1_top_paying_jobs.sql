-- Top-paying remote data analyst jobs query

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