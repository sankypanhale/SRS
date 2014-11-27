--PL/SQL package to suport the SRS application

create or replace package SRS as
--procedure to show all the tuples from students table
procedure show_students;

--procedure to show all the tuples from courses table
procedure show_courses;

--procedure to show all the tuples from prerequisites table
procedure show_prereq;

--procedure to show all the tuples from classes table
procedure show_classes;

--procedure to show all the tuples from enrollments table
procedure show_enrollments;

--procedure to show all the tuples from logs table
procedure show_logs;

--procedure to insert a student record in students table
procedure insertstudent
(p_sid in students.sid%type,
p_firstname in students.firstname%type,
p_lastname in students.lastname%type,
p_status in students.status%type,
p_gpa in students.gpa%type,
p_email in students.email%type);

--procedure to show courses for a student
procedure show_course_for_student
(p_sid in students.sid%type);

--procedure to get all the prerequisites of a given course
procedure get_prereq(in_dept_code in prerequisites.dept_code%type, in_course# in prerequisites.course#%type);

--procedure to show the details of the classid provided
procedure class_details(in_classid in classes.classid%type);

--procedure to enroll a student in a class
procedure enroll_student
(in_sid in students.sid%type,
in_classid in classes.classid%type);

--procedure to drop a student from a class
procedure drop_student
(in_sid in students.sid%type,
in_classid in classes.classid%type);

--procedure to delete a student from student table
procedure delete_student
(in_sid in students.sid%type);
end;
/
show errors;