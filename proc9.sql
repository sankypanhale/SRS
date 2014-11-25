set serveroutput on;
create or replace procedure delete_student
(in_sid in students.sid%type)is

-- all execptions added here
invalid_sid exception;

--all count variables
studentcount number;

begin
    studentcount := 0;
    select count(*) into studentcount from students where sid = in_sid;
    if(studentcount = 0) then
        raise invalid_sid;
	end if;
	
	delete from students where sid = in_sid;

	exception
		when invalid_sid then
		 dbms_output.put_line('The sid is invalid');
end;
/
show errors;