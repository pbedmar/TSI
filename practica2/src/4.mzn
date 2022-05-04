include "globals.mzn";

int: n_tasks = 9;
int: n_workers = 3;
set of int: tasks = 1..n_tasks;
set of int: workers = 1..n_workers;

% start, begin and end
array [1..3, tasks] of var int: plan;
int: START = 1;
int: DURATION = 2;
int: WORKER = 3; 

% time required per worker to complete each task
array [workers, tasks] of var int: duration = [|
                                                4,3,3,2,4,3,1,1,2|
                                                7,5,1,5,2,2,2,3,3|
                                                10,7,4,8,6,1,3,5,4
                                              |];

% start restrictions between tasks
array [tasks] of set of int: reqs =  [{}, {A}, {B}, {A}, {C,D}, {C,D}, {C,D}, {A}, {F,H}];

% task indexing
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

var int: maxDuration = max([plan[START,task] + plan[DURATION, task] | task in tasks]);


constraint forall(row in 1..3)(
    forall(task in tasks)(
        plan[row, task] > 0
    )
);

constraint (plan[START,A] + plan[DURATION,A]) <= plan[START,B];
constraint (plan[START,B] + plan[DURATION,B]) <= plan[START,C];
constraint (plan[START,A] + plan[DURATION,A]) <= plan[START,D];
constraint (plan[START,C] + plan[DURATION,C]) <= plan[START,E] /\ (plan[START,D] + plan[DURATION,D]) <= plan[START,E];
constraint (plan[START,C] + plan[DURATION,C]) <= plan[START,F] /\ (plan[START,D] + plan[DURATION,D]) <= plan[START,F];
constraint (plan[START,C] + plan[DURATION,C]) <= plan[START,G] /\ (plan[START,D] + plan[DURATION,D]) <= plan[START,G];
constraint (plan[START,A] + plan[DURATION,A]) <= plan[START,H];
constraint (plan[START,F] + plan[DURATION,F]) <= plan[START,I] /\ (plan[START,H] + plan[DURATION,H]) <= plan[START,I];

constraint forall(task in tasks)(
    plan[WORKER, task] <= 3
);

constraint forall(task in tasks)(
    plan[DURATION, task] == duration[plan[WORKER, task], task]
);

constraint forall(task in tasks)(
    forall(task2 in tasks)(
        if task != task2 then
            if plan[WORKER, task] == plan[WORKER, task2] then
                plan[START, task] + plan[DURATION, task] <= plan[START, task2] xor
                plan[START, task2] + plan[DURATION, task2] <= plan[START, task]
            endif
        endif
    )
);

% solve minimize max(row(plan, START));
solve minimize maxDuration;

output ["\(plan[i,j]) " ++ if j == n_tasks then "\n" else "" endif | i in 1..3, j in tasks] ++ ["Duración máxima: \(maxDuration)"];