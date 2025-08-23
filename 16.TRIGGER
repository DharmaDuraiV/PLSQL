TRIGGERS:
-------------
  🔹 TRIGGER IS ALSO SAME AS STORED PROCEDURE & ALSO IT WILL AUTOMATICALLY INVOKED WHENEVER DML OPERATION PERFORMED AGAINST TABLE OR VIEW .
  🔹 A Trigger is a stored PL/SQL block associated with a table, view, schema, or database.
  🔹 It is automatically executed (fired) when a specific DML/DDL/Database event occurs.

Types of Triggers

1. Based on Action (Event Type)

🔹 DML Triggers → Fire on INSERT, UPDATE, DELETE.
🔹 DDL Triggers → Fire on CREATE, ALTER, DROP.

2. Based on Timing

🔹 BEFORE Trigger
    → Executes before the action.
    → Fires before the row goes into the table
    → You can check / change / stop the data.

🔹 AFTER Trigger 
    → Executes after the action.
    → Fires after the row is already inside the table
    → You can only read / log it (cannot change).

3. Based on Level

🔹 Row-Level Trigger → Executes once per row affected (FOR EACH ROW).
🔹 Statement-Level Trigger → Executes once per SQL statement, no matter how many rows.


IN STATEMENTS LEVEL TRIGGER, TRIGGER BODY IS EXECUTED ONLY ONCE FOR DML STATEMENTS.
WHERE AS IN ROW LEVEL TRIGGER ,TRIGGER BODY IS EXECUTED FOR EACH ROW FOR DML STATEMENTS.


SYNTAX:

  CREATE OR REPLACE TRIGGER trigger_name
  BEFORE | AFTER [UPDATE OF column_name]
  INSERT | UPDATE | DELETE ON table_name
  [FOR EACH ROW]          
  [DECLARE]                 
   -- [variable declarations]
   -- [cursor declarations]
  BEGIN
     -- statements / logic
     -- use :OLD and :NEW for row-level triggers
     -- add IF conditions here if needed
  END;
  /

🔹 Key Notes

  BEFORE | AFTER [UPDATE OF column_name]
      →  UPDATE OF column_name is only valid for update triggers.
      →  For INSERT or DELETE, you cannot specify a column.
  [] ->  optional. Only if you need

Row Level Triggers
------------------

  🔹 in row level trigger, trigger body is executed for each row affected by a dml statement.
  🔹 that’s why we use the for each row clause in the trigger specification.
  🔹 oracle provides two special rollback statement qualifiers to access row values:
        :old → refers to the column values before dml operation.
        :new → refers to the column values after dml operation.
  🔹 when using these modifiers inside trigger body, we must use a colon (:) prefix before old or new.
  🔹 row level triggers are helpful for auditing, logging, enforcing business rules, and validating data changes.

Simple rule to use Before and After Key word:
--------------------------------------------
  🔹 use before 
        → when you want to validation, defaulting, restrictions, change, or stop the DML.
  🔹 use after 
        → when you want to logging, auditing, maintaining history the action (cannot stop).

Example:

  create or replace trigger emp_audit_trg
  before update or delete or insert
  on emp
  for each row
  begin
     -- access old and new values
     dbms_output.put_line('old salary: ' || :old.sal);
     dbms_output.put_line('new salary: ' || :new.sal);
  end;
  /
before insert trigger
---------------------

Example
--------

🔹 write a trigger that prevents inserting an employee with salary less than 1000.

  create or replace trigger emp_bi
  before insert on emp
  for each row
  begin
     if :new.sal < 1000 then
        raise_application_error(-20001, 'salary must be >= 1000');
     end if;
  end;
  /

✅ Test Case
----------

  insert into emp values (201, 'john', 500);  -- ❌ not allowed
  insert into emp values (202, 'miller', 1500);  -- ✅ allowed

---------------------------------------------------------------------------------------------

👉 write a trigger that does not allow an employee’s salary to be reduced.

  create or replace trigger emp_bu
  before update on emp
  for each row
  begin
     if :new.sal < :old.sal then
        raise_application_error(-20002, 'salary cannot be decreased');
     end if;
  end;
  /

✅ Test Case
----------

  update emp set sal = 1000 where empno = 202;  -- ❌ not allowed
  update emp set sal = 2500 where empno = 202;  -- ✅ allowed

---------------------------------------------------------------------------------------------

👉 write a trigger that prevents deletion of employees with the name 'miller'.

  create or replace trigger emp_bd
  before delete on emp
  for each row
  begin
     if :old.ename = 'MILLER' then
        raise_application_error(-20003, 'cannot delete miller');
     end if;
  end;
  /

✅ Test Case
----------

  delete from emp where ename = 'MILLER';  -- ❌ not allowed
  delete from emp where ename = 'ALLEN';    -- ✅ allowed

---------------------------------------------------------------------------------------------

🔹 After insert trigger
------------------------

👉 write a trigger that stores an audit log whenever a new employee is inserted.


-- audit table
  create table emp_audit (
     empno number,
     action varchar2(20),
     action_date date
  );

  create or replace trigger emp_ai
  after insert on emp
  for each row
  begin
     insert into emp_audit values(:new.empno, 'INSERT', sysdate);
  end;
  /

✅ Test Case
---------
  
  insert into emp values(301, 'scott', 'analyst', 2000);

  select * from emp_audit;

 o/p :
    301 | INSERT | 24-AUG-25
---------------------------------------------------------------------------------------------
👉 write a trigger that keeps history whenever employee salary is updated.

  create table emp_salary_history (
     empno number,
     old_sal number,
     new_sal number,
     changed_on date
  );

  create or replace trigger emp_au
  after update of sal on emp
  for each row
  begin
     insert into emp_salary_history
     values(:old.empno, :old.sal, :new.sal, sysdate);
  end;
  /

✅ Test Case
---------

  update emp set sal = 4000 where empno = 301;

  select * from emp_salary_history;

---------------------------------------------------------------------------------------------
👉 write a trigger that logs deleted employees into a backup table.

  create table emp_deleted_backup (
     empno number,
     ename varchar2(20),
     deleted_on date
  );

  create or replace trigger emp_ad
  after delete on emp
  for each row
  begin
     insert into emp_deleted_backup
     values(:old.empno, :old.ename, sysdate);
  end;
  /

✅ Test Case
---------

  delete from emp where empno = 301;
  select * from emp_deleted_backup;

---------------------------------------------------------------------------------------------
👉  write a trigger that performs multiple actions before inserting a new employee:
    convert ENAME to uppercase
    calculate 10% bonus of SAL and assign it to COMM
    print the employee name and bonus using dbms_output.put_line

  CREATE OR REPLACE TRIGGER trg_emp_before_insert
  BEFORE INSERT ON emp
  FOR EACH ROW
  DECLARE
     v_bonus NUMBER(7,2);
  BEGIN
     :NEW.ENAME := UPPER(:NEW.ENAME);
     v_bonus := :NEW.SAL * 0.10;
     :NEW.COMM := v_bonus;
     dbms_output.put_line('Employee: ' || :NEW.ENAME || ', Bonus: ' || v_bonus);
  END;
  /

---------------------------------------------------------------------------------------------
👉 whenever an employee’s salary (SAL) is updated, calculate a 10% bonus and store it in COMM. Also, display a message showing old and new salary.

  CREATE OR REPLACE TRIGGER trg_emp_before_update
  BEFORE UPDATE OF SAL ON emp
  FOR EACH ROW
  DECLARE
     v_bonus NUMBER(7,2);
  BEGIN
     v_bonus := :NEW.SAL * 0.10;
     :NEW.COMM := v_bonus;
     dbms_output.put_line('Employee: ' || :NEW.ENAME || 
                        ', Old Salary: ' || :OLD.SAL || 
                        ', New Salary: ' || :NEW.SAL || 
                        ', Bonus: ' || v_bonus);
  END;
  /

✅ Test Case

  UPDATE emp SET sal = 3000 WHERE empno = 801;

dbms_output:

  Employee: RAJESH, Old Salary: 2500, New Salary: 3000, Bonus: 300

---------------------------------------------------------------------------------------------
👉 whenever an employee’s salary (SAL) is updated, check the employee’s department (DEPTNO) using a cursor, and if the employee is in DEPTNO = 10, calculate 15% bonus; otherwise, calculate 10% bonus.

  CREATE OR REPLACE TRIGGER trg_emp_before_update_cursor
  BEFORE UPDATE OF SAL ON emp
  FOR EACH ROW
  DECLARE
     v_bonus NUMBER(7,2);
     CURSOR c_dept IS
        SELECT deptno FROM emp WHERE empno = :NEW.empno;
     v_dept c_dept%ROWTYPE;
  BEGIN
     OPEN c_dept;
     FETCH c_dept INTO v_dept;
     CLOSE c_dept;
       IF v_dept.deptno = 10 THEN
          v_bonus := :NEW.SAL * 0.15;
       ELSE
          v_bonus := :NEW.SAL * 0.10;
       END IF;
     :NEW.COMM := v_bonus;

       dbms_output.put_line('Employee: ' || :NEW.ENAME || 
                        ', Dept: ' || v_dept.deptno || 
                        ', New Salary: ' || :NEW.SAL || 
                        ', Bonus: ' || v_bonus);
  END;
  /

✅ Test Case

  UPDATE emp SET sal = 4000 WHERE empno = 801;

dbms_output:

  Employee: RAJESH, Dept: 10, New Salary: 4000, Bonus: 600



---------------------------------------------------------------------------------------------
🔹 Can you use COMMIT directly inside a normal row-level trigger?

    -> ❌ No. You should not use COMMIT in normal triggers because triggers run as part of the main DML transaction. 
    -> Committing inside a trigger can break transaction integrity .
    -> Oracle will raise an error for row-level triggers.

🔹 How can you safely log data from a trigger that requires a commit?

    -> ✅ Use an autonomous transaction. It allows the trigger to commit independently of the main transaction.
---------------------------------------------------------------------------------------------

--> WRITE A PL/SQL ROW LEVEL TRIGGER ON EMPLOYEE TABLE WHENEVER USER INSERTING THE DATA INTO A EMP TABLE SAL SHOULD BE ABOVE MORE THAN 5000.

CREATE OR REPLACE TRIGGER T1
BEFORE INSERT ON EMP
FOR EACH ROW
BEGIN
IF :NEW.SAL <=5000 THEN
RAISE_APPLICATION_ERROR(-20101,'SALARY MUST BE MORE THAN 5000');
END IF ;
END ;
/


SQL> BEGIN
2  INSERT INTO EMP(EMPNO,ENAME ,SAL) VALUES (1111,'JOHN',3000);
3  END ;
4  /

O/P :

BEGIN
*
ERROR AT LINE 1:
ORA-20101: SALARY MUST BE MORE THAN 5000
ORA-06512: AT "SCOTT.T1", LINE 3
ORA-04088: ERROR DURING EXECUTION OF TRIGGER 'SCOTT.T1'
ORA-06512: AT LINE 2



--> WRITE A PL/SQL ROW LEVEL TRIGGER ON DEPT TABLE WHENEVER USER UPDATE THE DATA INTO A DEPT TABLE IT SHOULD MODIFY ON EMP TABLE

CREATE OR REPLACE TRIGGER T2
AFTER UPDATE ON DEPT
FOR EACH ROW
BEGIN
UPDATE EMP
SET DEPTNO = :NEW.DEPTNO
WHERE DEPTNO =:OLD.DEPTNO;
END ;
/

BEGIN
UPDATE DEPT
SET DEPTNO =30
WHERE DEPTNO=60;
END ;
/

--> WRITE A PL/SQL  TRIGGER USING EMP,DEPT TABLE IMPLEMENT ON DELETE WITH OUT USING CASCADE ON DELETE .

CREATE OR REPLACE TRIGGER T4
AFTER DELETE ON DEPT
FOR EACH ROW
BEGIN
DELETE FROM EMP
WHERE DEPTNO= :OLD.DEPTNO;
END ;
/


EXAMPLE:1

CREATE SEQUENCE S2
START WITH 1
INCREMENT BY 1;

CREATE TABLE Q2
(
CID NUMBER,
CNAME VARCHAR(20)
);

CREATE OR REPLACE TRIGGER AUTO1
BEFORE INSERT ON Q2
FOR EACH ROW
BEGIN
SELECT S2.NEXTVAL INTO :NEW.CID FROM DUAL;
END ;
/


EXAMPLE:2

CREATE TABLE EMP_TRANS
(
EMPNO NUMBER ,
NAME VARCHAR(20),
OLD_SAL NUMBER,
NEW_SAL NUMBER
);

CREATE OR REPLACE TRIGGER E_TRANS
AFTER UPDATE ON EMP
FOR EACH ROW
DECLARE
PRAGMA AUTONOMOUS_TRANSACTION ;
BEGIN
INSERT INTO EMP_TRANS(EMPNO,NAME,OLD_SAL,NEW_SAL)
VALUES (:OLD.EMPNO,:OLD.ENAME,:OLD.SAL,:NEW.SAL);
COMMIT ;
END ;
/
