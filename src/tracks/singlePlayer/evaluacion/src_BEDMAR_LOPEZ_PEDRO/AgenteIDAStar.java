package tracks.singlePlayer.evaluacion.src_BEDMAR_LOPEZ_PEDRO;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedList;
import java.util.PriorityQueue;

public class AgenteIDAStar extends AbstractPlayer {

    // class representing a position on the grid
    public static class Vector2dInt {
        /**
         * X-coordinate of the vector.
         */
        public int x;
        public int y;
        public int c; // count value used to order nodes in a FIFO fashion if h is the same

        public Vector2dInt() {
            this.x = 0;
            this.y = 0;
            this.c = 0;
        }

        public Vector2dInt(int x, int y) {
            this.x = x;
            this.y = y;
            this.c = 0;
        }

        public Vector2dInt(int x, int y, int c) {
            this.x = x;
            this.y = y;
            this.c = c;
        }

        public Vector2dInt(Vector2dInt v) {
            this.x = v.x;
            this.y = v.y;
            this.c = v.c;
        }

        public Vector2dInt(Vector2d v) {
            this.x = (int) v.x;
            this.y = (int) v.y;
            this.c = 0;
        }

        @Override
        public boolean equals(Object o) {
            if (o instanceof Vector2dInt) {
                Vector2dInt v = (Vector2dInt) o;
                return x == v.x && y == v.y;
            } else {
                return false;
            }
        }

        public String toString() {
            return "(" + x + ", " + y + "," + c + ")";
        }


    }

    // manhattan distance between two points in the grid (h component)
    public static int manhattanDistance(Vector2dInt n1, Vector2dInt n2) {
        return Math.abs(n1.x - n2.x) + Math.abs(n1.y - n2.y);
    }

    // used to order the PriorityQueue containing the children of an expanded node. the lower the value, the higher priority.
    // firstly ordered by h, if they are equal ordered using FIFO.
    public static class CostComparator implements Comparator<Vector2dInt> {
        @Override
        public int compare(Vector2dInt v1, Vector2dInt v2) {
            int result = manhattanDistance(v1, portal) - manhattanDistance(v2, portal);
            if (result == 0) {
                result = v1.c - v2.c;
            }
            return result;
        }
    }

    public static Vector2dInt fscale;

    public static Vector2dInt portal;
    public static ArrayList<ArrayList<Boolean>> obstacles;
    public static Vector2dInt avatar_position;

    public static boolean route_computed;
    public static Comparator<Vector2dInt> comparator;
    public static LinkedList<Vector2dInt> queue;
    public static ArrayList<ArrayList<Boolean>> visited; // used only to compute visited nodes

    public static LinkedList<Types.ACTIONS> actions;
    public static int countExpandedNodes;
    public static int maxMemoryConsumption;


    public AgenteIDAStar(StateObservation so, ElapsedCpuTimer elapsedTimer) {
        // scale factor to transform world to grid coordinates
        fscale = new Vector2dInt(so.getWorldDimension().width / so.getObservationGrid().length, so.getWorldDimension().height / so.getObservationGrid()[0].length);

        // store goal (portal) position
        ArrayList<Observation>[] portals = so.getPortalsPositions();
        portal = scale(portals[0].get(0).position);

        // initialize obstacles matrix
        obstacles = new ArrayList<>(so.getObservationGrid().length);
        for (int i = 0; i < so.getObservationGrid().length; i++) {
            obstacles.add(new ArrayList<>(so.getObservationGrid()[0].length));
            for (int j = 0; j < so.getObservationGrid()[0].length; j++) {
                obstacles.get(i).add(false);
            }
        }

        // store obstacles in the level, both walls and traps.
        for (ArrayList<Observation> observations : so.getImmovablePositions()) {
            for (Observation obs : observations) {
                Vector2dInt scaled_pos = scale(obs.position);
                obstacles.get(scaled_pos.x).set(scaled_pos.y, true);
            }
        }

        // start position in grid coordinates
        avatar_position = scale(so.getAvatarPosition());

        route_computed = false;

        comparator = new CostComparator();
        queue = new LinkedList<>();

        // initialize visited matrix, false by default
        visited = new ArrayList<>(so.getObservationGrid().length);
        for (int i = 0; i < so.getObservationGrid().length; i++) {
            visited.add(new ArrayList<>(so.getObservationGrid()[0].length));
            for (int j = 0; j < so.getObservationGrid()[0].length; j++) {
                visited.get(i).add(false);
            }
        }

        actions = new LinkedList<>();
        countExpandedNodes = 0;
        maxMemoryConsumption = 0;
    }

    // world coordinates to grid coordinates
    public Vector2dInt scale(Vector2dInt position) {
        return new Vector2dInt(position.x / fscale.x,
                position.y / fscale.y);
    }

    // world coordinates to grid coordinates, now using Vector2d
    public Vector2dInt scale(Vector2d position) {
        return new Vector2dInt((int) position.x / fscale.x,
                (int) position.y / fscale.y);
    }

    // executed in a recursive fashion
    public int search(StateObservation so, int g, int threshold) {
        Vector2dInt expandedNode = queue.getLast();

        // used to measure the memory footprint
        if(g + 1 > maxMemoryConsumption) {
            maxMemoryConsumption = g + 1;
        }

        // compute f in current node
        int f = g + manhattanDistance(expandedNode, portal);
        if (f > threshold) {
            return f;
        }

        countExpandedNodes++;
        // if the expanded node is the goal
        if (expandedNode.equals(portal)) {
            return -1;
        }

        int min = Integer.MAX_VALUE;

        int x = expandedNode.x;
        int y = expandedNode.y;

        // queue used to order children using the comparator
        PriorityQueue<Vector2dInt> children = new PriorityQueue<>(comparator);


        // generate up, down, left and right children. they are generated only if:
        //      -> they are inside the grid
        //      -> there are no obstacles on that position
        //      -> the node is not in the route
        // by following these rules, they are added to children queue.
        // the c attribute is used to store the order in which the children are added to the queue,
        // so in case of draw of the h values, we can use that order.

        Vector2dInt up = new Vector2dInt(x, y - 1, 0);
        if (y - 1 < so.getObservationGrid()[0].length) {
            if (!obstacles.get(x).get(y - 1)) {
                if (!visited.get(x).get(y - 1)) {
                    children.add(up);
                }
            }
        }

        Vector2dInt down = new Vector2dInt(x, y + 1, 1);
        if (y + 1 >= 0) {
            if (!obstacles.get(x).get(y + 1)) {
                if (!visited.get(x).get(y + 1)) {
                    children.add(down);
                }
            }
        }

        Vector2dInt left = new Vector2dInt(x - 1, y, 2);
        if (x - 1 >= 0) {
            if (!obstacles.get(x - 1).get(y)) {
                if (!visited.get(x - 1).get(y)) {
                    children.add(left);
                }
            }
        }

        Vector2dInt right = new Vector2dInt(x + 1, y, 3);
        if (x + 1 < so.getObservationGrid().length) {
            if (!obstacles.get(x + 1).get(y)) {
                if (!visited.get(x + 1).get(y)) {
                    children.add(right);
                }
            }
        }

        // call search() recursively, using the children in the children queue in order
        while (!children.isEmpty()) {
            Vector2dInt child = children.remove();
            queue.addLast(child);
            visited.get(child.x).set(child.y, true);
            int t = search(so, g + 1, threshold);
            if (t == -1) return -1;
            if (t < min) {
                min = t;
            }
            queue.removeLast();
            visited.get(child.x).set(child.y, false);
        }

        return min;
    }

    // executed at each step
    @Override
    public Types.ACTIONS act(StateObservation so, ElapsedCpuTimer elapsedTimer) {

        // route computed only once, before the first step
        if (!route_computed) {

            // start measuring execution time
            double tStart = System.nanoTime();

            // initialize threshold to the start position manhattan distance
            int threshold = manhattanDistance(avatar_position, portal);
            queue.addLast(avatar_position);

            while (true) {
                int t = search(so, 0, threshold);

                // if solution found
                if (t == -1) {

                    Vector2dInt childNode;
                    Vector2dInt parentNode = queue.removeLast();

                    // using the parent-child relationship, generate actions to be performed by the agent.
                    // start from the goal node and end in the start node
                    // store the actions in the actions list
                    while (!queue.isEmpty()) {
                        childNode = parentNode;
                        parentNode = queue.removeLast();

                        if (parentNode.y - childNode.y < 0) {
                            actions.addLast(Types.ACTIONS.ACTION_DOWN);
                        } else if (parentNode.y - childNode.y > 0) {
                            actions.addLast(Types.ACTIONS.ACTION_UP);
                        } else if (parentNode.x - childNode.x < 0) {
                            actions.addLast(Types.ACTIONS.ACTION_RIGHT);
                        } else if (parentNode.x - childNode.x > 0) {
                            actions.addLast(Types.ACTIONS.ACTION_LEFT);
                        }
                    }

                    route_computed = true;
                    break;
                }

                // if not found solution
                if (t == Integer.MAX_VALUE) {
                    actions.addLast(Types.ACTIONS.ACTION_NIL);
                    break;
                }
                threshold = t;
            }

            // end measuring execution time
            double tEnd = System.nanoTime();
            double totalTimeInSeconds = (tEnd - tStart) / 1000000;

            // log results -- runtime
            System.out.println("RUNTIME: " + String.format(java.util.Locale.US,"%.5f", totalTimeInSeconds));

            // log results -- route length (number of actions to be performed)
            System.out.println("TAMANO DE LA RUTA: " + actions.size());

            // log results -- nb. of expanded nodes
            System.out.println("NODOS EXPANDIDOS: " + countExpandedNodes);

            // log results -- max nb. of nodes in memory (depth of the branch)
            System.out.println("MAX NODOS EN MEMORIA: " + maxMemoryConsumption);
        }

        // get next action to be performed by the agent
        Types.ACTIONS next = Types.ACTIONS.ACTION_NIL;
        if (!actions.isEmpty()) {
            next = actions.removeLast();
        }

        return next;
    }
}
