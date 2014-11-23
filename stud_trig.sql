create or replace trigger student_insert_trigger
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
show errors