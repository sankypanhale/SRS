set serveroutput on;
create or replace procedure insertstudent
(p_sid in students.sid%type,
p_firstname in students.firstname%type,
p_lastname in students.lastname%type,
p_status in students.status%type,
p_gpa in students.gpa%type,
p_email in students.email%type)is

	invalid_gpa exception;
	invalid_sid exception;
	invalid_firstname exception;
	invalid_lastname exception;
	invalid_status exception;
	invalid_email exception;
	emailcount number(2);
begin
emailcount := 0;
select count(*) into emailcount from students where email = p_email;
if(p_gpa < 0 or p_gpa > 4) then
	raise invalid_gpa;
elsif(p_sid not like 'B%') then
	raise invalid_sid;
elsif(p_firstname is null) then
	raise invalid_firstname;
elsif(p_lastname is null) then
	raise invalid_lastname;
elsif(p_status not in ('freshman','sophomore','junior','senior','graduate')) then
	raise invalid_status;
elsif(emailcount > 0) then
	raise invalid_email;
else
	insert into students values (p_sid,p_firstname,p_lastname,p_status,p_gpa,p_email);
end if;

exception
	when invalid_gpa then
		dbms_output.put_line('GPA value is must be in between 0 and 4.');
	when invalid_sid then
		dbms_output.put_line('Sid value is must start with B.');
	when invalid_firstname then
		dbms_output.put_line('firstname value cannot be null.');
	when invalid_lastname then
		dbms_output.put_line('lastname value can not be null.');
	when invalid_status then
		dbms_output.put_line('status value must be freshman,sophomore,junior,senior,graduate');
	when invalid_email then
		dbms_output.put_line('email value is not unique.');
end;
/
show error



