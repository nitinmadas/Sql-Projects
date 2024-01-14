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
		


                        
