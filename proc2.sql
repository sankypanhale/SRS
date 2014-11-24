set serveroutput on;
create or replace procedure show_students is 
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
/

create or replace procedure show_courses is 
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
/
create or replace procedure show_prereq is 
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
/
create or replace procedure show_classes is 
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
/
create or replace procedure show_enrollments is 
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
/
show errors;
>>>>>>> Stashed changes
