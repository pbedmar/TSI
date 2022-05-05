include "globals.mzn";

int: NUM_NODOS = 4 ;
int: NUM_ARISTAS = 6 ;
array[1..NUM_ARISTAS,1..2] of int: aristas = [|1 , 4 |2 , 1 |3 , 4 |3 , 4 |1 , 4 |3 , 2 |];

set of int: n_aristas = 1..NUM_ARISTAS;

array[n_aristas] of var int: colores;
array[n_aristas] of var bool: ocurrencias;

constraint forall(i in n_aristas)(colores[i]>0);

constraint forall(a in n_aristas)(
    forall(a2 in n_aristas)(
        if not ((aristas[a,1] == aristas[a2,1] /\ aristas[a,2] == aristas[a2,2]) \/ (aristas[a,1] == aristas[a2,2] /\ aristas[a,2] == aristas[a2,1])) then
            if aristas[a,1] == aristas[a2,1] \/ aristas[a,1] == aristas[a2,2] \/ aristas[a,2] == aristas[a2,1] \/ aristas[a,2] == aristas[a2,2] then
                colores[a] != colores[a2]
            endif
        endif
    )
);

solve minimize max(colores);
output ["Número de colores mínimo: \(max(colores))"]