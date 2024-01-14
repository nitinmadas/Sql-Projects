USE boxoffice;

#1
SELECT title,boxoffice FROM boxoffice;
#2
SELECT title, boxoffice 
FROM boxoffice
WHERE imdb_score > 5;

#3
SELECT title, boxoffice 
FROM boxoffice
WHERE runtime = '> 2 hrs';

#4
SELECT native,count(title)
FROM boxoffice
GROUP BY 1;
#5
SELECT genre,native,count(title)
FROM boxoffice
GROUP BY 1,2;

#6a
SELECT title, imdb_score
FROM boxoffice
WHERE imdb_score = (SELECT MIN(imdb_score) 
						FROM boxoffice);
#6b
SELECT title, imdb_score
FROM boxoffice
WHERE imdb_score = (SELECT MAX(imdb_score)
						FROM boxoffice);
		
#7
SELECT genre,COUNT(title) AS cnt
FROM boxoffice
GROUP BY 1
ORDER BY cnt DESC
LIMIT 1;

#8a
SELECT title,boxoffice FROM boxoffice
ORDER BY boxoffice LIMIT 5;

#8b
SELECT title,boxoffice FROM boxoffice
ORDER BY boxoffice DESC LIMIT 5;

#9
SELECT genre,round(AVG(imdb_score),2) AS avg_imdb_rating
FROM boxoffice
GROUP BY 1;

#10
SELECT title
FROM boxoffice
WHERE title RLIKE '^The.*';

#11
SELECT title
FROM boxoffice
WHERE title RLIKE '.*man$';

#12
SELECT title
FROM boxoffice
WHERE title RLIKE '.*(story|man|love).*';	

#13
SELECT title
FROM boxoffice
WHERE title RLIKE '.*(story|man|love)$';



                        
