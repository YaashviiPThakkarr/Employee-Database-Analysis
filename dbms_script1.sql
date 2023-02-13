DROP TABLE skill CASCADE CONSTRAINTS;
DROP TABLE department CASCADE CONSTRAINTS;
DROP TABLE employee CASCADE CONSTRAINTS;
DROP TABLE training CASCADE CONSTRAINTS;
DROP TABLE client CASCADE CONSTRAINTS;
DROP TABLE project CASCADE CONSTRAINTS;
DROP TABLE assignment CASCADE CONSTRAINTS;

CREATE TABLE skill
( Code NUMBER(4),
  Name VARCHAR2(30) CONSTRAINT skill_name_NN NOT NULL,
  Category VARCHAR2(20) CONSTRAINT skill_category_NN NOT NULL,
  CONSTRAINT skill_code_PK PRIMARY KEY (Code)
);

CREATE TABLE department
( Dept_Code NUMBER(4),
  Name VARCHAR2(30) CONSTRAINT department_name_NN NOT NULL,
  Location VARCHAR2(20) CONSTRAINT department_location_NN NOT NULL,
  Phone VARCHAR2(12),
  Manager_ID NUMBER(4),
  CONSTRAINT department_dept_code_PK PRIMARY KEY (Dept_Code),
  CONSTRAINT department_phone_CK CHECK (REGEXP_LIKE (Phone, '^([0-9]{3}-[0-9]{3}-[0-9]{4})$'))
);
  
CREATE TABLE employee 
( Emp_Num NUMBER(4),
  LName VARCHAR2(15) CONSTRAINT employee_lname_NN NOT NULL,
  FName VARCHAR2(15) CONSTRAINT employee_fname_NN NOT NULL,
  DOB DATE,
  Hire_Date DATE DEFAULT SYSDATE,
  Super_ID NUMBER(4),
  Dept_Code NUMBER(4),
  CONSTRAINT employee_emp_num_PK PRIMARY KEY (Emp_Num),
  CONSTRAINT employee_super_id_FK FOREIGN KEY(Super_ID) REFERENCES employee(Emp_Num),
  CONSTRAINT employee_dept_code_FK FOREIGN KEY(Dept_Code) REFERENCES department(Dept_Code),
  CONSTRAINT employee_dob_CK CHECK (REGEXP_LIKE (DOB, '^([0-9]{2}[-][a-zA-Z]{3}[-][0-9]{2})$')),
  CONSTRAINT employee_hire_date_CK CHECK (REGEXP_LIKE (Hire_Date, '^([0-9]{2}[-][a-zA-Z]{3}[-][0-9]{2})$')) 
);
  

CREATE TABLE training
( Train_Num NUMBER(4), 
  Code NUMBER(4),
  Emp_Num NUMBER(4),
  Name VARCHAR2(30) CONSTRAINT training_name_NN NOT NULL,
  Date_Acquired DATE DEFAULT SYSDATE,
  Comments VARCHAR2(50),
  CONSTRAINT training_train_num_PK PRIMARY KEY (Train_Num),
  CONSTRAINT training_code_FK FOREIGN KEY(Code) REFERENCES skill(Code),
  CONSTRAINT training_emp_num_FK FOREIGN KEY(Emp_Num) REFERENCES employee(Emp_Num),
  CONSTRAINT training_date_acquired_CK CHECK (REGEXP_LIKE (Date_Acquired, '^([0-9]{2}[-][a-zA-Z]{3}[-][0-9]{2})$'))
);
  
CREATE TABLE client
( Client_ID NUMBER(4),
  Name VARCHAR2(30) CONSTRAINT client_name_NN NOT NULL,
  Street VARCHAR2(30) CONSTRAINT client_street_NN NOT NULL,
  City VARCHAR2(20) CONSTRAINT client_city_NN NOT NULL,
  State VARCHAR2(2) CONSTRAINT client_state_NN NOT NULL,
  Zip_Code VARCHAR2(5),
  Industry VARCHAR2(30) CONSTRAINT client_industry_NN NOT NULL,
  Web_Address VARCHAR2(30) CHECK (REGEXP_LIKE (Web_Address, '^[www]{3}.[a-zA-Z0-9]+.[a-z]{3}$')),
  Phone VARCHAR2(12) CHECK(REGEXP_LIKE (Phone, '^([0-9]{3}[-][0-9]{3}[-][0-9]{4})$')),
  Contact_LName VARCHAR2(30) CONSTRAINT contact_lname_NN NOT NULL,
  Contact_FName VARCHAR2(30) CONSTRAINT contact_fname_NN NOT NULL,
  CONSTRAINT client_client_id_PK PRIMARY KEY (Client_ID),
  CONSTRAINT client_state_CK CHECK (LENGTH(State) = 2),
  CONSTRAINT client_zip_code_CK CHECK (LENGTH(Zip_Code) = 5)
);

CREATE TABLE project 
( Proj_Number NUMBER(4),
  Name VARCHAR2(30) CONSTRAINT project_name_NN NOT NULL,
  Start_Date DATE DEFAULT SYSDATE,
  Total_Cost NUMBER(5),
  Dept_Code NUMBER(4),
  Client_ID NUMBER(4),
  Code NUMBER(4),
  CONSTRAINT project_number_PK PRIMARY KEY (Proj_Number),
  CONSTRAINT project_dept_code_FK FOREIGN KEY(Dept_Code) REFERENCES department(Dept_Code),
  CONSTRAINT project_client_id_FK FOREIGN KEY(Client_ID) REFERENCES client(Client_ID),
  CONSTRAINT project_code_FK FOREIGN KEY(Code) REFERENCES skill(Code),
  CONSTRAINT project_date_CK CHECK (REGEXP_LIKE (Start_Date, '^([0-9]{2}[-][a-zA-Z]{3}[-][0-9]{2})$'))
);



CREATE TABLE assignment
( Assign_Num NUMBER(4),
  Proj_Number NUMBER(4),
  Emp_Num NUMBER(4),
  Date_Assigned DATE DEFAULT SYSDATE,
  Date_Ended DATE,
  Hours_Used NUMBER(4),
  CONSTRAINT assignment_assign_num_PK PRIMARY KEY (Assign_Num),
  CONSTRAINT assignment_proj_number_FK FOREIGN KEY(Proj_Number) REFERENCES project(Proj_Number),
  CONSTRAINT assignment_assign_emp_num_FK FOREIGN KEY(Emp_Num) REFERENCES employee(Emp_Num),
  CONSTRAINT assignment_date_assgined_CK CHECK (REGEXP_LIKE (Date_Assigned, '^([0-9]{2}[-][a-zA-Z]{3}[-][0-9]{2})$')),
  CONSTRAINT assignment_date_ended_CK CHECK (REGEXP_LIKE (Date_Ended, '^([0-9]{2}[-][a-zA-Z]{3}[-][0-9]{2})$')),
  CONSTRAINT assignment_check_date CHECK (Date_Ended > Date_Assigned)
);
 

ALTER TABLE department
	ADD CONSTRAINT department_manager_id_FK 
	FOREIGN KEY(Manager_ID)
	REFERENCES employee(Emp_Num);

  
  
  
