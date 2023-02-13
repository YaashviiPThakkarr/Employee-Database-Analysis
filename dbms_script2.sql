SET LINESIZE 170
SET PAGESIZE 70
--Part II--

--Question 1-- 
COLUMN Employee FORMAT A30
COLUMN Training FORMAT A30
SELECT 
	e.emp_num || ':' || INITCAP(e.fname) || ' ' || INITCAP(e.lname) AS "Employee", 
	s.code || ':' || INITCAP(s.name) AS "Training", 
	COUNT(t.train_num) AS "#_of_skills", 
	MIN(t.date_acquired) AS "Date_Acquired", 
	TRUNC(MONTHS_BETWEEN(SYSDATE,MAX(t.date_acquired))) AS "Months_since_training"
FROM 
	training t 
JOIN employee e
ON t.emp_num = e.emp_num
JOIN skill s
ON t.code = s.code	
GROUP BY 
	(e.emp_num,e.fname,e.lname,s.code,s.name);

--Question 2-- 
COLUMN Employee FORMAT A30
COLUMN Department FORMAT A30
SELECT LEVEL, LPAD(' ', 3*(LEVEL-1)) || e.emp_num || ':' || INITCAP(e.fname) || ' ' || INITCAP(e.lname) AS "Employee", 
	d.dept_code || ':' || d.name AS "Department"
	FROM employee e, department d
	WHERE e.dept_code = d.dept_code
	START WITH e.emp_num = (
	SELECT emp_num FROM employee WHERE super_id is null)
	CONNECT BY PRIOR e.emp_num = e.super_id;

--Question 3-- 
COLUMN Project_Name FORMAT A30
SELECT p.proj_number || ':' || p.name AS Project_Name, TO_CHAR(date_assigned, 'MM-YYYY') as month_year,
NVL(COUNT(a.assign_num),0) AS "#_employees", 
NVL(SUM(hours_used),0) AS hours_used
	FROM assignment a
	INNER JOIN
	(SELECT * FROM project WHERE total_cost IS NULL)p
	ON a.proj_number = p.proj_number
	GROUP BY GROUPING SETS((p.proj_number || ':' || p.name,TO_CHAR(date_assigned, 'MM-YYYY')),
	p.proj_number || ':' || p.name);

--Question 4-- 
ALTER TABLE Employee
	ADD (bonus_amt NUMBER(5) DEFAULT 0);

UPDATE employee e1
	SET bonus_amt = (SELECT NVL(bonus,0) FROM 
	(
	SELECT * FROM employee
		LEFT OUTER JOIN(
		SELECT emp_num, SUM(bonus_per_project) bonus
		FROM
		(
			SELECT emp_num, proj_number,SUM(hours_used)"Total Time", 200 bonus_per_project
			FROM project JOIN assignment USING (proj_number)
			WHERE start_date >= '01-JAN-'|| EXTRACT(YEAR FROM SYSDATE)
			AND start_date <='31-MAR-'|| EXTRACT(YEAR FROM SYSDATE)
			GROUP BY emp_num, proj_number
			HAVING SUM(hours_used)>=150
			)
	    GROUP BY emp_num
		)USING(emp_num)
	)e2
	WHERE e1.emp_num = e2.emp_num
);

COLUMN Name FORMAT A25
COLUMN Super_id FORMAT A12
SELECT emp_num || ':' || INITCAP(fname) || ' ' || INITCAP(lname) AS Name,
 DOB, 
 hire_date, 
 NVL(TO_CHAR(super_id),'---') AS Super_id, 
 dept_code, TO_CHAR(bonus_amt, '$9999.99') AS bonus_amt 
FROM employee;
	
--Question 5 -- 
COLUMN Employee FORMAT A20
COLUMN Hire_date FORMAT A20
COLUMN Training_received FORMAT A30	
SELECT 
	e.emp_num || ':' || INITCAP(e.fname) || ' ' || INITCAP(e.lname) AS "Employee", e.hire_date, 
	t.train_num || ':' || t.name AS "Training_received", t.date_acquired,
	t.date_acquired - e.hire_date AS "Days", NVL("Project_count",0) AS "Project_#"
FROM	
	(
	SELECT * 
	FROM employee 
	WHERE hire_date BETWEEN '01-APR-21' and '30-JUN-21'
	) e
LEFT JOIN 
	training t
ON e.emp_num = t.emp_num
LEFT JOIN	 
	(
	SELECT emp_num, 
	NVL(COUNT(DISTINCT(proj_number),0) AS "Project_count"
	FROM assignment
	GROUP BY emp_num
	) a
ON e.emp_num = a.emp_num;
 

--Question 6-- 
COLUMN Status FORMAT A12
SELECT p.proj_number, p.start_date, 
CASE 
WHEN p.total_cost IS NULL THEN 'Ongoing'
ELSE 'Completed'
END AS Status
FROM
	(SELECT A.proj_number, B.date_assigned - A.date_ended AS date_diff
	FROM 
	(
		(SELECT proj_number, date_assigned, date_ended,
				DENSE_RANK() OVER(PARTITION BY proj_number ORDER BY date_assigned) AS rank1
		 FROM
		 assignment
		 GROUP BY proj_number, date_assigned, date_ended)A
		 INNER JOIN
				(
				SELECT proj_number, date_assigned,date_ended,
				DENSE_RANK() OVER(PARTITION BY proj_number ORDER BY date_assigned) AS rank2
				FROM
				assignment
				GROUP BY proj_number, date_assigned, date_ended
				)B
			ON rank1 = rank2-1 AND A.proj_number = B.proj_number
		)
	)C
INNER JOIN project p
ON C.proj_number = p.proj_number
WHERE C.date_diff >30;


--Question 7-- updated in google doc
COLUMN Quarter FORMAT A20
SELECT C.Quarter AS "Quarter",
  NVL(COUNT(DISTINCT B.proj_number),0) AS "#_Project",
  NVL(COUNT(DISTINCT B.emp_num),0) AS "#_Employees", 
  NVL(ROUND(AVG(B.hours_used)),0) AS "Avg_hours"
FROM(
	(
	SELECT p.proj_number,
	CASE
		WHEN p.start_date BETWEEN '01-JAN-21' AND '31-MAR-21' THEN 'Quarter1'
		WHEN p.start_date BETWEEN '01-APR-21' AND '30-JUN-21' THEN 'Quarter2'
		WHEN p.start_date BETWEEN '01-JUL-21' AND '30-SEP-21' THEN 'Quarter3'
		WHEN p.start_date BETWEEN '01-OCT-21' AND '31-DEC-21' THEN 'Quarter4'
		END AS Quarter
	FROM project p
	WHERE p.start_date > '31-DEC-20')C
JOIN 
	(
	SELECT a.proj_number, a.emp_num, a.hours_used,
	CASE
		WHEN a.date_assigned BETWEEN '01-JAN-21' AND '31-MAR-21' THEN 'Quarter1'
		WHEN a.date_assigned BETWEEN '01-APR-21' AND '30-JUN-21' THEN 'Quarter2'
		WHEN a.date_assigned BETWEEN '01-JUL-21' AND '30-SEP-21' THEN 'Quarter3'
		WHEN a.date_assigned BETWEEN '01-OCT-21' AND '31-DEC-21' THEN 'Quarter4'
		END AS Quarter
	FROM assignment a)B
	ON C.Quarter = B.Quarter AND C.proj_number = B.proj_number
	)
GROUP BY C.Quarter;


--Question 8-- remove justify for skills
/* Since there are 12 skills in our Skill table, the output will be very long, we are just printing 5 skills according
to the given output in the question. */
SET LINESIZE 1000
SET PAGSIZE 1000
COLUMN "Employee Name" FORMAT A20
COLUMN "ID" FORMAT A10
COLUMN "Number of skills:" FORMAT A20
COLUMN "Latest Date Acquired" FORMAT A12
COLUMN "Admin Report" FORMAT 12 justify center 
COLUMN "SAS" FORMAT 3 justify center 
COLUMN "R Tools" FORMAT 7 justify center
COLUMN "Cash Flows" FORMAT 10 justify center 
COLUMN "Java" FORMAT 4 justify center 
COLUMN "Latest Date Acquired" heading 'Latest|Date|Acquired' justify center
COLUMN "Number of Skills:" heading 'Number|of|Skills:' justify center 
SELECT TO_CHAR(e.emp_num) AS "ID" ,INITCAP(e.fname) ||' '|| INITCAP(e.lname) AS "Employee Name",      
         SUM(DECODE(s.code,1004,1,0)) "Admin Report",
         NVL(TO_CHAR(MAX(DECODE(s.code,1004,t.date_acquired)),'MM/DD/YY'),'------') "Latest Date Acquired",
         SUM(DECODE(s.code,1010,1,0)) "SAS",
         NVL(TO_CHAR(MAX(DECODE(s.code,1010,t.date_acquired)),'MM/DD/YY'),'------') "Latest Date Acquired",
         SUM(DECODE(s.code,1016,1,0)) "R Tools",
         NVL(TO_CHAR(MAX(DECODE(s.code,1016,t.date_acquired)),'MM/DD/YY'),'------') "Latest Date Acquired",
		 SUM(DECODE(s.code,1009,1,0)) "Cash Flows",
         NVL(TO_CHAR(MAX(DECODE(s.code,1009,t.date_acquired)),'MM/DD/YY'),'------') "Latest Date Acquired",
		 SUM(DECODE(s.code,1014,1,0)) "Java",
         NVL(TO_CHAR(MAX(DECODE(s.code,1014,t.date_acquired)),'MM/DD/YY'),'------') "Latest Date Acquired",
         NVL(TO_CHAR(COUNT(t.code)),0) "Number of Skills:"
	FROM employee e 
	LEFT JOIN training t 		
	ON e.emp_num = t.emp_num
    LEFT JOIN skill s 
	ON t.code = s.code
	GROUP BY e.emp_num, e.fname,e.lname
UNION ALL
SELECT '---', 'Number of Trainings:' , SUM(F.A),'------', SUM(F.B), '------',SUM(F.C),'------',SUM(F.D),
	'------',SUM(F.E),'------','------' 
FROM(
	SELECT TO_CHAR(e.emp_num) AS "ID",
       e.fname ||' '|| e.lname AS "Employee name",      
         SUM(DECODE(s.code,1004,1,0)) A,
         NVL(TO_CHAR(MAX(DECODE(s.code,1004,t.date_acquired)),'MM/DD/YY'),'------') "Latest Date Acquired",
         SUM(DECODE(s.code,1010,1,0)) B,
         NVL(TO_CHAR(MAX(DECODE(s.code,1010,t.date_acquired)),'MM/DD/YY'),'------') "Latest Date Acquired",
         SUM(DECODE(S.CODE,1016,1,0)) C,
         NVL(TO_CHAR(MAX(DECODE(s.code,1016,t.date_acquired)),'MM/DD/YY'),'------') "Latest Date Acquired",
		 SUM(DECODE(s.code,1009,1,0)) D,
         NVL(TO_CHAR(MAX(DECODE(s.code,1009,t.date_acquired)),'MM/DD/YY'),'------') "Latest Date Acquired",
		 SUM(DECODE(s.code,1014,1,0)) E,
         NVL(TO_CHAR(MAX(DECODE(s.code,1014,t.date_acquired)),'MM/DD/YY'),'------') "Latest Date Acquired",
         NVL(COUNT(t.code),0) "Number of skills:"
	FROM employee e 
	LEFT JOIN training t 
	ON e.emp_num = t.emp_num
    LEFT JOIN skill s 
	ON t.code = s.code
  GROUP BY e.emp_num, e.fname,e.lname
  ORDER BY e.emp_num)F;


--Question 9-- 

BREAK ON Name
COLUMN Name FORMAT A30
COLUMN Trained_skill FORMAT A40
SELECT 
	dept_code || ':' || dept_name AS Name, 
	skill_code || ':' || skill_name AS Trained_skill, skill_count,
	DENSE_RANK() OVER (PARTITION BY dept_code ORDER BY skill_count DESC) AS rankings
FROM
(
	SELECT A.dept_code, dept_name, skill_code, skill_name, COUNT(DISTINCT t.train_num) AS skill_count
	FROM
		(
		SELECT d.dept_code, d.name AS dept_name, s.code AS skill_code, s.name AS skill_name
		FROM department d
		CROSS JOIN skill s
		) A
	LEFT JOIN employee e
	ON A.dept_code = e.dept_code 
	LEFT JOIN training t
	ON A.skill_code = t.code AND t.emp_num = e.emp_num
	GROUP BY A.dept_code, dept_name, skill_code, skill_name
);


--Group 10-- 
COLUMN Name FORMAT A30
SELECT p.proj_number || ':' || p.name AS Name, SUM(date_ended - date_assigned) AS Total_days
FROM 
(	SELECT proj_number,SUM(days) 
	FROM
		( 
		SELECT proj_number, days,
		DENSE_RANK() OVER(ORDER BY days DESC) AS day_rank
		FROM 
			(
			SELECT assign.proj_number, assign.date_assigned, assign.date_ended, 
			assign.date_ended - assign.date_assigned AS days
			  FROM assignment assign
			  JOIN 
				(
				SELECT proj_number, emp_num
				FROM assignment 
				GROUP BY proj_number, emp_num
				HAVING COUNT(proj_number) >=5
				) A
				ON assign.proj_number = A.proj_number
			)
		)	
	WHERE day_rank<4
	GROUP BY proj_number
	HAVING SUM(days)>=60
)B
JOIN assignment a 
ON B.proj_number = a.proj_number
JOIN project p
ON p.proj_number = a.proj_number
GROUP BY p.proj_number, p.name;


--Question 11--  
/* The seniority in this query is based on the hire date of the employees */
COLUMN Employee FORMAT A20
COLUMN hire_date FORMAT A20
COLUMN dept FORMAT A20
SELECT B.emp_num || ': ' || INITCAP(B.lname) AS Employee, B.hire_date,
	NVL(B.dept_name,'Administrative') AS dept, 
	NVL(COUNT(DISTINCT emp.emp_num),0) AS "#_employee_supervises"
FROM
	(SELECT emp_num, lname, hire_date, d.name AS dept_name
	FROM
			(SELECT emp_num, lname, hire_date,
			RANK() OVER (ORDER BY hire_date ASC) as senior_ranks
			FROM 
			employee e
			) A
	LEFT JOIN department d
	ON A.emp_num = d.manager_id
	WHERE senior_ranks <5) B
LEFT JOIN employee emp
ON B.emp_num = emp.super_id
GROUP BY B.emp_num, B.lname, B.hire_date, B.dept_name;


--Question 12-- 
COLUMN client_type FORMAT A30
SELECT 
CASE 
	WHEN web_address LIKE '%.edu' THEN 'Educational Institute'
	WHEN web_address LIKE '%.gov' THEN 'Government Agency'
	WHEN web_address LIKE '%.org' THEN 'Non-For-Profit Organisation'
	WHEN web_address LIKE '%.com' THEN 'For-Profit Organisation'
	WHEN web_address IS NULL THEN 'Not Available'
	ELSE 'Others'
	END AS client_type,
 NVL(COUNT(c.client_id),0) AS "#_of_clients",
 NVL(COUNT(p.proj_number),0) AS "#_of_projects"
FROM 
client c
LEFT JOIN project p
ON c.client_id = p.client_id
GROUP BY 
CASE 
	WHEN web_address LIKE '%.edu' THEN 'Educational Institute'
	WHEN web_address LIKE '%.gov' THEN 'Government Agency'
	WHEN web_address LIKE '%.org' THEN 'Non-For-Profit Organisation'
	WHEN web_address LIKE '%.com' THEN 'For-Profit Organisation'
	WHEN web_address IS NULL THEN 'Not Available'
	ELSE 'Others'
END;

--Question 13-- CHANGE in file 
COLUMN name FORMAT A30
COLUMN dept_name FORMAT A30
COLUMN project_name FORMAT A30
SELECT e.emp_num || ': ' || INITCAP(e.fname) || ' ' || INITCAP(e.lname) AS Name,
	d.dept_code || ': ' || d.name AS dept_name, 
	p.proj_number || ': ' || INITCAP(p.name) AS project_name
FROM
	(
	SELECT emp_num, proj_number, date_assigned FROM
		(
			SELECT emp_num, proj_number, date_assigned, 
			RANK() OVER(PARTITION BY emp_num ORDER BY date_assigned DESC) as date_rank
			FROM assignment
		) 
	WHERE date_rank = 1 AND date_assigned <= '31-JUL-'|| EXTRACT(YEAR FROM SYSDATE)
	)A
JOIN employee e
ON A.emp_num = e.emp_num 
LEFT JOIN department d
ON e.dept_code = d.dept_code
JOIN project p
ON A.proj_number = p.proj_number 
ORDER BY d.name,e.lname;

--Question 14-- 
COLUMN Category FORMAT A20
(
SELECT s.category AS "Category",
	NVL(COUNT(DISTINCT p.proj_number),0) AS "#_of_trainings", 
	NVL(COUNT(DISTINCT a.assign_num),0) AS "#_of_projects"
FROM
skill s
LEFT JOIN project p
ON s.code = p.code
LEFT JOIN assignment a
ON p.proj_number = a.proj_number
GROUP BY s.category
)
UNION ALL
(
SELECT '--------Grand Total:', 
	COUNT(DISTINCT p.proj_number),
	COUNT(DISTINCT a.assign_num)
FROM
skill s
LEFT JOIN project p
ON s.code = p.code
LEFT JOIN assignment a
ON p.proj_number = a.proj_number
);

--Question 15--
CONNECT SYSTEM/Johnheinz#1
CREATE USER yashviDB IDENTIFIED BY yashvithakkar;
GRANT DBA TO yashviDB;
CONNECT yasvhiDB/yashvithakkar

COLUMN "Constraint Type" FORMAT A20
COLUMN "Search Condition" FORMAT A60
COLUMN "Table Name" FORMAT A12
COLUMN "Column Name" FORMAT A18
COLUMN "FK References" FORMAT A30
COLUMN "Constraint Type" FORMAT A20
BREAK ON "Table Name"
SELECT
utc.Table_Name "Table Name",
utc.Column_Name "Column Name",
	NVL(unc.Constraint_Name, '--') "Constraint Type",
	CASE
		WHEN u.Constraint_Type = 'P' THEN 'PK'
		WHEN u.Constraint_Type = 'R' THEN 'FK'
		WHEN u.Constraint_Type = 'C' AND LOWER(u.Constraint_Name) LIKE '%ck%' THEN 'CK'
		WHEN u.Constraint_Type = 'C' AND LOWER(u.Constraint_Name) LIKE '%nn%' THEN 'NN'
		ELSE '--'
		END "Constraint Type",
	NVL(SUBSTR(ac.R_Constraint_Name, 0, LENGTH(ac.R_Constraint_Name) - 3), '--') "FK References",
	u.Search_Condition "Search Condition"
FROM user_tab_columns utc
LEFT OUTER JOIN user_cons_columns unc on
utc.Table_Name = unc.Table_Name
AND utc.Column_Name = unc.Column_Name
FULL OUTER JOIN user_constraints u on
unc.Constraint_Name = u.Constraint_Name
LEFT JOIN all_constraints ac on
unc.Constraint_Name = ac.Constraint_Name
ORDER BY
utc.Table_Name ASC;