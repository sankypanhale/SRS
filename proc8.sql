set serveroutput on;
create or replace procedure drop_student
(in_sid in students.sid%type,
in_classid in classes.classid%type)is

--all exception are added here
invalid_sid exception;
invalid_classid exception;
not_enrolled exception;
prereq_violation exception;

--all count variables
studentcount number;
classcount number;
enrollcount number;

--record type to hold row from classes table
class_record classes%rowtype;

--cursor to save courses of which this course is the prerequisite.
cursor temp_pre is select * from prerequisites where pre_dept_code = class_record.dept_code and pre_course# = class_record.course#;
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

	select count(*) into enrollcount from enrollments where classid = in_classid and sid = in_sid;
        if(enrollcount = 0) then
                raise not_enrolled;
        end if;
	
	select * into class_record from classes where classid = in_classid;
	
	temp_count := 0;
	for temp_pre_record in temp_pre loop
		select count(*) into temp_count from dual where 
		temp_pre_record.dept_code||temp_pre_record.course# in
		(select dept_code||course# from classes cls,enrollments e where e.sid = in_sid and e.classid = cls.classid);

		if(temp_count = 1) then
			raise prereq_violation;
		end if;
		temp_count := 0;
	end loop;

	delete from enrollments where sid = in_sid and classid = in_classid;
	
	--check if this is the last class of the student
	select count(*) into enrollcount from enrollments where sid = in_sid;
        if(enrollcount = 0) then                
                dbms_output.put_line('This student is not enrolled in any classes');
        end if;
	
	--check if no student is enrolled for this class
	select count(*) into enrollcount from enrollments where classid = in_classid;
        if(enrollcount = 0) then                
                dbms_output.put_line('The class now has no students.');
        end if;
	
	
exception
	when invalid_sid then
                dbms_output.put_line('The sid is invalid');
        when invalid_classid then
                dbms_output.put_line('The classid is invalid');
        when not_enrolled then
                dbms_output.put_line('The Student is not enrolled in the class');
        when prereq_violation then
                dbms_output.put_line('The drop is not permitted because another class uses it as a prerequisite.');

end;
/
show errors;
