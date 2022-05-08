include "globals.mzn";

float: required_money;    % ask the user for the money to convert in coins
float: required_money_100 = required_money*100;    % drop decimal units multiplying by 100
int: required_money_int = round(required_money_100);    % transform the money to integer to avoid numerical precision issues when looking for solutions
var int: c1; var int: c2; var int: c5; var int: c10; var int: c20; var int: c50;    % number of cent coins
var int: e1; var int: e2;    % number of euro coins

% weight each type of coin
var int: cents = c1*1 + c2*2 + c5*5 + c10*10 + c20*20 + c50*50;
var int: euros = e1*100 + e2*200;

% total sum of coins
var int: countCoins = c1 + c2 + c5 + c10 + c20 + c50 + e1 + e2;

constraint c1>=0 /\ c2>=0 /\ c5>=0 /\ c10>=0 /\ c20>=0 /\ c50>=0 /\ e1>=0 /\ e2>=0;    % zero or more coins of each type
constraint (cents + euros) == required_money_int;    % ensure that the money we compute matches the one entered by the user
constraint cents < 100;    % only use cents to represent the decimal part of the money

solve minimize countCoins;    % minimize the number of coins
