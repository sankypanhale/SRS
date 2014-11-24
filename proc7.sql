set serveroutput on;
create or replace procedure enroll_student
(in_sid in students.sid%type,
in_classid in classes.classid%type)is

-- all execptions added here
invalid_sid exception;
invalid_classid exception;
class_full exception;
already_enrolled exception;
overloaded exception;
pre_not_taken exception;

--all count variables 
studentcount number;
classcount number;
enrollcount number;
overloadcount number;

--record type to hold row from classes table
class_record classes%rowtype;

--cursor to save all the prerequisite of the course(whose classid is = in_classid)
cursor temp_pre is select * from prerequisites where dept_code = class_record.dept_code and course# = class_record.course#;
temp_pre_record temp_pre%rowtype;
temp_count number;

begin
	studentcount := 0;
	classcount := 0;

	select count(*) into studentcount from students where sid = in_sid;
	if(studentcount = 0) then
		raise invalid_sid;
	end if;	
	select count(*) into classcount from classes where classid = in_classid;
	if(classcount = 0) then
		raise invalid_classid;
	end if;
	
	select * into class_record from classes where classid = in_classid;
	if(class_record.class_size = class_record.limit) then
		raise class_full;
	end if;
	
	select count(*) into enrollcount from enrollments where classid = in_classid and sid = in_sid;
	if(enrollcount = 1) then
		raise already_enrolled;
	end if;	

	select count(*) into overloadcount from enrollments where sid = in_sid and classid in 
	(select classid from classes where semester = class_record.semester and year = class_record.year);
	if(overloadcount = 3) then
		dbms_output.put_line('You are overloaded.');
	elsif(overloadcount = 4) then
		raise overloaded;
	end if;
	
	temp_count := 0;
	for temp_pre_record in temp_pre loop
		select count(*) into temp_count from dual where
		temp_pre_record.pre_dept_code||temp_pre_record.pre_course#  in 
		(select dept_code||course# from classes cls,enrollments e where e.sid = in_sid and e.classid = cls.classid);

		-- temp_count == 0 means the student has not taken course currently stored in temp_pre_record
		if(temp_count = 0) then
			raise pre_not_taken;
		else
			temp_count := 0;
		end if;
        end loop;
	insert into enrollments values(in_sid,in_classid,null);	

exception
	when invalid_sid then
		dbms_output.put_line('The sid is invalid');
	when invalid_classid then
		dbms_output.put_line('The classid is invalid');
	when class_full then
		dbms_output.put_line('The class is closed.');
	when already_enrolled then
		dbms_output.put_line('The student is already in the class.');
	when overloaded then
		dbms_output.put_line('Student can not be be enrolled in more than four classes in the same semester.');
	when pre_not_taken then
		dbms_output.put_line('Prerequisites courses have not been completed.');
end;
/
show errors;
