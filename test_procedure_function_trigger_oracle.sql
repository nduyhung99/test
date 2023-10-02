CREATE OR REPLACE PROCEDURE today_is AS 
BEGIN 
	dbms_output.put_line('Today is ' || TO_CHAR(SYSDATE,'DL'));
END today_is;

BEGIN
	today_is();
END;

CREATE TABLE employees (
employee_id NUMBER,
commission_pct NUMBER,
salary NUMBER
);
INSERT INTO employees VALUES (1,12,24);
INSERT INTO employees VALUES (2,13,26);
INSERT INTO employees VALUES (3,14,28);
INSERT INTO employees VALUES (4,15,30);
INSERT INTO employees VALUES (5,null,32);
INSERT INTO employees VALUES (6,null,34);
SELECT * FROM employees;

CREATE OR REPLACE PROCEDURE award_bonus (emp_id IN NUMBER, bonus_rate IN NUMBER)
  AS
  emp_comm        employees.commission_pct%TYPE;
   emp_sal         employees.salary%TYPE;
   salary_missing EXCEPTION;
   BEGIN
	   	SELECT salary, commission_pct INTO emp_sal, emp_comm FROM employees
	    WHERE employee_id = emp_id;
	    IF emp_sal IS NULL THEN
	      RAISE salary_missing;
	    ELSE 
	      IF emp_comm IS NULL THEN
	    DBMS_OUTPUT.PUT_LINE('Employee ' || emp_id || ' receives a bonus: ' 
	                            || TO_CHAR(emp_sal * bonus_rate) );
	     ELSE
	       DBMS_OUTPUT.PUT_LINE('Employee ' || emp_id 
	                            || ' receives a commission. No bonus allowed.');
	     END IF;
	    END IF;
	   EXCEPTION  
	   	WHEN salary_missing THEN
	      DBMS_OUTPUT.PUT_LINE('Employee ' || emp_id || 
	                           ' does not have a value for salary. No update.');
	   	WHEN OTHERS THEN
	      NULL;
   END award_bonus;
  
  BEGIN
  	award_bonus(1,2);
  	award_bonus(6,2);
  END;

	   
CREATE OR REPLACE PROCEDURE delete_employee(
	EMP_ID EMPLOYEES.EMPLOYEE_ID%TYPE
)
AS not_found_emp_exception EXCEPTION ;
emp_count NUMBER;
BEGIN 
	SELECT count(1) INTO emp_count FROM EMPLOYEES e2 WHERE e2.EMPLOYEE_ID = EMP_ID;
	IF emp_count > 0 then
		DELETE FROM EMPLOYEES epm WHERE epm.EMPLOYEE_ID = EMP_ID;
		dbms_output.put_line('Delete employee success!');
		COMMIT;
	ELSE
		RAISE not_found_emp_exception;
	END IF;
	EXCEPTION
	 WHEN not_found_emp_exception THEN
	 	dbms_output.put_line('Employee not found!');
     WHEN NO_DATA_FOUND THEN
       dbms_output.put_line('No data found!');
     WHEN OTHERS THEN
       dbms_output.put_line('Have exception');
END delete_employee;

BEGIN 
	delete_employee(1);
END;

DECLARE
  emp_id NUMBER := 1; -- Thay 1 bằng ID của nhân viên cần xóa
  v_success NUMBER;
BEGIN
  -- Gọi procedure và truyền biến OUT
  delete_employee(emp_id, v_success);
  IF v_success = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Employee deleted successfully.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Employee not found.');
  END IF;
END;

SELECT * FROM EMPLOYEES e ;

CREATE OR REPLACE TYPE employee_type AS OBJECT (
    employee_id NUMBER,
	commission_pct NUMBER,
	salary NUMBER
);

CREATE OR REPLACE TYPE employee_list_type AS TABLE OF employee_type;

CREATE OR REPLACE FUNCTION get_employees RETURN employee_list_type AS
    employee_data employee_list_type;
BEGIN
    SELECT employee_type(employee_id, commission_pct, salary)
    BULK COLLECT INTO employee_data
    FROM EMPLOYEES;
    
    RETURN employee_data;
END;

/*
CREATE OR REPLACE TRIGGER EmployeeBeforeInsertTrigger
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
  :NEW."FirstName" := 'test_first_name';
END;
*/

SELECT * FROM get_employees();