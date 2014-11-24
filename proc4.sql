set serveroutput on;
create or replace procedure show_course_for_student
(p_sid in students.sid%type)is
cursor stu_cursor is select s.sid,s.firstname,c.dept_code,c.course#,c.title
from students s,enrollments e,classes cls,courses c
where s.sid = p_sid and
s.sid = e.sid and
e.classid = cls.classid and
cls.dept_code = c.dept_code and
cls.course# = c.course#;
s_rec stu_cursor%rowtype;
begin
        if(not stu_cursor%isopen) then
                open stu_cursor;
        end if;
        fetch stu_cursor into s_rec;
        while(stu_cursor%found) loop
                dbms_output.put_line(s_rec.sid||','||s_rec.firstname||','||s_rec.dept_code||s_rec.course#||','||s_rec.title);
                fetch stu_cursor into s_rec;
        end loop;
        close stu_cursor;
end;
/

