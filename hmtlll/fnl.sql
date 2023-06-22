
CREATE OR REPLACE PACKAGE employee_package IS
PROCEDURE update_emp_record(e_code employee.emp_code%type);
FUNCTION delete_emp_record(e_code employee.emp_code%type) RETURN boolean;
END employee_package;
/

CREATE OR REPLACE PACKAGE BODY employee_package AS
PROCEDURE update_emp_record(e_code employee.emp_code%type) IS
avg_sal employee.emp_salary%type := 0;
min_sal employee.emp_salary%type := 0;
sal_update_c employee.sal_update_counter%type;
e_sal employee.emp_salary%type;
BEGIN
SELECT ROUND(AVG(emp_salary), 2), MIN(emp_salary) INTO avg_sal, min_sal FROM employee;
SELECT emp_salary, sal_update_counter INTO e_sal, sal_update_c FROM employee WHERE emp_code = e_code;

dbms_output.put_line('---------------------------------------');
dbms_output.put_line('Initial salary before update: '|| e_sal);
dbms_output.put_line('Minimum salary of all emps: '|| min_sal);
dbms_output.put_line('Average salary of all emps: '|| avg_sal);
dbms_output.put_line('---------------------------------------');

IF e_sal BETWEEN min_sal AND avg_sal THEN
IF sal_update_c = 1 THEN
UPDATE employee SET sal_update_counter = sal_update_counter + 1 WHERE emp_code = e_code;
UPDATE employee SET emp_salary = emp_salary + 50 WHERE emp_code = e_code;
IF sql%rowcount > 0 THEN
dbms_output.put_line('Employee updated successfully and sal_update_counter is incremented by 1');
END IF;
ELSE
dbms_output.put_line('Cant update. The <salary update counter> is not equal to one');
END IF;
ELSE
dbms_output.put_line('Cant update the employee. The salary is not between average and minimun');
END IF;

EXCEPTION
WHEN no_data_found THEN
dbms_output.put_line('No data found');
WHEN too_many_rows THEN
dbms_output.put_line('Too many rows');
END;

FUNCTION delete_emp_record(e_code employee.emp_code%type) RETURN boolean IS
sal_update_c employee.emp_salary%type;
BEGIN
SELECT sal_update_counter INTO sal_update_c FROM employee WHERE emp_code = e_code;

IF sal_update_c = 2 THEN
DELETE FROM employee WHERE emp_code = e_code;
IF sql%rowcount > 0 THEN
dbms_output.put_line('Employee with emp_code: ' || e_code || ' successfully deleted');
RETURN TRUE;
END IF;
ELSE
dbms_output.put_line('Cant delete. The <salary update counter> is not equal to two');
RETURN FALSE;
END IF;

EXCEPTION
WHEN no_data_found THEN
dbms_output.put_line('No data found');
WHEN too_many_rows THEN
dbms_output.put_line('Too many rows');
END;
END employee_package;
/

CREATE OR REPLACE TRIGGER update_prevention
BEFORE UPDATE ON employee
DECLARE
not_time_to_update EXCEPTION;
PRAGMA EXCEPTION_INIT(not_time_to_update, -20002);
BEGIN
IF (TO_CHAR(SYSDATE, 'HH24:MI') BETWEEN '17:00' AND '07:00') THEN
RAISE_APPLICATION_ERROR(-20002, 'Sorry! You can not update between 5pm and 7am');
END IF;
END;
/

-- Reference to package elements
DECLARE
deleted_emp Boolean;
BEGIN
employee_package.update_emp_record(3);
deleted_emp := employee_package.delete_emp_record(2);
END;
/

