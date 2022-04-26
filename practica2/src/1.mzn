include "globals.mzn";

% Exercise a
float: required_money;
var int: c1; var int: c2; var int: c5; var int: c10; var int: c20; var int: c50;
var int: e1; var int: e2;

var float: money = c1*0.01 + c2*0.02 + c5*0.05 + c10*0.1 + c20*0.2 + c50*0.5 + e1*1 + e2*2;

constraint c1>=0 /\ c2>=0 /\ c5>=0 /\ c10>=0 /\ c20>=0 /\ c50>=0 /\ e1>=0 /\ e2>=0;
constraint money == required_money;

solve satisfy;

% Why this doesn't work?
% output["money=\(money)\n"]

% Exercise b
% float: money;
% var int: c1; var int: c2; var int: c5; var int: c10; var int: c20; var int: c50;
% var int: e1; var int: e2;
% var float: cents = c1*0.01 + c2*0.02 + c5*0.05 + c10*0.1 + c20*0.2 + c50*0.5;
% var int: euros = e1*1 + e2*2;

% constraint c1>=0 /\ c2>=0 /\ c5>=0 /\ c10>=0 /\ c20>=0 /\ c50>=0 /\ e1>=0 /\ e2>=0;
% constraint (cents + euros) == money;
% constraint cents < 1.0;

% solve satisfy;
