drop trigger student_trigger;
drop trigger courses_trigger;
drop trigger prerequisites_trigger;
drop trigger classes_trigger;
drop trigger enrollments_trigger;


-- trigger for students table
create or replace trigger student_trigger
after insert or update or delete
on students
for each row
declare 
	log_action  logs.operation%type;
	myuser logs.who%type;
	mytime date;
	mysid logs.key_value%type;
begin
 if INSERTING then
    log_action := 'Insert';
	mysid := :new.sid;
  elsif UPDATING then
    log_action := 'Update';
	mysid := :old.sid;
  elsif DELETING then
    log_action := 'Delete';
	mysid := :old.sid;
  else
    DBMS_OUTPUT.PUT_LINE('This code is not reachable.');
  end if;
select user into myuser from dual;
select sysdate into mytime from dual;
dbms_output.put_line('User is: ' || myuser);
insert into logs values(log_id.nextval,myuser,mytime,'students',log_action,mysid);
end;
/

-- #############################################################

-- # trigger for courses table
create or replace trigger courses_trigger
after insert or update or delete
on courses
for each row
declare 
	log_action  logs.operation%type;
	myuser logs.who%type;
	mytime date;
	mykey logs.key_value%type;
begin
 if INSERTING then
    log_action := 'Insert';
	mykey := :new.dept_code || :new.course#;
  elsif UPDATING then
    log_action := 'Update';
	mykey := :old.dept_code || :old.course#;
  elsif DELETING then
    log_action := 'Delete';
	mykey := :old.dept_code || :old.course#;
  else
    DBMS_OUTPUT.PUT_LINE('This code is not reachable.');
  end if;
select user into myuser from dual;
select sysdate into mytime from dual;
insert into logs values(log_id.nextval,myuser,mytime,'courses',log_action,mykey);
end;
/

-- #############################################################


-- # trigger for prerequisites table
create or replace trigger prerequisites_trigger
after insert or update or delete
on prerequisites
for each row
declare 
	log_action  logs.operation%type;
	myuser logs.who%type;
	mytime date;
	mykey logs.key_value%type;
begin
 if INSERTING then
    log_action := 'Insert';
	mykey := :new.dept_code || :new.course# || :new.pre_dept_code || :new.pre_course#;
  elsif UPDATING then
    log_action := 'Update';
	mykey := :old.dept_code || :old.course# || :old.pre_dept_code || :old.pre_course#;
  elsif DELETING then
    log_action := 'Delete';
	mykey := :old.dept_code || :old.course# || :old.pre_dept_code || :old.pre_course#;
  else
    DBMS_OUTPUT.PUT_LINE('This code is not reachable.');
  end if;
select user into myuser from dual;
select sysdate into mytime from dual;
insert into logs values(log_id.nextval,myuser,mytime,'prerequisites',log_action,mykey);
end;
/


-- #############################################################


-- # trigger for classes table
create or replace trigger classes_trigger
after insert or update or delete
on classes
for each row
declare 
	log_action  logs.operation%type;
	myuser logs.who%type;
	mytime date;
	mykey logs.key_value%type;
begin
 if INSERTING then
    log_action := 'Insert';
	mykey := :new.classid;
  elsif UPDATING then
    log_action := 'Update';
	mykey := :old.classid;
  elsif DELETING then
    log_action := 'Delete';
	mykey := :old.classid;
  else
    DBMS_OUTPUT.PUT_LINE('This code is not reachable.');
  end if;
select user into myuser from dual;
select sysdate into mytime from dual;
insert into logs values(log_id.nextval,myuser,mytime,'classes',log_action,mykey);
end;
/


-- #############################################################


-- # trigger for enrollments table
create or replace trigger enrollments_trigger
after insert or update or delete
on enrollments
for each row
declare 
	log_action  logs.operation%type;
	myuser logs.who%type;
	mytime date;
	mykey logs.key_value%type;
begin
 if INSERTING then
    log_action := 'Insert';
	mykey := :new.sid || :new.classid;
  elsif UPDATING then
    log_action := 'Update';
	mykey := :old.sid || :old.classid;
  elsif DELETING then
    log_action := 'Delete';
	mykey := :old.sid || :old.classid;
  else
    DBMS_OUTPUT.PUT_LINE('This code is not reachable.');
  end if;
select user into myuser from dual;
select sysdate into mytime from dual;
insert into logs values(log_id.nextval,myuser,mytime,'enrollments',log_action,mykey);
end;
/

show errors
