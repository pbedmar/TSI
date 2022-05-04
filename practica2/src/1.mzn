include "globals.mzn";

% Exercise c
float: required_money;
float: required_money_100 = required_money*100;
int: required_money_int = round(required_money_100);
var int: c1; var int: c2; var int: c5; var int: c10; var int: c20; var int: c50;
var int: e1; var int: e2;

var int: cents = c1*1 + c2*2 + c5*5 + c10*10 + c20*20 + c50*50;
var int: euros = e1*100 + e2*200;
var int: countCoins = c1 + c2 + c5 + c10 + c20 + c50 + e1 + e2;

constraint c1>=0 /\ c2>=0 /\ c5>=0 /\ c10>=0 /\ c20>=0 /\ c50>=0 /\ e1>=0 /\ e2>=0;
constraint (cents + euros) == required_money_int;
constraint cents < 100;

solve minimize countCoins;
