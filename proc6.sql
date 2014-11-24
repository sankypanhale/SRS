set serveroutput on;
create or replace procedure class_details(in_classid in classes.classid%type) is
cursor enroll_cursor is select * from enrollments where classid = in_classid;
en_rec enroll_cursor%rowtype;
temp_classid classes.classid%type;
temp_dept_code classes.dept_code%type;
temp_course# classes.course#%type;
temp_title courses.title%type;
temp_name students.firstname%type;

class_not_found exception;
sid_not_enrolled exception;
count_classes number;

begin
	count_classes := 0;
	select count(*) into count_classes from classes where classid = in_classid;
	if(count_classes = 0) then 
		raise class_not_found;
	else
		select classid,dept_code,course# into temp_classid,temp_dept_code,temp_course# from classes where classid = in_classid;
	end if;
	select title into temp_title from courses where dept_code = temp_dept_code and course# = temp_course#;
	if(not enroll_cursor%isopen) then
		open enroll_cursor;
	end if;
	fetch enroll_cursor into en_rec;
	if(enroll_cursor%notfound) then
		raise sid_not_enrolled;
	else
		while(enroll_cursor%found) loop	
			select firstname into temp_name from students where sid = en_rec.sid;
			dbms_output.put_line(temp_classid||','||temp_title||','||en_rec.sid||','||temp_name);
			fetch enroll_cursor into en_rec;
		end loop;
	end if;

exception
	when class_not_found then
		dbms_output.put_line('The cid is invalid');
	when sid_not_enrolled then
		dbms_output.put_line('No student is enrolled in the class');
end;
/
show errors;
