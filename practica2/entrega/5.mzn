include "globals.mzn";

% declarations extracted from the python script
int: NUM_NODOS = 4 ;
int: NUM_ARISTAS = 6 ;
array[1..NUM_ARISTAS,1..2] of int: aristas = [|1 , 4 |2 , 1 |3 , 4 |3 , 4 |1 , 4 |3 , 2 |];

% colors array containing the color assigned to each edge
set of int: n_aristas = 1..NUM_ARISTAS;
array[n_aristas] of var int: colores;

% all the colors values should be bigger than 0
constraint forall(i in n_aristas)(colores[i]>0);

% if two edges share the same vertex they can't have the same color. nevertheless, if they have the same two vertices, that means
% they are the same edge and they can have the same color
constraint forall(a in n_aristas)(
    forall(a2 in n_aristas)(
        if not ((aristas[a,1] == aristas[a2,1] /\ aristas[a,2] == aristas[a2,2]) \/ (aristas[a,1] == aristas[a2,2] /\ aristas[a,2] == aristas[a2,1])) then % do they are different edges?
            if aristas[a,1] == aristas[a2,1] \/ aristas[a,1] == aristas[a2,2] \/ aristas[a,2] == aristas[a2,1] \/ aristas[a,2] == aristas[a2,2] then % do they share some vertex?
                colores[a] != colores[a2] % they can't have the same color
            endif
        endif
    )
);

% minimize the number of colors (minimize the max color value in the colores array)
solve minimize max(colores);

output ["Número de colores mínimo: \(max(colores))"]