select * from heart_disease order by id desc limit 10;
select age,chest_pain,heart_disease from heart_disease;
select count(id) from heart_disease where heart_disease="Yes";
select chest_pain,avg(cholesterol) from heart_disease group by chest_pain;
select sex, chest_pain, max(age) from heart_disease group by sex,chest_pain;
select chest_pain, restecg, min(cholesterol) from heart_disease where restecg = "Abnormal" group by chest_pain;
select * from heart_disease order by thalassaemia_test desc limit 5;
select * from heart_disease where cholesterol>(select avg(cholesterol) from heart_disease);
select avg(thalassaemia_test) from heart_disease;
select sex, chest_pain, restecg, heart_disease,avg(thalassaemia_test) from heart_disease group by sex, chest_pain, restecg, heart_disease;
select sex, chest_pain, restecg, heart_disease,avg(thalassaemia_test) from heart_disease
 where (select avg(thalassaemia_test) group by sex, chest_pain, restecg, heart_disease)>
 (select avg(thalassaemia_test) from heart_disease)
 group by sex,chest_pain,restecg,heart_disease;
 
