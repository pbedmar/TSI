include "globals.mzn";

int: n_tasks = 9;
int: n_workers = 3;
set of int: tasks = 1..n_tasks;
set of int: workers = 1..n_workers;

% array storing start, duration and worker of each task
array [1..4, tasks] of var int: plan;
int: START = 1;
int: DURATION = 2;
int: WORKER = 3; 
int: AUX_WORKER = 4;

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

% time required per worker to complete each task
array [workers, tasks] of var int: duration = [|
                                                4,3,3,2,4,3,1,1,2|
                                                7,5,1,5,2,2,2,3,3|
                                                10,7,4,8,6,1,3,5,4
                                              |];

% variable containing the endtime of the construction. to be minimized.
var int: maxEnd = max([plan[START,task] + plan[DURATION, task] | task in tasks]);

% every start time, duration and worker index should be bigger than one
constraint forall(row in 1..3)(
    forall(task in tasks)(
        plan[row, task] > 0
    )
);

% there are three workers and not more.
constraint forall(task in tasks)(
    plan[WORKER, task] <= 3
);

% start time of each task is conditioned on finish time of previous tasks.
constraint (plan[START,A] + plan[DURATION,A]) <= plan[START,B];    % for example, task B can't start until task A had finished.
constraint (plan[START,B] + plan[DURATION,B]) <= plan[START,C];
constraint (plan[START,A] + plan[DURATION,A]) <= plan[START,D];
constraint (plan[START,C] + plan[DURATION,C]) <= plan[START,E] /\ (plan[START,D] + plan[DURATION,D]) <= plan[START,E];
constraint (plan[START,C] + plan[DURATION,C]) <= plan[START,F] /\ (plan[START,D] + plan[DURATION,D]) <= plan[START,F];
constraint (plan[START,C] + plan[DURATION,C]) <= plan[START,G] /\ (plan[START,D] + plan[DURATION,D]) <= plan[START,G];
constraint (plan[START,A] + plan[DURATION,A]) <= plan[START,H];
constraint (plan[START,F] + plan[DURATION,F]) <= plan[START,I] /\ (plan[START,H] + plan[DURATION,H]) <= plan[START,I];

% the duration of completion of each task depends on the worker in use.
constraint forall(task in tasks)(
    if plan[AUX_WORKER, task] == 1 then
        plan[DURATION, task] == (duration[plan[WORKER, task], task]-2)
    endif
);

constraint forall(task in tasks)(
    if plan[AUX_WORKER, task] == 0 then
        plan[DURATION, task] == (duration[plan[WORKER, task], task])
    endif
);

constraint plan[AUX_WORKER,A] == 1;
constraint plan[WORKER,A] == 1;

% ensures that each worker can only work in one task at the same time
constraint forall(task in tasks)(
    forall(task2 in tasks)(
        if task != task2 then
            if plan[WORKER, task] == plan[WORKER, task2] then
                plan[START, task] + plan[DURATION, task] < plan[START, task2] \/
                plan[START, task2] + plan[DURATION, task2] < plan[START, task]
            endif
        endif
    )
);


constraint forall(task in tasks)(
    if plan[DURATION, task] < 3 then
        plan[AUX_WORKER, task] == 0
    else
        plan[AUX_WORKER, task] == 0 \/ plan[AUX_WORKER, task] == 1
    endif
);



% minimize the construction end time
solve minimize maxEnd;

output ["\(strTasks[i]) \t" | i in tasks] ++ ["\n"] ++ ["\(plan[i,j])\t" ++ if j == n_tasks then "\n" else "" endif | i in 1..4, j in tasks] ++ ["Duración máxima: \(maxEnd-1)"];