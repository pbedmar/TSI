include "globals.mzn";

% for each variable there are five possible options
int: n_variants=5;
set of int: variants=1..n_variants;

% variables containing the solution indexes;
var int: colorHouseZebra;
var int: personDrinkingWater;

% encode each person origin region
array [variants] of var variants: regions;
int: vasco=1;
int: catalan=2;
int: gallego=3;
int: navarro=4;
int: andaluz=5;
array [variants] of string: strRegions = ["vasco","catalán","gallego","navarro","andaluz"];

% encode each person job
array [variants] of var variants: jobs;
int: painter=1;
int: sculptor=2;
int: diplomat=3;
int: violinist=4;
int: doctor=5; 
array [variants] of string: strJobs = ["pintor","escultor","diplomático","violinista","médico"];

% encode each person animal
array [variants] of var variants: animals;
int: dog=1;
int: snail=2;
int: fox=3;
int: horse=4;
int: zebra=5; 
array [variants] of string: strAnimals = ["perro","caracoles","zorro","caballo","cebra"];

% encode each person drink
array [variants] of var variants: drinks;
int: tea=1;
int: coffee=2;
int: milk=3;
int: juice=4;
int: water=5; 
array [variants] of string: strDrinks = ["te","café","leche","zumo","agua"];

% encode each house color
array [variants] of var variants: colors;
int: red=1;
int: green=2;
int: white=3;
int: yellow=4;
int: blue=5; 
array [variants] of string: strColors = ["roja", "verde", "blanca", "amarilla", "azul"];

% there is still a missing variable that we haven't initialized: the house position in the street.
% we don't explicitly do that because is encoded in the representation. each array position on then
% rest of variables tell us this house position. for example, regions[vasco] will tell us in what house
% lives the vasco. we use that relation to codify the constraints.
% the constraints are declared in the same order specified on the professors' PDF.
constraint regions[vasco] == colors[red];
constraint regions[catalan] == animals[dog];
constraint regions[gallego] == jobs[painter];
constraint regions[navarro] == drinks[tea];
constraint regions[andaluz] == 1;               % andaluz lives on the first house on the left.
constraint colors[green] == drinks[coffee];
constraint colors[green] == colors[white]+1;
constraint jobs[sculptor] == animals[snail];
constraint jobs[diplomat] == colors[yellow];
constraint 3 == drinks[milk];                   % in the house in the middle, milk is drinked.
constraint regions[andaluz] == colors[blue]+1 \/ regions[andaluz] == colors[blue]-1;
constraint jobs[violinist] == drinks[juice];
constraint animals[fox] == jobs[doctor]+1 \/ animals[fox] == jobs[doctor]-1;
constraint animals[horse] == jobs[diplomat]+1 \/ animals[horse] == jobs[diplomat]-1;

% each option for each variable should be different
constraint alldifferent(regions);
constraint alldifferent(jobs);
constraint alldifferent(animals);
constraint alldifferent(drinks);
constraint alldifferent(colors);

% make colorHouseZebra and personDrinkingWater variables store the solution indexes
constraint colors[colorHouseZebra] == animals[zebra];
constraint regions[personDrinkingWater] == drinks[water];

solve satisfy;

% prints the index where the solution is stored in the array. if the zebra is the house 2, means the second position on the strColors array (green). 
output ["La cebra está en la casa \(colorHouseZebra). El \(personDrinkingWater) bebe agua."]