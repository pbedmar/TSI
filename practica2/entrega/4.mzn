include "globals.mzn";

% number of tasks to complete and of available workers (apart from aux worker)
int: n_tasks = 9;
int: n_workers = 3;
set of int: tasks = 1..n_tasks;
set of int: workers = 1..n_workers;

% array used to encode solution. each column represent an activity. the first row indicates the start time, the second row the assigned worker
% and the third one if the auxiliary worker has been assigned to the task or not (takes 0 or 1 of values).
array [1..3, tasks] of var int: plan;
int: START = 1;
int: WORKER = 2; 
int: AUX_WORKER = 3;

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

% variable containing the endtime of the construction. to be minimized. if there is an auxiliary worker cooperating on the task,
% the task duration is decreased by 2 days.
var int: maxEnd = max([plan[START,task] + if plan[AUX_WORKER,task] == 0 then duration[plan[WORKER,task],task] else duration[plan[WORKER,task],task]-2 endif | task in tasks]);

% each task start time should be bigger than zero
constraint forall(task in tasks)(
    plan[START, task] > 0
);

% there are three workers
constraint forall(task in tasks)(
    plan[WORKER, task] > 0 /\ plan[WORKER, task] <= 3
);

% each auxiliary worker boolean indicator takes 0 (auxiliary worker not participating) or 1 (auxiliary worker participating) as value.
constraint forall(task in tasks)(
    plan[AUX_WORKER, task] >= 0 /\ plan[AUX_WORKER, task] <= 1
);


% start time of each task is conditioned on finish time of previous tasks. for example, in the first constraint, task B can't start until task A had finished. 
% an if-then-else structure is used to select the task durations, depending on the use (or not) of the auxiliary worker.

% task B restrictions
constraint plan[START,A] + if plan[AUX_WORKER,A] == 0 then duration[plan[WORKER,A],A] else duration[plan[WORKER,A],A]-2 endif <= plan[START,B];
% task C restrictions
constraint plan[START,B] + if plan[AUX_WORKER,B] == 0 then duration[plan[WORKER,B],B] else duration[plan[WORKER,B],B]-2 endif <= plan[START,C];
% task D restrictions
constraint plan[START,A] + if plan[AUX_WORKER,A] == 0 then duration[plan[WORKER,A],A] else duration[plan[WORKER,A],A]-2 endif <= plan[START,D];
% task E restrictions
constraint plan[START,C] + if plan[AUX_WORKER,C] == 0 then duration[plan[WORKER,C],C] else duration[plan[WORKER,C],C]-2 endif <= plan[START,E];
constraint plan[START,D] + if plan[AUX_WORKER,D] == 0 then duration[plan[WORKER,D],D] else duration[plan[WORKER,D],D]-2 endif <= plan[START,E];
% task F restrictions
constraint plan[START,C] + if plan[AUX_WORKER,C] == 0 then duration[plan[WORKER,C],C] else duration[plan[WORKER,C],C]-2 endif <= plan[START,F];
constraint plan[START,D] + if plan[AUX_WORKER,D] == 0 then duration[plan[WORKER,D],D] else duration[plan[WORKER,D],D]-2 endif <= plan[START,F];
% task G restrictions
constraint plan[START,C] + if plan[AUX_WORKER,C] == 0 then duration[plan[WORKER,C],C] else duration[plan[WORKER,C],C]-2 endif <= plan[START,G];
constraint plan[START,D] + if plan[AUX_WORKER,D] == 0 then duration[plan[WORKER,D],D] else duration[plan[WORKER,D],D]-2 endif <= plan[START,G];
% task H restrictions
constraint plan[START,A] + if plan[AUX_WORKER,A] == 0 then duration[plan[WORKER,A],A] else duration[plan[WORKER,A],A]-2 endif <= plan[START,H];
% task I restrictions
constraint plan[START,F] + if plan[AUX_WORKER,F] == 0 then duration[plan[WORKER,F],F] else duration[plan[WORKER,F],F]-2 endif <= plan[START,I];
constraint plan[START,H] + if plan[AUX_WORKER,H] == 0 then duration[plan[WORKER,H],H] else duration[plan[WORKER,H],H]-2 endif <= plan[START,I];


% ensures that each worker can only work in one task at the same time. the durations depending on the use of the auxiliary worker are also taken into account.
constraint forall(task in tasks)(
    forall(task2 in tasks)(
        if task != task2 then
            % constraint for the three main workers
            if plan[WORKER, task] == plan[WORKER, task2] then
                plan[START, task] + if plan[AUX_WORKER,task] == 0 then duration[plan[WORKER,task],task] else duration[plan[WORKER,task],task]-2 endif <= plan[START, task2] \/
                plan[START, task2] + if plan[AUX_WORKER,task2] == 0 then duration[plan[WORKER,task2],task2] else duration[plan[WORKER,task2],task2]-2 endif <= plan[START, task]
            endif /\
            % constraint for the auxiliary worker (it also can't help two workers at the same time
            if plan[AUX_WORKER, task] == 1 /\ plan[AUX_WORKER, task2] == 1 then
                plan[START, task] + duration[plan[WORKER,task],task]-2 <= plan[START, task2] \/
                plan[START, task2] + duration[plan[WORKER,task2],task2]-2 <= plan[START, task]
            endif
        endif
    )
);

% the auxiliary worker can only participate on tasks which take 3 days or more
constraint forall(task in tasks)(
    if duration[plan[WORKER,task],task] < 3 then
        plan[AUX_WORKER, task] == 0
    endif
);



% minimize the construction end time
solve minimize maxEnd;

% each column represents a task. the first row is the start time of the task, the second row the assigned worker,
% the third the use or not of the auxiliar worker and the fourth the duration of the task
% the total duration of the solution is also specified.
output ["\(strTasks[i]) \t" | i in tasks] ++ ["\n"] ++ ["\(plan[i,j])\t" ++ if j == n_tasks then "\n" else "" endif | i in 1..3, j in tasks] 
++ ["\(duration[plan[WORKER,task],task]) \t" | task in tasks] ++ ["\nDuración mínima: \(maxEnd-1)"];