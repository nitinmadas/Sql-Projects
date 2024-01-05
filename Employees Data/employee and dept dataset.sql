select * from employee;
select * from dept;

select f_name, l_name, slaray from 
employee where slaray> 
(select slaray from employee where l_name='Bell'); 

select f_name, l_name, slaray from 
employee where slaray> 
(select slaray from employee where l_name='Bell') 
order by f_name asc; 

select emp_id, f_name, l_name, slaray from employee 
where emp_id in (select manager_id from employee);

select emp_id, f_name, l_name, phone, slaray from employee
where slaray>(select avg(slaray) from employee);
select avg(slaray) from employee;

select * from employee 
where employee.slaray = (select min(slaray) from employee);

select distinct f_name, l_name, slaray ,dept.dept
from employee inner join dept on employee.dept_id
where slaray > (select avg(slaray) from employee ) 
and dept.dept='Sales';
 
select distinct emp_id, f_name, l_name, slaray from employee
where slaray > (select max(slaray) from employee 
where job_id = 'SH_CLERK');

select emp_id, f_name, l_name, dept.dept
from employee inner join dept on employee.dept_id;