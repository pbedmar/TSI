package tracks.singlePlayer.evaluacion.src_BEDMAR_LOPEZ_PEDRO;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.PriorityQueue;

public class AgenteRTAStar extends AbstractPlayer {
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
            this.c = 0;
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
            return "(" + x + ", " + y + ")";
        }


    }

    // manhattan distance between two points in the grid (h component)
    public int manhattanDistance(int i, int j) {
        return Math.abs(i - portal.x) + Math.abs(j - portal.y);
    }

    // used to order the PriorityQueue containing the children of an expanded node. the lower the value, the higher priority.
    // firstly ordered by h, if they are equal ordered using FIFO.
    public static class CostComparator implements Comparator<Vector2dInt> {
        @Override
        public int compare(Vector2dInt v1, Vector2dInt v2) {
            int result = hMatrix.get(v1.x).get(v1.y) - hMatrix.get(v2.x).get(v2.y);
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

    public static ArrayList<ArrayList<Integer>> hMatrix; // matrix containing the h value of each node in the grid
    public static CostComparator comparator;
    public static ArrayList<ArrayList<Boolean>> visited;

    public static double runtime;
    public static int routeLength;
    public static int countExpandedNodes;

    public AgenteRTAStar(StateObservation so, ElapsedCpuTimer elapsedTimer) {
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

        // initialize h values matrix
        hMatrix = new ArrayList<>(so.getObservationGrid().length);
        for (int i = 0; i < so.getObservationGrid().length; i++) {
            hMatrix.add(new ArrayList<>(so.getObservationGrid()[0].length));
            for (int j = 0; j < so.getObservationGrid()[0].length; j++) {
                hMatrix.get(i).add(manhattanDistance(i, j));
            }
        }

        comparator = new CostComparator();

        // initialize visited matrix, false by default
        visited = new ArrayList<>(so.getObservationGrid().length);
        for (int i = 0; i < so.getObservationGrid().length; i++) {
            visited.add(new ArrayList<>(so.getObservationGrid()[0].length));
            for (int j = 0; j < so.getObservationGrid()[0].length; j++) {
                visited.get(i).add(false);
            }
        }

        runtime = 0;
        routeLength = 0;
        countExpandedNodes = 0;
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

    // generate children ordered by low to high cost
    public PriorityQueue<Vector2dInt> getOrderedChildren(StateObservation so, Vector2dInt expandedNode) {
        int x = expandedNode.x;
        int y = expandedNode.y;

        // queue used to order children using the comparator
        PriorityQueue<Vector2dInt> queue = new PriorityQueue<>(comparator);


        // generate up, down, left and right children. they are generated only if:
        //      -> they are inside the grid
        //      -> there are no obstacles on that position
        // by following these rules, they are added to children queue.
        // the c attribute is used to store the order in which the children are added to the queue,
        // so in case of draw of the h values, we can use that order.

        Vector2dInt up = new Vector2dInt(x, y - 1, 0);
        if (y - 1 >= 0) {
            if (!obstacles.get(x).get(y - 1)) {
                queue.add(up);
                visited.get(up.x).set(up.y, true);
            }
        }

        Vector2dInt down = new Vector2dInt(x, y + 1, 1);
        if (y + 1 < so.getObservationGrid()[0].length) {
            if (!obstacles.get(x).get(y + 1)) {
                queue.add(down);
                visited.get(down.x).set(down.y, true);
            }
        }

        Vector2dInt left = new Vector2dInt(x - 1, y, 2);
        if (x - 1 >= 0) {
            if (!obstacles.get(x - 1).get(y)) {
                queue.add(left);
                visited.get(left.x).set(left.y, true);
            }
        }

        Vector2dInt right = new Vector2dInt(x + 1, y, 3);
        if (x + 1 < so.getObservationGrid().length) {
            if (!obstacles.get(x + 1).get(y)) {
                queue.add(right);
                visited.get(right.x).set(right.y, true);
            }
        }

        return queue;
    }

    public Types.ACTIONS act(StateObservation so, ElapsedCpuTimer elapsedTimer) {

        // start measuring execution time
        double tStart = System.nanoTime();

        PriorityQueue<Vector2dInt> queue = getOrderedChildren(so, avatar_position);

        // get best child and second best child (if exists)
        Vector2dInt bestChild = queue.remove();
        Vector2dInt secondBestChild = bestChild;
        if (queue.size() > 0) {
            secondBestChild = queue.peek();
        }

        // h value from current node and second best child
        int currentNodeH = hMatrix.get(avatar_position.x).get(avatar_position.y);
        int secondBestChildH= hMatrix.get(secondBestChild.x).get(secondBestChild.y) + 1;

        // increase h value of the current node
        int currentNodeUpdatedH = Math.max(currentNodeH, secondBestChildH);
        hMatrix.get(avatar_position.x).set(avatar_position.y, currentNodeUpdatedH);
        visited.get(avatar_position.x).set(avatar_position.y, true);

        // compute action to perform
        Types.ACTIONS result = Types.ACTIONS.ACTION_NIL;
        if (avatar_position.y - bestChild.y < 0) {
            result = Types.ACTIONS.ACTION_DOWN;
        } else if (avatar_position.y - bestChild.y > 0) {
            result = Types.ACTIONS.ACTION_UP;
        } else if (avatar_position.x - bestChild.x < 0) {
            result = Types.ACTIONS.ACTION_RIGHT;
        } else if (avatar_position.x - bestChild.x > 0) {
            result = Types.ACTIONS.ACTION_LEFT;
        }

        // new position is the best child
        avatar_position = bestChild;

        // end measuring execution time
        double tEnd = System.nanoTime();
        double totalTimeInSeconds = (tEnd - tStart) / 1000000;
        runtime += totalTimeInSeconds;
        routeLength++;

        countExpandedNodes++;
        // if the expanded node is the goal
        if(avatar_position.equals(portal)) {
            int maxMemoryConsumption = 0;
            for (int i = 0; i < so.getObservationGrid().length; i++) {
                for (int j = 0; j < so.getObservationGrid()[0].length; j++) {
                    if (visited.get(i).get(j)) {
                        maxMemoryConsumption++;
                    }
                }
            }

            // log results -- accumulated runtime between all the executions of act() (only the time spent to compute the route)
            System.out.println("RUNTIME: " + String.format(java.util.Locale.US,"%.5f", runtime));

            // log results -- route length (number of actions to be performed)
            System.out.println("TAMANO DE LA RUTA: " + routeLength);

            // log results -- nb. of expanded nodes
            System.out.println("NODOS EXPANDIDOS: " + countExpandedNodes);

            // log results -- max nb. of nodes in memory (number of nodes which their h value was needed)
            System.out.println("MAX NODOS EN MEMORIA: " + maxMemoryConsumption);
        }

        return result;
    }
}
