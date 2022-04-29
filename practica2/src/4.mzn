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
% array [tasks] of var int: duration1 = [4,3,3,2,4,3,1,1,2];
% array [tasks] of var int: duration2 = [7,5,1,5,2,2,2,3,3];
% array [tasks] of var int: duration3 = [10,7,4,8,6,1,3,5,4];
var int: end;

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

set of int: A_req = {};
set of int: B_req = {A};
set of int: C_req = {B};
set of int: D_req = {A};
set of int: E_req = {C, D};
set of int: F_req = {C, D};
set of int: G_req = {C, D};
set of int: H_req = {A};
set of int: I_req = {F, H};

% delimit house building time
constraint forall(task in tasks)(
    forall(worker in 1..3)(
        (start[task] + sum(t in 1..task-1)(duration[worker,t])) <= end 
    )
);

constraint forall(worker in 1..3)(
    forall(task in A_req)(start[A] > start[task]+duration[worker,task]) /\
    forall(task in B_req)(start[B] > start[task]+duration[worker,task]) /\
    forall(task in C_req)(start[C] > start[task]+duration[worker,task]) /\
    forall(task in D_req)(start[D] > start[task]+duration[worker,task]) /\
    forall(task in E_req)(start[E] > start[task]+duration[worker,task]) /\
    forall(task in F_req)(start[F] > start[task]+duration[worker,task]) /\
    forall(task in G_req)(start[G] > start[task]+duration[worker,task]) /\
    forall(task in H_req)(start[H] > start[task]+duration[worker,task]) /\
    forall(task in I_req)(start[I] > start[task]+duration[worker,task])
);

% constraint forall(task in 2..n_tasks)(
    
% );








constraint forall(task in tasks)(start[task] > 0);

% constraint forall(task in A_req)(start[A] > start[task]);
% constraint forall(task in B_req)(start[B] > start[task]);
% constraint forall(task in C_req)(start[C] > start[task]);
% constraint forall(task in D_req)(start[D] > start[task]);
% constraint forall(task in E_req)(start[E] > start[task]);
% constraint forall(task in F_req)(start[F] > start[task]);
% constraint forall(task in G_req)(start[G] > start[task]);
% constraint forall(task in H_req)(start[H] > start[task]);
% constraint forall(task in I_req)(start[I] > start[task]);

solve minimize end;

output ["\(strTasks[i]):\(start[i]), " | i in tasks];
% output ["\(end)"];