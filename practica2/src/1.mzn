include "globals.mzn";

float: money;

var int: c1; var int: c2; var int: c5; var int: c10; var int: c20; var int: c50;
var int: e1; var int: e2;
var float: quantity = c1*0.01 + c2*0.02 + c5*0.05 + c10*0.1 + c20*0.2 + c50*0.5 + e1*1.0 + e2*2.0;

constraint c1>=0 /\ c2>=0 /\ c5>=0 /\ c10>=0 /\ c20>=0 /\ c50>=0 /\ e1>=0 /\ e2>=0;
constraint quantity == money;

solve satisfy;