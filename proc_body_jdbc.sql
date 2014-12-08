set serveroutput on;
create or replace package body SRSJDBC as
--procedure to show all the tuples from students table
procedure show_students
(stu_cursor out sys_refcursor) is 
begin 
	open stu_cursor for select * from students order by sid;
end;	

--procedure to show all the tuples from courses table
procedure show_courses
(cou_cursor out sys_refcursor) is 
begin
	open cou_cursor for select * from courses order by dept_code,course#;
end;

--procedure to show all the tuples from prerequisites table
procedure show_prereq
(pre_cursor out sys_refcursor) is
begin
	open pre_cursor for select * from prerequisites order by dept_code,course#;
end;

--procedure to show all the tuples from classes table
procedure show_classes
(class_cursor out sys_refcursor) is 
begin
	open class_cursor for select * from classes order by classid;
end;

--procedure to show all the tuples from enrollments table
procedure show_enrollments
(enrol_cursor out sys_refcursor) is 
begin
	open enrol_cursor for select * from enrollments order by sid,classid;
end;

--procedure to show all the tuples from logs table
procedure show_logs
(log_cursor out sys_refcursor) is
begin
	open log_cursor for select * from logs order by logid;
end;

--procedure to insert a student record in students table
procedure insertstudent
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
	invalid_sid1 exception;
	emailcount number(2);
	sidcount number(2);
begin

emailcount := 0;
sidcount := 0;

select count(*) into emailcount from students where email = p_email;
select count(*) into sidcount from students where sid = p_sid;

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
elsif(sidcount > 0) then
	raise invalid_sid1;
else
	insert into students values (p_sid,p_firstname,p_lastname,p_status,p_gpa,p_email);
end if;

exception
	when invalid_gpa then
		raise_application_error(-20101, 'GPA value is must be in between 0 and 4.');
	when invalid_sid then
		raise_application_error(-20102, 'Sid value is must start with B.');
	when invalid_firstname then
		raise_application_error(-20103, 'firstname value cannot be null.');
	when invalid_lastname then
		raise_application_error(-20104, 'lastname value can not be null.');
	when invalid_status then
		raise_application_error(-20105, 'status value must be freshman,sophomore,junior,senior,graduate');
	when invalid_email then
		raise_application_error(-20106, 'email value is not unique.');
	when invalid_sid1 then
		raise_application_error(-20107, 'sid value is not unique.');
end;

--procedure to show courses for a student
procedure show_course_for_student
(p_sid in students.sid%type,
stu_cursor out sys_refcursor) is

invalid_sid exception;
no_course exception;
studentcount number;
coursecount number;

begin
	studentcount := 0;
	coursecount := 0;

	select count(*) into studentcount from students where sid = p_sid;
	select count(*) into coursecount from enrollments where sid = p_sid;
	
	if(studentcount = 0) then
		raise invalid_sid;
	elsif(coursecount = 0) then
		raise no_course;
	end if;
    open stu_cursor for select s.sid,s.firstname,c.dept_code||c.course# as course,c.title
	from students s,enrollments e,classes cls,courses c
	where s.sid = p_sid and
	s.sid = e.sid and
	e.classid = cls.classid and
	cls.dept_code = c.dept_code and
	cls.course# = c.course#
	order by c.dept_code,c.course#;
	
	exception
		when invalid_sid then
			raise_application_error(-20108, 'The sid is invalid.');
		when no_course then
			raise_application_error(-20109,'The student has not taken any course.');
end;

--procedure to get all the prerequisites of a given course
procedure get_prereq
(in_dept_code in prerequisites.dept_code%type, 
in_course# in prerequisites.course#%type,
prereq_cursor out sys_refcursor) is
begin
	open prereq_cursor for select * from prerequisites where dept_code = in_dept_code and course# = in_course#;
end;

--procedure to show the details of the classid provided
procedure class_details
(in_classid in classes.classid%type,
class_cursor out sys_refcursor) is

temp_stud_count number;

class_not_found exception;
sid_not_enrolled exception;
count_classes number;

begin
	count_classes := 0;
	temp_stud_count := 0;
	select count(*) into count_classes from classes where classid = in_classid;
	if(count_classes = 0) then 
		raise class_not_found;
	end if;
	select count(*) into temp_stud_count from enrollments where classid = in_classid;
	if(temp_stud_count = 0) then
		raise sid_not_enrolled;
	else
		open class_cursor for
		select cl.classid, cr.title, e.sid, s.firstname from classes cl, courses cr, enrollments e, students s where cl.classid = in_classid and cr.dept_code = cl.dept_code and cr.course# = cl.course# and e.classid = cl.classid and e.sid = s.sid;
	end if;

exception
	when class_not_found then
		raise_application_error(-20110,'The cid is invalid');
	when sid_not_enrolled then
		raise_application_error(-20111,'No student is enrolled in the class');
end;

--procedure to enroll a student in a class
procedure enroll_student
(in_sid in students.sid%type,
in_classid in classes.classid%type,
overloadcount out number)is

-- all execptions added here
invalid_sid exception;
invalid_classid exception;
class_full exception;
already_enrolled exception;
overloaded exception;
pre_not_taken exception;
course_already_taken exception;

--all count variables 
studentcount number;
classcount number;
enrollcount number;

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

    	temp_count := 0;
    	select count(*) into temp_count from dual where class_record.dept_code||class_record.course# in 
    		(select dept_code||course# from classes cls,enrollments e where e.sid = in_sid and e.classid = cls.classid);
    	if(temp_count = 1) then
    		raise course_already_taken;
    	end if;

	insert into enrollments values(in_sid,in_classid,null);	

exception
	when invalid_sid then
		raise_application_error(-20112,'The sid is invalid');
	when invalid_classid then
		raise_application_error(-20113,'The classid is invalid');
	when class_full then
		raise_application_error(-20114,'The class is closed.');
	when already_enrolled then
		raise_application_error(-20115,'The student is already in the class.');
	when overloaded then
		raise_application_error(-20116,'Student can not be be enrolled in more than four classes in the same semester.');
	when pre_not_taken then
		raise_application_error(-20117,'Prerequisites courses have not been completed.');
	when course_already_taken then
		raise_application_error(-20118,'The student has already taken the course of the given class.');	
end;

--procedure to drop a student from a class
procedure drop_student
(in_sid in students.sid%type,
in_classid in classes.classid%type,
stu_count_out out number,
class_count_out out number)is

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
	select count(*) into stu_count_out from enrollments where sid = in_sid;
    /*    if(stu_count_out = 0) then                
                dbms_output.put_line('This student is not enrolled in any classes.');
        end if;
	*/
	--check if no student is enrolled for this class
	select count(*) into class_count_out from enrollments where classid = in_classid;
    /*    if(class_count_out = 0) then                
                dbms_output.put_line('The class now has no students.');
        end if;
	*/
	
exception
	when invalid_sid then
                raise_application_error(-20119,'The sid is invalid.');	
        when invalid_classid then
                raise_application_error(-20120,'The classid is invalid.');	
        when not_enrolled then
				raise_application_error(-20121,'The Student is not enrolled in the class.');
        when prereq_violation then
                raise_application_error(-20122,'The drop is not permitted because another class uses it as a prerequisite.');

end;

--procedure to delete a student from student table
procedure delete_student
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
			raise_application_error(-20119,'The sid is invalid.');
end;
end; /*package body end*/
/
show errors;
