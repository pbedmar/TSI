package tracks.singlePlayer.evaluacion.src_BEDMAR_LOPEZ_PEDRO;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

import java.util.ArrayList;
import java.util.LinkedList;

public class AgenteIDAStar extends AbstractPlayer {

    // class representing a position on the grid
    public static class Vector2dInt {
        /**
         * X-coordinate of the vector.
         */
        public int x;
        public int y;

        public Vector2dInt() {
            this.x = 0;
            this.y = 0;
        }

        public Vector2dInt(int x, int y) {
            this.x = x;
            this.y = y;
        }

        public Vector2dInt(int x, int y, int g) {
            this.x = x;
            this.y = y;
        }

        public Vector2dInt(Vector2dInt v) {
            this.x = v.x;
            this.y = v.y;
        }

        public Vector2dInt(Vector2d v) {
            this.x = (int) v.x;
            this.y = (int) v.y;
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

    public int manhattanDistance(Vector2dInt n1, Vector2dInt n2) {
        return Math.abs(n1.x - n2.x) + Math.abs(n1.y - n2.y);
    }

    public static Vector2dInt fscale;

    public static Vector2dInt portal;
    public static ArrayList<ArrayList<Boolean>> obstacles;
    public static Vector2dInt avatar_position;

    public static boolean route_computed;
    public static LinkedList<Vector2dInt> queue;
    public static ArrayList<ArrayList<Boolean>> visited;

    public static LinkedList<Types.ACTIONS> actions;
    public static int countExpandedNodes;


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

    public int search(StateObservation so, int g, int threshold) {
        Vector2dInt expandedNode = queue.getLast(); //TODO: getLast() or removeLast()?

        int f = g + manhattanDistance(expandedNode, portal);
        if (f > threshold) {
            return f;
        }
        if (expandedNode.equals(portal)) {
            return -1;
        }

        int min = Integer.MAX_VALUE;

        int x = expandedNode.x;
        int y = expandedNode.y;

        Vector2dInt up = new Vector2dInt(x, y + 1); //TODO: Cambiar up-down en todos los algoritmos menos en este!!!
        if (y + 1 < so.getObservationGrid()[0].length) {
            if (!obstacles.get(x).get(y + 1)) {
                if (!visited.get(x).get(y + 1)) {
                    queue.addLast(up);
                    visited.get(x).set(y + 1, true);
                    int t = search(so, g + 1, threshold);
                    if (t == -1) return -1;
                    if (t < min) {
                        min = t;
                    }
                    queue.removeLast();
                    visited.get(x).set(y + 1, false);
                }
            }
        }

        Vector2dInt down = new Vector2dInt(x, y - 1);
        if (y - 1 >= 0) {
            if (!obstacles.get(x).get(y - 1)) {
                if (!visited.get(x).get(y - 1)) {
                    queue.addLast(down);
                    visited.get(x).set(y - 1, true);
                    int t = search(so, g+1, threshold);
                    if (t == -1) return -1;
                    if (t < min) {
                        min = t;
                    }
                    queue.removeLast();
                    visited.get(x).set(y - 1, false);
                }
            }
        }

        Vector2dInt left = new Vector2dInt(x - 1, y);
        if (x - 1 >= 0) {
            if (!obstacles.get(x - 1).get(y)) {
                if (!visited.get(x - 1).get(y)) {
                    queue.addLast(left);
                    visited.get(x - 1).set(y, true);
                    int t = search(so, g+1, threshold);
                    if (t == -1) return -1;
                    if (t < min) {
                        min = t;
                    }
                    queue.removeLast();
                    visited.get(x - 1).set(y, false);
                }
            }
        }

        Vector2dInt right = new Vector2dInt(x + 1, y);
        if (x + 1 < so.getObservationGrid().length) {
            if (!obstacles.get(x + 1).get(y)) {
                if (!visited.get(x + 1).get(y)) {
                    queue.addLast(right);
                    visited.get(x + 1).set(y, true);
                    int t = search(so, g+1, threshold);
                    if (t == -1) return -1;
                    if (t < min) {
                        min = t;
                    }
                    queue.removeLast();
                    visited.get(x + 1).set(y, false);
                }
            }
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

            int threshold = manhattanDistance(avatar_position, portal);
            queue.addLast(avatar_position);

            while (true) {
                int t = search(so, 0, threshold);
                if (t == -1) {
                    System.out.println(queue);

                    Vector2dInt childNode;
                    Vector2dInt parentNode = queue.removeLast();

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

                    System.out.println(actions);
                    route_computed = true;
                    break;
                }
                if (t == Integer.MAX_VALUE) {
                    actions.addLast(Types.ACTIONS.ACTION_NIL);
                    break;
                }
                threshold = t;
            }

            // end measuring execution time
            double tEnd = System.nanoTime();
            double totalTimeInSeconds = (tEnd - tStart) / 1000000000;

            // log results -- runtime
            System.out.println("RUNTIME: " + totalTimeInSeconds);

            // log results -- route length
            System.out.println("TAMANO DE LA RUTA: " + actions.size());

            // log results -- nb. of expanded nodes
            //System.out.println("NODOS EXPANDIDOS: " + countExpandedNodes);

            // log results -- max nb. of nodes in memory
            //System.out.println("MAX NODOS EN MEMORIA: " + maxMemoryConsumption);
        }

        // get next action to be performed by the agent
        Types.ACTIONS next = Types.ACTIONS.ACTION_NIL;
        if (!actions.isEmpty()) {
            next = actions.removeLast();
        }

        return next;
    }
}
