drop trigger stud_enroll_trigger;


-- trigger for students table
create or replace trigger stud_enroll_trigger
after insert
on enrollments
for each row
declare
        newsize number;
begin
	select class_size into newsize from classes where classid = :new.classid;
	newsize := newsize + 1;
	update classes set class_size = newsize where classid = :new.classid; 
end;
/
show errors

