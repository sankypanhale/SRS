set serveroutput on;
create or replace package body SRS as
--procedure to show all the tuples from students table
procedure show_students is 
cursor stu_cursor is select * from students;
s_rec stu_cursor%rowtype;
begin
	if(not stu_cursor%isopen) then
		open stu_cursor;
	end if;
	fetch stu_cursor into s_rec;
	while(stu_cursor%found) loop
		dbms_output.put_line(s_rec.sid||','||s_rec.firstname||','||s_rec.lastname||','||s_rec.status||','||s_rec.gpa||','||s_rec.email);
		fetch stu_cursor into s_rec;
	end loop;
	close stu_cursor;
end;

--procedure to show all the tuples from courses table
procedure show_courses is 
cursor cou_cursor is select * from courses;
c_rec cou_cursor%rowtype;
begin
	if(not cou_cursor%isopen) then
		open cou_cursor;
	end if;
	fetch cou_cursor into c_rec;
	while(cou_cursor%found) loop
		dbms_output.put_line(c_rec.dept_code||','||c_rec.course#||','||c_rec.title);
		fetch cou_cursor into c_rec;
	end loop;
	close cou_cursor;
end;

--procedure to show all the tuples from prerequisites table
procedure show_prereq is 
cursor pre_cursor is select * from prerequisites;
p_rec pre_cursor%rowtype;
begin
	if(not pre_cursor%isopen) then
		open pre_cursor;
	end if;
	fetch pre_cursor into p_rec;
	while(pre_cursor%found) loop
		dbms_output.put_line(p_rec.dept_code||','||p_rec.course#||','||p_rec.pre_dept_code||','||p_rec.pre_course#);
		fetch pre_cursor into p_rec;
	end loop;
	close pre_cursor;
end;

--procedure to show all the tuples from classes table
procedure show_classes is 
cursor cla_cursor is select * from classes;
c_rec cla_cursor%rowtype;
begin
	if(not cla_cursor%isopen) then
		open cla_cursor;
	end if;
	fetch cla_cursor into c_rec;
	while(cla_cursor%found) loop
		dbms_output.put_line(c_rec.classid||','||c_rec.dept_code||','||c_rec.course#||','||c_rec.sect#||','||c_rec.year||','||c_rec.semester||','||c_rec.limit||','||c_rec.class_size);
		fetch cla_cursor into c_rec;
	end loop;
	close cla_cursor;
end;

--procedure to show all the tuples from enrollments table
procedure show_enrollments is 
cursor enrol_cursor is select * from enrollments;
e_rec enrol_cursor%rowtype;
begin
	if(not enrol_cursor%isopen) then
		open enrol_cursor;
	end if;
	fetch enrol_cursor into e_rec;
	while(enrol_cursor%found) loop
		dbms_output.put_line(e_rec.sid||','||e_rec.classid||','||e_rec.lgrade);
		fetch enrol_cursor into e_rec;
	end loop;
	close enrol_cursor;
end;

--procedure to show all the tuples from logs table
procedure show_logs is 
cursor log_cursor is select * from logs;
log_rec log_cursor%rowtype;
begin
	if(not log_cursor%isopen) then
		open log_cursor;
	end if;
	fetch log_cursor into log_rec;
	while(log_cursor%found) loop
		dbms_output.put_line(log_rec.logid||','||log_rec.who||','||log_rec.time||','||log_rec.table_name||','||log_rec.operation||','||log_rec.key_value);
		fetch log_cursor into log_rec;
	end loop;
	close log_cursor;
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
	when invalid_sid1 then
		dbms_output.put_line('sid value is not unique.');
end;

--procedure to show courses for a student
procedure show_course_for_student
(p_sid in students.sid%type)is
cursor stu_cursor is select s.sid,s.firstname,c.dept_code,c.course#,c.title
from students s,enrollments e,classes cls,courses c
where s.sid = p_sid and
s.sid = e.sid and
e.classid = cls.classid and
cls.dept_code = c.dept_code and
cls.course# = c.course#;
s_rec stu_cursor%rowtype;

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
        if(not stu_cursor%isopen) then
                open stu_cursor;
        end if;
        fetch stu_cursor into s_rec;
        while(stu_cursor%found) loop
                dbms_output.put_line(s_rec.sid||','||s_rec.firstname||','||s_rec.dept_code||s_rec.course#||','||s_rec.title);
                fetch stu_cursor into s_rec;
        end loop;
        close stu_cursor;

	exception
		when invalid_sid then
			 dbms_output.put_line('The sid is invalid.');
		when no_course then
			dbms_output.put_line('The student has not taken any course.');
end;

--procedure to get all the prerequisites of a given course
procedure get_prereq(in_dept_code in prerequisites.dept_code%type, in_course# in prerequisites.course#%type) is
p_dept_code prerequisites.dept_code%type;
p_course# prerequisites.course#%type;
cursor prereq_cursor is select * from prerequisites where dept_code = in_dept_code and course# = in_course#;
pre_rec prereq_cursor%rowtype;
begin
	for pre_rec in prereq_cursor loop
		dbms_output.put_line(pre_rec.pre_dept_code||pre_rec.pre_course#);
		get_prereq(pre_rec.pre_dept_code, pre_rec.pre_course#);
	end loop;
end;

--procedure to show the details of the classid provided
procedure class_details(in_classid in classes.classid%type) is
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

--procedure to enroll a student in a class
procedure enroll_student
(in_sid in students.sid%type,
in_classid in classes.classid%type)is

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

    	temp_count := 0;
    	select count(*) into temp_count from dual where class_record.dept_code||class_record.course# in 
    		(select dept_code||course# from classes cls,enrollments e where e.sid = in_sid);
    	if(temp_count = 1) then
    		raise course_already_taken;
    	end if;

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
	when course_already_taken then
		dbms_output.put_line('The student has already taken the course of the given class.');	
end;

--procedure to drop a student from a class
procedure drop_student
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
		 dbms_output.put_line('The sid is invalid');
end;
end; /*package body end*/
/
show errors;
