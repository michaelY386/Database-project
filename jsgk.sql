create database Project_js character set gbk;
use Project_js;

#We set 1.yuwen 2.maths 3.english 4.physics 5.chemistry 6.history 7.geography
#8.politics 9.biology 10.computer science
create table course_info
(
	cname varchar(20) not null,
    cno smallint unique primary key
);

#We need to insert it first, but not necessary
create table course_combine
(
    c_choice char(2) not null primary key,
    elect1 smallint not null,
    elect2 smallint not null,
    other1 smallint not null,
    other2 smallint not null,
    other3 smallint not null,
    other4 smallint not null 
); 

create table senior_school
(
	school_no char(6) unique not null primary key,
    school_name varchar(30) not null,
    tel_no varchar(11) unique not null
);
 

create table student
(
    sname varchar(30) not null,          
    gender char(1) not null,
    birthdate date not null,
    idno char(18) not null,
    ethnic varchar(10) not null,
    senior_school_no char(6),
    stu_type varchar(10) not null,
    stu_academic varchar(7) not null comment 'Art/Science',   
    course_choice char(2) not null, 
    phone_no varchar(11) not null,
    deliver_address varchar(100) not null,      
    post_no char(6) not null,
    post_receiver varchar(30) not null,           
    sno char(12) not null primary key,                        
    KSH char(14) not null,
    ZKH char(13) not null,
    character_score smallint,  
    plunge_score smallint,
	elect1_grade varchar(2), 
    elect2_grade varchar(2), 
    rank_in_province int,  
    foreign key(senior_school_no) references senior_school(school_no),
    foreign key(course_choice) references course_combine(c_choice)
); 
    
create table stu_grade
(
	 sno char(12) not null,
     score_yw smallint not null,
	 score_sx smallint not null,
	 score_eng smallint not null,
     addition smallint not null,
     elect1_score smallint,
     elect1_grade varchar(2),
     elect2_score smallint,
     elect2_grade varchar(2),
     other1_score smallint not null,
     other1_grade char(1),
     other2_score smallint not null,
     other2_grade char(1),
     other3_score smallint not null,
     other3_grade char(1),
     other4_score smallint not null,
     other4_grade char(1),
     cs_score smallint not null, 
     cs_grade char(6),
     req_score smallint,
     foreign key(sno) references student(sno)
);   #there must be a key?
     #primary key & not null?  unique?
     
     
     
     
     
#view of qualified art student
create view Pass_Student_for_Art as 
(
	select student.sno, KSH, ZKH, sname, character_score, plunge_score, student.elect1_grade, student.elect2_grade
    from student, stu_grade
    where stu_academic = '文科' 
		and stu_grade.sno = student.sno 
        and 60 <= stu_grade.cs_score  
        and 'D'<> stu_grade.other1_grade
        and 'D'<> stu_grade.other2_grade
		and 'D'<> stu_grade.other3_grade
        and 'D'<> stu_grade.other4_grade
); 

#view of qualified science student
create view Pass_Student_for_Science as 
(
	select student.sno, KSH, ZKH, sname, character_score, plunge_score, student.elect1_grade, student.elect2_grade
    from student, stu_grade
    where stu_academic = '理科' 
		and stu_grade.sno = student.sno 
        and 60 <= stu_grade.cs_score  
        and 'D'<> stu_grade.other1_grade
        and 'D'<> stu_grade.other2_grade
		and 'D'<> stu_grade.other3_grade
        and 'D'<> stu_grade.other4_grade
); 



delimiter //      

#check students' info
create trigger Check_Stu_Info
	before insert on student
    for each row 
		begin 
			declare tmp1 varchar(5);
            declare tmp2 varchar(5);
            declare tmp3 varchar(5);
            declare tmp4 varchar(5);
            
            set tmp1 = substring(new.course_choice, 1, 1);                #?
			if new.stu_academic = '文科' and tmp1 = '4' then set new.stu_academic = null; set new.course_choice = null; end if;
            if new.stu_academic = '理科' and tmp1 = '6' then set new.stu_academic = null; set new.course_choice = null; end if;
			
            
            set tmp1 = substring(new.sno, 3, 4);                  #?
            set tmp2 = substring(new.KSH, 5, 4);                
            set tmp3 = substring(new.ZKH, 3, 4);
            set tmp4 = substring(new.senior_school_no, 1, 4);
            if tmp1 != tmp2 or tmp1 != tmp3 or tmp1 != tmp4 then 
				set new.sno = null; set new.KSH = null; set new.ZKH = null; set new.senior_school_no = null; end if;
			
            set tmp1 = substring(new.KSH, 3, 2);
            if tmp1 != '32' then set new.KSH = null; end if;
            
            set tmp1 = new.course_choice;
            set tmp2 = substring(new.KSH, 9, 2);
            set tmp3 = substring(new.ZKH, 7, 2);
            if tmp1 != tmp2 or tmp1 != tmp3 then 
				set new.course_choice = null; set new.KSH = null; set new.ZKH = null; end if;
			
            set tmp1 = substring(new.sno, 9, 4);
            set tmp2 = substring(new.KSH, 11, 4);
            if tmp1 != tmp2 then set new.sno = null; set new.KSH = null; end if;
            
            set tmp1 = substring(new.sno, 1, 2);
            set tmp2 = substring(new.KSH, 1, 2);
            set tmp3 = substring(new.ZKH, 1, 2);
            if tmp1 != tmp2 or tmp1 != tmp3 then 
				set new.sno = null; set new.KSH = null; set new.ZKH = null;  end if;
            
            set tmp1 = substring(new.sno, 7, 2);
            set tmp2 = substring(new.senior_school_no, 5, 2);
            if tmp1 != tmp2 then set new.sno = null; set new.senior_school_no = null; end if;
            
            set tmp1 = substring(new.KSH, 3, 2);
            if tmp1 != '32' then set new.KSH = null; end if;
		end;
		//
            
#check students' grades
create trigger Check_Grade
	before insert on stu_grade
    for each row 
		begin 
			if new.score_yw > 160 or new.score_yw < 0 then set new.score_yw = null; end if;
            if new.score_sx > 160 or new.score_sx < 0 then set new.score_sx = null; end if;
            if new.score_eng > 120 or new.score_eng < 0 then set new.score_eng = null; end if;
            if new.addition > 40 or new.addition < 0 then set new.addition = null; end if;
            if new.elect1_score != null and new.elect1_score > 120 or new.elect1_score < 0 then set new.elect1_score = null; end if;
            if new.elect2_score != null and new.elect2_score > 120 or new.elect2_score < 0 then set new.elect2_score = null; end if;
            if new.other1_score > 100 or new.other1_score < 0 then set new.other1_score = null; end if;
            if new.other2_score > 100 or new.other2_score < 0 then set new.other2_score = null; end if;
            if new.other3_score > 100 or new.other3_score < 0 then set new.other3_score = null; end if;
            if new.other4_score > 100 or new.other4_score < 0 then set new.other1_score = null; end if;
            if new.cs_score > 100 or new.cs_score < 0 then set new.cs_score = null; end if;
		end;
		//
        
#Calculate 4 required courses and computer science's score & grade	
create trigger Cal_Req_Course
	before insert on stu_grade
	for each row
		begin 
			declare cnt int;
            set cnt = 0;
			if new.other1_score >= 90 then set cnt = cnt + 1; end if;
            if new.other1_score >= 90 then set new.other1_grade = 'A'; end if; 
			if new.other1_score <= 89 and new.other1_score >= 75 then set new.other1_grade = 'B'; end if; 
            if new.other1_score <= 74 and new.other1_score >= 60 then set new.other1_grade = 'C'; end if;
            if new.other1_score <= 59 then set new.other1_grade = 'D'; end if; 
            
            if new.other2_score >= 90 then set cnt = cnt + 1; end if;
            if new.other2_score >= 90 then set new.other2_grade = 'A'; end if; 
			if new.other2_score <= 89 and new.other2_score >= 75 then set new.other2_grade = 'B'; end if; 
            if new.other2_score <= 74 and new.other2_score >= 60 then set new.other2_grade = 'C'; end if;
            if new.other2_score <= 59 then set new.other2_grade = 'D'; end if;
            
            
            if new.other3_score >= 90 then set cnt = cnt + 1; end if;
            if new.other3_score >= 90 then set new.other3_grade = 'A'; end if; 
			if new.other3_score <= 89 and new.other3_score >= 75 then set new.other3_grade = 'B'; end if; 
            if new.other3_score <= 74 and new.other3_score >= 60 then set new.other3_grade = 'C'; end if;
            if new.other3_score <= 59 then set new.other3_grade = 'D'; end if;
            
            if new.other4_score >= 90 then set cnt = cnt + 1; end if;
            if new.other4_score >= 90 then set new.other4_grade = 'A'; end if; 
			if new.other4_score <= 89 and new.other4_score >= 75 then set new.other4_grade = 'B'; end if; 
            if new.other4_score <= 74 and new.other4_score >= 60 then set new.other4_grade = 'C'; end if;
            if new.other4_score <= 59 then set new.other4_grade = 'D'; end if;
            
            if new.cs_score <= 59 then set new.cs_grade = 'Failed';
				else set new.cs_grade = 'Pass'; 
			end if;
            
            if cnt <= 3 then set new.req_score = cnt;
				else set new.req_score = 5;
			end if;
		end;
       // 
       
#calculate 2 elected courses' grade by ranking for each students
#Physics
create procedure Cal_Grade_for_Physics()
	begin
		declare score smallint;  #temp score
        declare sno1 char(12);
        declare no_more_record smallint default 0;
        declare num int default 0;					# #students
        declare cnt int default 1;  		 	# #students who get pre_score
        declare rank int default 0;  			#temp rank
        declare s_pre smallint default 121;   		#previous score
        declare r_pre int default 0;     		#previous rank
        declare p float;#percentage
        declare cursor_phy cursor for select student.sno, stu_grade.elect1_score from student, stu_grade
						where student.sno = stu_grade.sno and stu_academic = '理科' order by stu_grade.elect1_score desc;
		declare continue handler for not found set no_more_record = 1;
        select count(student.sno) from student where student.stu_academic = '理科' into num;
        open cursor_phy;
        fetch cursor_phy into sno1, score;
        select sno1,score;
        while no_more_record != 1 do
			if score = s_pre then set rank = r_pre; set cnt = cnt + 1; end if;
            if score < s_pre then 
				set rank = r_pre + cnt;
                set cnt = 1;
                set r_pre = rank;
                set s_pre = score;
			end if;
            set p = rank/num;
            if p <= 0.05 then
				update student set elect1_grade = 'A+' where sno1 = student.sno;
                update stu_grade set elect1_grade = 'A+' where sno1 = stu_grade.sno; end if;
			if p > 0.05 and p <= 0.2 then 
				update student set elect1_grade = 'A' where sno1 = student.sno;
                update stu_grade set elect1_grade = 'A' where sno1 = stu_grade.sno; end if;
			if p > 0.2 and p <= 0.3 then 
				update student set elect1_grade = 'B+' where sno1 = student.sno;
                update stu_grade set elect1_grade = 'B+' where sno1 = stu_grade.sno; end if;
			if p > 0.3 and p <= 0.5 then 
				update student set elect1_grade = 'B' where sno1 = student.sno;
                update stu_grade set elect1_grade = 'B' where sno1 = stu_grade.sno; end if;
			if p > 0.5 and p <= 0.9 then 
				update student set elect1_grade = 'C' where sno1 = student.sno;
                update stu_grade set elect1_grade = 'C' where sno1 = stu_grade.sno; end if;
			if p > 0.9 then 
				update student set elect1_grade = 'D' where sno1 = student.sno;
                update stu_grade set elect1_grade = 'D' where sno1 = stu_grade.sno; end if;
			fetch cursor_phy into sno1, score;
        end while;
        close cursor_phy;
	end;
	//

#History
create procedure Cal_Grade_for_History()
	begin
		declare score smallint;  #temp score
        declare sno1 char(12);
        declare no_more_record smallint default 0;
        declare num smallint default 0;	  			# #students
        declare cnt smallint default 1;  			# #students who get pre_score
        declare rank smallint default 0;  			#temp rank
        declare s_pre smallint default 121;  	 	#previous score
        declare r_pre smallint default 0;     		#previous rank
        declare p float;  #percentage
        declare cursor_his cursor for select student.sno, stu_grade.elect1_score from student, stu_grade
						where student.sno = stu_grade.sno and stu_academic = '文科' order by stu_grade.elect1_score desc;
		declare continue handler for not found set no_more_record = 1;
        select count(student.sno) from student where student.stu_academic = '文科' into num;
        open cursor_his;
        fetch cursor_his into sno1, score;
        while no_more_record != 1 do
			if score = s_pre then set rank = r_pre; set cnt = cnt + 1;
            else 
				set rank = r_pre + cnt;
                set cnt = 1;
                set r_pre = rank;
                set s_pre = score;
			end if;
            set p = rank / num;
            if p <= 0.05 then
				update student set elect1_grade = 'A+' where sno1 = student.sno;
                update stu_grade set elect1_grade = 'A+' where sno1 = stu_grade.sno; end if;
			if p > 0.05 and p <= 0.2 then 
				update student set elect1_grade = 'A' where sno1 = student.sno;
                update stu_grade set elect1_grade = 'A' where sno1 = stu_grade.sno; end if;
			if p > 0.2 and p <= 0.3 then 
				update student set elect1_grade = 'B+' where sno1 = student.sno;
                update stu_grade set elect1_grade = 'B+' where sno1 = stu_grade.sno; end if;
			if p > 0.3 and p <= 0.5 then 
				update student set elect1_grade = 'B' where sno1 = student.sno;
                update stu_grade set elect1_grade = 'B' where sno1 = stu_grade.sno; end if;
			if p > 0.5 and p <= 0.9 then 
				update student set elect1_grade = 'C' where sno1 = student.sno;
                update stu_grade set elect1_grade = 'C' where sno1 = stu_grade.sno; end if;
			if p > 0.9 then 
				update student set elect1_grade = 'D' where sno1 = student.sno;
                update stu_grade set elect1_grade = 'D' where sno1 = stu_grade.sno; end if;
			fetch cursor_his into sno1, score;
        end while;
        close cursor_his;
	end;
	//

#Chemistry
create procedure Cal_Grade_for_Chemistry()
	begin
		declare score smallint;  #temp score
        declare sno1 char(12);
        declare no_more_record smallint default 0;
        declare num int;  			# #students
        declare cnt int default 1;   			# #students who get pre_score
        declare rank int default 0;  			#temp rank
        declare s_pre smallint default 121;   		#previous score
        declare r_pre int default 0;     		#previous rank
        declare p float;  #percentage
        declare cursor_chem cursor for select student.sno, stu_grade.elect2_score from student, stu_grade
						where  student.sno = stu_grade.sno and course_choice = '45' or course_choice = '65' order by stu_grade.elect2_score desc;
		declare continue handler for not found set no_more_record = 1;
        select count(student.sno) from student where course_choice = '45' or course_choice = '65' into num;
        open cursor_chem;
        fetch cursor_chem into sno1, score;
        while no_more_record != 1 do
			if score = s_pre then set rank = r_pre; set cnt = cnt + 1;
            else 
				set rank = r_pre + cnt;
                set cnt = 1;
                set r_pre = rank;
                set s_pre = score;
			end if;
            set p = rank / num;
            if p <= 0.05 then
				update student set elect2_grade = 'A+' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'A+' where sno1 = stu_grade.sno; end if;
			if p > 0.05 and p <= 0.2 then 
				update student set elect2_grade = 'A' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'A' where sno1 = stu_grade.sno; end if;
			if p > 0.2 and p <= 0.3 then 
				update student set elect2_grade = 'B+' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'B+' where sno1 = stu_grade.sno; end if;
			if p > 0.3 and p <= 0.5 then 
				update student set elect2_grade = 'B' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'B' where sno1 = stu_grade.sno; end if;
			if p > 0.5 and p <= 0.9 then 
				update student set elect2_grade = 'C' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'C' where sno1 = stu_grade.sno; end if;
			if p > 0.9 then 
				update student set elect2_grade = 'D' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'D' where sno1 = stu_grade.sno; end if;
			fetch cursor_chem into sno1, score;
        end while;
        close cursor_chem;
	end;
	//
    
#Geography
create procedure Cal_Grade_for_Geography()
	begin
		declare score smallint;  #temp score
        declare sno1 char(12);
        declare no_more_record smallint default 0;
        declare num int default 0;	  			# #students
        declare cnt int default 1;   			# #students who get pre_score
        declare rank int default 0;  			#temp rank
        declare s_pre smallint default 121;   		#previous score
        declare r_pre int default 0;     		#previous rank
        declare p float;  #percentage
        declare cursor_geo cursor for select student.sno, stu_grade.elect2_score from student, stu_grade
						where  student.sno = stu_grade.sno and course_choice = '47' or course_choice = '67' order by stu_grade.elect2_score desc;
		declare continue handler for not found set no_more_record = 1;
        select count(student.sno) from student where course_choice = '47' or course_choice = '67' into num;
        open cursor_geo;
        fetch cursor_geo into sno1, score;
        while no_more_record != 1 do
			if score = s_pre then set rank = r_pre; set cnt = cnt + 1;
            else 
				set rank = r_pre + cnt;
                set cnt = 1;
                set r_pre = rank;
                set s_pre = score;
			end if;
            set p = rank / num;
            if p <= 0.05 then
				update student set elect2_grade = 'A+' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'A+' where sno1 = stu_grade.sno; end if;
			if p > 0.05 and p <= 0.2 then 
				update student set elect2_grade = 'A' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'A' where sno1 = stu_grade.sno; end if;
			if p > 0.2 and p <= 0.3 then 
				update student set elect2_grade = 'B+' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'B+' where sno1 = stu_grade.sno; end if;
			if p > 0.3 and p <= 0.5 then 
				update student set elect2_grade = 'B' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'B' where sno1 = stu_grade.sno; end if;
			if p > 0.5 and p <= 0.9 then 
				update student set elect2_grade = 'C' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'C' where sno1 = stu_grade.sno; end if;
			if p > 0.9 then 
				update student set elect2_grade = 'D' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'D' where sno1 = stu_grade.sno; end if;
			fetch cursor_geo into sno1, score;
        end while;
        close cursor_geo;
	end;
	//
    
#Politics
create procedure Cal_Grade_for_Politics()
	begin
		declare score smallint;  	#temp score
        declare sno1 char(12);
        declare no_more_record smallint default 0;
        declare num int default 0;	 			# #students
        declare cnt int default 1;   			# #students who get pre_score
        declare rank int default 0;  			#temp rank
        declare s_pre smallint default 121;   		#previous score
        declare r_pre int default 0;     		#previous rank
        declare p float;  #percentage
        declare cursor_pol cursor for select student.sno, stu_grade.elect2_score from student, stu_grade
						where  student.sno = stu_grade.sno and course_choice = '48' or course_choice = '68' order by stu_grade.elect2_score desc;
		declare continue handler for not found set no_more_record = 1;
        select count(student.sno) from student where course_choice = '48' or course_choice = '68' into num;
        open cursor_pol;
        fetch cursor_pol into sno1, score;
        while no_more_record != 1 do
			if score = s_pre then set rank = r_pre; set cnt = cnt + 1;
            else 
				set rank = r_pre + cnt;
                set cnt = 1;
                set r_pre = rank;
                set s_pre = score;
			end if;
            set p = rank / num;
            if p <= 0.05 then
				update student set elect2_grade = 'A+' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'A+' where sno1 = stu_grade.sno; end if;
			if p > 0.05 and p <= 0.2 then 
				update student set elect2_grade = 'A' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'A' where sno1 = stu_grade.sno; end if;
			if p > 0.2 and p <= 0.3 then 
				update student set elect2_grade = 'B+' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'B+' where sno1 = stu_grade.sno; end if;
			if p > 0.3 and p <= 0.5 then 
				update student set elect2_grade = 'B' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'B' where sno1 = stu_grade.sno; end if;
			if p > 0.5 and p <= 0.9 then 
				update student set elect2_grade = 'C' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'C' where sno1 = stu_grade.sno; end if;
			if p > 0.9 then 
				update student set elect2_grade = 'D' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'D' where sno1 = stu_grade.sno; end if;
			fetch cursor_pol into sno1, score;
        end while;
        close cursor_pol;
	end;
	//
    
#Biology
create procedure Cal_Grade_for_Biology()
	begin
		declare score smallint; 	#temp score
        declare sno1 char(12);
        declare no_more_record smallint default 0;
        declare num int default 0;	  		# #students
        declare cnt int default 1;   		# #students who get pre_score
        declare rank int default 0;  		#temp rank
        declare s_pre smallint default 121;   	#previous score
        declare r_pre int default 0;     	#previous rank
        declare p float;  #percentage
        declare cursor_bio cursor for select student.sno, stu_grade.elect2_score from student, stu_grade
						where student.sno = stu_grade.sno and course_choice = '49' or course_choice = '69' order by stu_grade.elect2_score desc;
		declare continue handler for not found set no_more_record = 1;
        select count(student.sno) from student where course_choice = '49' or course_choice = '69' into num;
        open cursor_bio;
        fetch cursor_bio into sno1, score;
        while no_more_record != 1 do
			if score = s_pre then set rank = r_pre; set cnt = cnt + 1;
            else 
				set rank = r_pre + cnt;
                set cnt = 1;
                set r_pre = rank;
                set s_pre = score;
			end if;
            set p = rank / num;
            if p <= 0.05 then
				update student set elect2_grade = 'A+' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'A+' where sno1 = stu_grade.sno; end if;
			if p > 0.05 and p <= 0.2 then 
				update student set elect2_grade = 'A' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'A' where sno1 = stu_grade.sno; end if;
			if p > 0.2 and p <= 0.3 then 
				update student set elect2_grade = 'B+' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'B+' where sno1 = stu_grade.sno; end if;
			if p > 0.3 and p <= 0.5 then 
				update student set elect2_grade = 'B' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'B' where sno1 = stu_grade.sno; end if;
			if p > 0.5 and p <= 0.9 then 
				update student set elect2_grade = 'C' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'C' where sno1 = stu_grade.sno; end if;
			if p > 0.9 then 
				update student set elect2_grade = 'D' where sno1 = student.sno;
                update stu_grade set elect2_grade = 'D' where sno1 = stu_grade.sno; end if;
			fetch cursor_bio into sno1, score;
        end while;
        close cursor_bio;
	end;
	//
    
    
#Art students' ranking
create procedure Rank_in_Province_for_Art()
	begin 
        declare cnt smallint default 1;
        declare s_pre smallint default 500;   #previous score
        declare r_pre smallint default 0;     #previous rank
        declare temp smallint;      #temp score
        declare sno1 char(12);
        declare no_more_record smallint default 0;
        declare cursor_rank_province_art cursor for select sno, plunge_score from student
						where stu_academic = '文科' order by plunge_score desc;
		declare continue handler for not found set no_more_record = 1;
        open cursor_rank_province_art;
        fetch cursor_rank_province_art into sno1, temp;
        while no_more_record != 1 do
			if temp = s_pre then
				update student set rank_in_province = r_pre where sno1 = student.sno;
                set cnt = cnt + 1;
			else 
				update student set rank_in_province = r_pre + cnt where sno1 = student.sno;
                set r_pre = r_pre + cnt;
                set s_pre = temp;
                set cnt = 1;
			end if;
            fetch cursor_rank_province_art into sno1, temp;
		end while;
		close cursor_rank_province_art;
        end;
		// 
  
#Science students' ranking
create procedure Rank_in_Province_for_Sci()
	begin 
        declare cnt smallint default 1;
        declare s_pre smallint default 500;
        declare r_pre smallint default 0;
        declare temp smallint;
        declare sno1 char(12);
        declare no_more_record smallint default 0;
        declare cursor_rank_province_sci cursor for select sno, plunge_score from student
						where stu_academic = '理科' order by plunge_score desc;
		declare continue handler for not found set no_more_record = 1;
        open cursor_rank_province_sci;
        fetch cursor_rank_province_sci into sno1, temp;
        while no_more_record != 1 do
			if temp = s_pre then
				update student set rank_in_province = r_pre where sno1 = student.sno;
                set cnt = cnt + 1;
			else 
				update student set rank_in_province = r_pre + cnt where sno1 = student.sno;
                set r_pre = r_pre + cnt;
                set s_pre = temp;
                set cnt = 1;
			end if;
            fetch cursor_rank_province_sci into sno1, temp;
		end while;
		close cursor_rank_province_sci;
        end;
		// 
        
#Calculate character & plunge score
create procedure Cal_CP()
    begin 
		declare no_more_record int default 0;
		declare sno1 char(12);
        declare yw smallint;
        declare sx smallint;
        declare eng smallint;
		declare addition1 smallint;
        declare req_4 smallint;
        declare cursor_sum cursor for select sno, score_yw, score_sx, score_eng, addition, req_score from stu_grade;
		declare continue handler for not found set no_more_record = 1;
		open cursor_sum;
        fetch cursor_sum into sno1, yw, sx, eng, addition1, req_4;
        while no_more_record != 1 do
			update student set character_score = yw + sx + addition1 
							where student.sno = sno1;
            update student set plunge_score = yw + sx + eng + req_4 + addition1 
							where student.sno = sno1;
			fetch cursor_sum into sno1, yw, sx, eng, addition1, req_4;      #?
		end while; 
        close cursor_sum;
	end;
	//                                       
delimiter ;



#We set 1.yuwen 2.maths 3.english 4.physics 5.chemistry 6.history 7.geography
#8.politics 9.biology 10.computer science
insert into course_info value("语文", 1);
insert into course_info value("数学", 2);
insert into course_info value("英语", 3);
insert into course_info value("物理", 4);
insert into course_info value("化学", 5);
insert into course_info value("历史", 6);
insert into course_info value("地理", 7);
insert into course_info value("政治", 8);
insert into course_info value("生物", 9);
insert into course_info value("信息技术", 10);

insert into course_combine value("45", 4, 5, 6, 7, 8, 9);
insert into course_combine value("47", 4, 7, 5, 6, 8, 9);
insert into course_combine value("48", 4, 8, 5, 6, 7, 9);
insert into course_combine value("49", 4, 9, 5, 6, 7, 8);
insert into course_combine value("65", 6, 5, 4, 7, 8, 9);
insert into course_combine value("67", 6, 7, 4, 5, 8, 9);
insert into course_combine value("68", 6, 8, 4, 5, 7, 9);
insert into course_combine value("69", 6, 9, 4, 5, 7, 8); 

insert into senior_school value(100101, "S_A", 12306);                 #若编号前面全为0 则系统会省略
insert into senior_school value(100102, "S_B", 55555);
insert into senior_school value(100103, "S_C", 45678);

insert into student value("叶尾鱼", "M", "1995-7-28", "320103199507282517", "汉", "100102", "应届", "理科", "45", "18217417434", "南通市", "226001", "叶尾鱼", "151001023457", "15321001453457", "1510014534502", null, null, null, null, null);
insert into stu_grade value("151001023457", 140, 150, 88, 35, 110, null, 90, null, 90, null, 90, null, 90, null, 90, null, 90, null, null);
insert into student value("杨小帆", "M", "1994-11-3", "320103199411032518", "汉", "100101", "应届", "理科", "45", "18001591168", "南京市", "210007", "杨小帆", "151001013456", "15321001453456", "1510014534501", null, null, null, null, null);
insert into stu_grade value("151001013456", 109, 131, 103, 40, 105, null, 100, null, 88, null, 95, null, 95, null, 95, null, 100, null, null);



call Cal_Grade_for_Physics();
call Cal_Grade_for_History();
call Cal_Grade_for_Chemistry();
call Cal_Grade_for_Geography();
call Cal_Grade_for_Politics();
call Cal_Grade_for_Biology();

call Cal_CP();

call Rank_in_Province_for_Art();
call Rank_in_Province_for_Sci();


    