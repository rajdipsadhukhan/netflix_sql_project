-- Netflix project
DROP TABLE netflix;
CREATE TABLE netflix(
	show_id	VARCHAR(10),
	type VARCHAR(10), 	
	title VARCHAR(150),	
	director VARCHAR(250),	
	casts VARCHAR(1000),	
	country VARCHAR(200),	
	date_added VARCHAR(100),	
	release_year INT,	
	rating VARCHAR(10),
	duration VARCHAR(100),	
	listed_in VARCHAR(100),	
	description VARCHAR(300)

);

SELECT * FROM netflix;

SELECT COUNT(*) AS total_content FROM netflix;

-- 15 Business Problem
-- 1. count the number of movies vs tv shows
	SELECT type , COUNT(*) AS total_content FROM netflix GROUP BY type;

-- 2. find the most common rating for movies and tv shows
	SELECT 
	type,
	rating 
	FROM
	(
	SELECT type ,rating , COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix 
	GROUP BY 1,2
	
	) AS t1
	WHERE ranking = 1;

-- 3. List all the movies released in 2020 .
	SELECT * FROM netflix
	WHERE release_year = 2020 AND type = 'Movie';

-- 4. Find the top 5 countries with the most content on netflix
	SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) AS new_country,
	COUNT(show_id) AS total_content
	FROM netflix
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 5;

-- 5. Identify the longest movie.
	SELECT * FROM netflix
	WHERE type='Movie' AND duration = (SELECT MAX(duration) FROM netflix);
	

SELECT * FROM netflix;
-- 6.Find the content that added in the last 5 years.
SELECT * FROM netflix
WHERE TO_DATE(date_added,'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '5'

-- 7. Find all the movies /TV shows by Rajiv Chilaka.
SELECT type,title,director FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows that has more than 5 seasons.
SELECT * FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration,' ',1)::numeric > 5;

-- 9. Count the number of content in each genre.
SELECT show_id,listed_in,
UNNEST(STRING_TO_ARRAY(listed_in,','))
FROM netflix;

-- 10. Find each year and average number of contents released by India on netflix,
	-- return top 5 year with highest average contents released.
SELECT
EXTRACT (YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) AS year,
COUNT(*) AS yearly_content,
ROUND(
COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric*100
,2)
as avg_content_per_year
FROM netflix
WHERE country='India'
GROUP BY 1;

-- 11.List all movies that are documentaries.
SELECT * FROM netflix
WHERE type = 'Movie'
AND listed_in ILIKE '%Documentaries%';

-- 12.Find all content without director.
SELECT * FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years.
SELECT * FROM netflix
WHERE casts ILIKE '%Salman Khan%' AND release_year > EXTRACT( YEAR FROM CURRENT_DATE)-10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
UNNEST(STRING_TO_ARRAY(casts,',')) AS actors,
COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15. Categories the content based on the presence of the keywords 'kill' and 'violence'
-- in the description field. Label content containing these keywords as 'Bad' and all other
-- content as 'Good'. Count how many items fall into each category.
WITH new_table
AS
(
SELECT * ,
CASE 
WHEN  description ILIKE '%kills%'
	OR
	  description ILIKE '%violence%' THEN 'Bad_content'
	  ELSE 'Good_content'
END category

FROM netflix
)
SELECT category,
COUNT(*) AS total_content
FROM new_table
GROUP BY 1;
	  



