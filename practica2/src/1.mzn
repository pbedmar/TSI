include "globals.mzn";

% Exercise a
float: required_money;
float: required_money_100 = required_money*100;
int: required_money_int = round(required_money_100);
var int: c1; var int: c2; var int: c5; var int: c10; var int: c20; var int: c50;
var int: e1; var int: e2;

var int: money = c1*1 + c2*2 + c5*5 + c10*10 + c20*20 + c50*50 + e1*100 + e2*200;

constraint c1>=0 /\ c2>=0 /\ c5>=0 /\ c10>=0 /\ c20>=0 /\ c50>=0 /\ e1>=0 /\ e2>=0;
constraint money == required_money_int;

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
