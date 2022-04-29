include "globals.mzn";

int: n_tasks = 9;
int: n_workers = 3;
set of int: tasks = 1..n_tasks;
set of int: workers = 1..n_workers;

array [tasks] of var int: start;
array [workers, tasks] of var int: duration = [|
                                                4,3,3,2,4,3,1,1,2|
                                                7,5,1,5,2,2,2,3,3|
                                                10,7,4,8,6,1,3,5,4
                                              |];


var int: end;
var int: c = 0;
array [workers, tasks] of int: counts = [0,0,0];

int: A = 1;
int: B = 2;
int: C = 3;
int: D = 4;
int: E = 5;
int: F = 6;
int: G = 7;
int: H = 8;
int: I = 9;
array [tasks] of string: strTasks = ["A", "B", "C", "D", "E", "F", "G", "H", "I"];

array [tasks] of set of int: reqs =  [{}, {A}, {B}, {A}, {C,D}, {C,D}, {C,D}, {A}, {F,H}];

constraint forall(task in tasks)(start[task] > 0);

% delimit house building time
constraint forall(task in tasks)(
    exists(worker in workers)(
        start[task] + sum(t in 1..task-1)(duration[worker,t]) < end /\ 
        forall(req in tasks)(forall(t in reqs[req])(start[req] >= start[t]+duration[worker,t]))
    )
);

% constraint forall(worker in workers

solve minimize end;

output ["\(strTasks[i]):\(start[i]), " | i in tasks];
% output ["\(end)"];