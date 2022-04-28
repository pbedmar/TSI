import numpy as np

def randomgraph(N, M, seed):

	print("int: NUM_NODOS =", N, ";")
	print("int: NUM_ARISTAS =", M, ";")
	print("array[1..NUM_ARISTAS,1..2] of int: aristas = [|", end="")

	# Fijamos la semilla
	np.random.seed(seed)

	# Iteramos para cada arista
	for i in range(M):

		# Generamos dos nodos en [1,N]
		n1 = np.random.randint(0,N)+1
		n2 = np.random.randint(0,N)+1

		# Si son el mismo nodo, se re-genera
		while n1 == n2:
			n2 = np.random.randint(0,N)+1

		# Se imprime la arista
		print(n1, ",", n2, "|", end="")

	print("];")
	print("")


randomgraph(4, 6, 0)