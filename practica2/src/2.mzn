include "globals.mzn";

% initialize values
int: n_days=5;
int: n_hours=6;
int: n_courses=9;
set of int: days=1..n_days;
set of int: hours=1..n_hours;
set of int: courses=0..n_courses;

% the representation we use consists of a matrix. on it, each row represents a day and each column an hour.
array [days, hours] of var courses: rooms;

% specify courses which take 4, 2 or 1 hour weekly
set of int: courses_4h = {1,3,4,5};
set of int: courses_2h = {2,6,7,8};
set of int: courses_1h = {9};

% specify courses which are teached in blocks of 2 or 1 hours
set of int: courses_b2h = {1,3,4,5,8};
set of int: courses_b1h = {2,6,7,9};

% courses teached by each professor
set of int: prof1 = {1,3};
set of int: prof2 = {4,5};
set of int: prof3 = {6,9};
set of int: prof4 = {2,7,8};

% constraint the number of hours per course. 
% for example, courses in courses_4h should appear four times in the weekly calendar (using 4 time slots of 1 hour)
constraint forall(course in courses_4h)(
    count(rooms,course) == 4
);
constraint forall(course in courses_2h)(
    count(rooms,course) == 2
);
constraint forall(course in courses_1h)(
    count(rooms,course) == 1
);


% ensure that courses teached in 2 hour blocks maintain the restriction.
constraint forall(day in days)(
    forall(hour in 2..n_hours-1)(
        if rooms[day,hour] in courses_b2h then
            rooms[day,hour] == rooms[day,hour-1] \/ rooms[day,hour] == rooms[day,hour+1] % or the previous or the following hour should be occupied by the same course
        endif
    )
);


% on each day can only be teached one block of each course
% constraint for 2h courses
constraint forall(day in days)(
    forall(course in courses_b2h)(
        count(row(rooms,day), course) <= 2
    )
);

% constraint for 1h courses
constraint forall(day in days)(
    forall(course in courses_b1h)(
        count(row(rooms,day), course) <= 1
    )
);

% prof1, prof2 and prof3 can only teach one course per day
constraint forall(day in days)(
    (count(row(rooms,day),1) == 0 \/ count(row(rooms,day),3) == 0) /\    %prof1
    (count(row(rooms,day),4) == 0 \/ count(row(rooms,day),5) == 0) /\    %prof2
    (count(row(rooms,day),6) == 0 \/ count(row(rooms,day),9) == 0)       %prof3
);

% break at fourth slot
constraint forall(day in days)(rooms[day,4] == 0);

% professors' time restrictions
constraint forall(day in days)(
    forall(prof in prof1)(
        rooms[day, 1] != prof /\ rooms[day, 2] != prof /\ rooms[day, 3] != prof /\ rooms[day, 4] != prof    % prof1 only teaches during last 2 hours
    ) /\
    forall(prof in prof2)(
        rooms[day, 3] != prof /\ rooms[day, 4] != prof /\ rooms[day, 5] != prof /\ rooms[day, 6] != prof    % prof2 only teaches during first 2 hours
    ) /\
    forall(prof in prof3)(
        rooms[day, 1] != prof /\ rooms[day, 2] != prof /\ rooms[day, 4] != prof /\ rooms[day, 5] != prof /\ rooms[day, 6] != prof    % prof3 only teaches during the hour before the break
    )
);

% course restrictions by day of the week. each line represents a day, and ensures that some courses are not teached that day
constraint count(row(rooms,1),3) == 0 /\ count(row(rooms,1),5) == 0 /\ count(row(rooms,1),6) == 0 /\ count(row(rooms,1),7) == 0 /\ count(row(rooms,1),8) == 0;
constraint count(row(rooms,2),3) == 0 /\ count(row(rooms,2),5) == 0 /\ count(row(rooms,2),6) == 0 /\ count(row(rooms,2),8) == 0 /\ count(row(rooms,2),9) == 0;
constraint count(row(rooms,3),1) == 0 /\ count(row(rooms,3),4) == 0 /\ count(row(rooms,3),5) == 0 /\ count(row(rooms,3),7) == 0 /\ count(row(rooms,3),9) == 0;
constraint count(row(rooms,4),1) == 0 /\ count(row(rooms,4),4) == 0 /\ count(row(rooms,4),6) == 0 /\ count(row(rooms,4),7) == 0 /\ count(row(rooms,4),8) == 0 /\ count(row(rooms,4),9) == 0;
constraint count(row(rooms,5),1) == 0 /\ count(row(rooms,5),3) == 0 /\ count(row(rooms,5),4) == 0 /\ count(row(rooms,5),8) == 0 /\ count(row(rooms,5),9) == 0;

solve satisfy;

output ["\(rooms[i,j]) " ++ if i == 5 then "\n" else "" endif | j in 1..n_hours, i in 1..n_days];