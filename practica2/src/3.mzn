include "globals.mzn";

int: n_variants=5;
set of int: variants=1..n_variants;

array [variants] of var variants: regions;
int: vasco=1;
int: catalan=2;
int: gallego=3;
int: navarro=4;
int: andaluz=5;
array [variants] of string: strRegions = ["vasco","catalan","gallego","navarro","andaluz"];

array [variants] of var variants: jobs;
int: painter=1;
int: sculptor=2;
int: diplomat=3;
int: violinist=4;
int: doctor=5; 
array [variants] of string: strJobs = ["pintor","escultor","diplomático","violinista","médico"];

array [variants] of var variants: animals;
int: dog=1;
int: snail=2;
int: fox=3;
int: horse=4;
int: zebra=5; 
array [variants] of string: strAnimals = ["perro","caracoles","zorro","caballo","cebra"];

array [variants] of var variants: drinks;
int: tea=1;
int: coffee=2;
int: milk=3;
int: juice=4;
int: water=5; 
array [variants] of string: strDrinks = ["te","café","leche","zumo","agua"];

array [variants] of var variants: colors;
int: red=1;
int: green=2;
int: white=3;
int: yellow=4;
int: blue=5; 
array [variants] of string: strColors = ["roja", "verde", "blanca", "amarilla", "azul"];

constraint regions[vasco] == colors[red];
constraint regions[catalan] == animals[dog];
constraint regions[gallego] == jobs[painter];
constraint regions[navarro] == drinks[tea];
constraint regions[andaluz] == 1;
constraint colors[green] == drinks[coffee];
constraint colors[green] == colors[white]+1;
constraint jobs[sculptor] == animals[snail];
constraint jobs[diplomat] == colors[yellow];
constraint 3 == drinks[milk];
constraint regions[andaluz] == colors[blue]+1 \/ regions[andaluz] == colors[blue]-1;
constraint jobs[violinist] == drinks[juice];
constraint animals[fox] == jobs[doctor]+1 \/ animals[fox] == jobs[doctor]-1;
constraint animals[horse] == jobs[diplomat]+1 \/ animals[horse] == jobs[diplomat]-1;

constraint alldifferent(regions);
constraint alldifferent(jobs);
constraint alldifferent(animals);
constraint alldifferent(drinks);
constraint alldifferent(colors);

solve satisfy;

output ["La cebra está en la casa \(strColors[animals[zebra]]). El \(regions[drinks[water]]) bebe agua."]