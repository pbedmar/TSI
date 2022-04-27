include "globals.mzn";

set of int: n_days=1..5;
set of int: n_hours=1..6;
set of int: n_courses=0..9;
array [n_days, n_hours] of var n_courses: rooms;

set of int: courses_2h = {1,3,4,5,8};
set of int: courses_1h = {2,6,7,9};

set of int: prof1 = {1,3};
set of int: prof2 = {4,5};
set of int: prof3 = {6,9};
set of int: prof4 = {2,7,8};

% each day can only be teached one block of each course
% constraint for 2h courses
constraint forall(day in n_days)(
    forall(course in courses_2h)(
        count(row(rooms,day), course) <= 2
    )
);

% constraint for 1h courses
constraint forall(day in n_days)(
    forall(course in courses_1h)(
        count(row(rooms,day), course) <= 1
    )
);

% breaktime at fourth slot
 constraint forall(day in n_days)(rooms[day,4] == 0);

% professors' time restrictions
constraint forall(day in n_days)(
    forall(prof in prof1)(
        rooms[day, 1] != prof /\ rooms[day, 2] != prof /\ rooms[day, 3] != prof /\ rooms[day, 4] != prof
    ) /\
    forall(prof in prof2)(
        rooms[day, 3] != prof /\ rooms[day, 4] != prof /\ rooms[day, 5] != prof /\ rooms[day, 6] != prof
    ) /\
    forall(prof in prof3)(
        rooms[day, 1] != prof /\ rooms[day, 2] != prof /\ rooms[day, 4] != prof /\ rooms[day, 5] != prof /\ rooms[day, 6] != prof
    )
);

% courses' day restrictions
constraint count(row(rooms,1),1) > 0 \/ count(row(rooms,2),1) > 0;
constraint count(row(rooms,3),3) > 0 \/ count(row(rooms,4),3) > 0;
constraint count(row(rooms,1),4) > 0 \/ count(row(rooms,2),4) > 0;
constraint count(row(rooms,4),5) > 0 \/ count(row(rooms,5),5) > 0;
constraint count(row(rooms,3),6) > 0 \/ count(row(rooms,5),6) > 0;
constraint count(row(rooms,2),7) > 0 \/ count(row(rooms,5),7) > 0;
constraint count(row(rooms,3),8) > 0;
constraint count(row(rooms,1),9) > 0;

% constraint count(row(rooms,1),3) == 0 /\ count(row(rooms,1),5) == 0 /\ count(row(rooms,1),6) == 0 /\ count(row(rooms,1),7) == 0 /\ count(row(rooms,1),8) == 0;
% constraint count(row(rooms,2),3) == 0 /\ count(row(rooms,2),5) == 0 /\ count(row(rooms,2),6) == 0 /\ count(row(rooms,2),8) == 0 /\ count(row(rooms,2),9) == 0;
% constraint count(row(rooms,3),1) == 0 /\ count(row(rooms,3),4) == 0 /\ count(row(rooms,3),5) == 0 /\ count(row(rooms,3),7) == 0 /\ count(row(rooms,3),9) == 0;
% constraint count(row(rooms,4),1) == 0 /\ count(row(rooms,4),4) == 0 /\ count(row(rooms,4),6) == 0 /\ count(row(rooms,4),7) == 0 /\ count(row(rooms,4),8) == 0 /\ count(row(rooms,4),9) == 0;
% constraint count(row(rooms,5),3) == 0 /\ count(row(rooms,5),5) == 0 /\ count(row(rooms,5),6) == 0 /\ count(row(rooms,5),7) == 0 /\ count(row(rooms,5),8) == 0;

solve satisfy;

output ["\(rooms[i,j]) " ++ if i == 5 then "\n" else "" endif | j in 1..6, i in 1..5];