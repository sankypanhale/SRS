set serveroutput on;
create or replace procedure get_prereq(in_dept_code in prerequisites.dept_code%type, in_course# in prerequisites.course#%type) is
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
/
show errors;
