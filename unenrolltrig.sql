drop trigger stud_unenroll_trigger;

-- trigger for students table
create or replace trigger stud_unenroll_trigger
after delete
on students
for each row
begin
	 
    delete from enrollments where sid = :old.sid;
end;
/
show errors
