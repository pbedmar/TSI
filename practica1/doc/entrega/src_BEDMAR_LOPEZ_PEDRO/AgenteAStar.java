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

public class AgenteAStar extends AbstractPlayer {
    // class representing a position on the grid
    public static class Vector2dInt {
        /**
         * X-coordinate of the vector.
         */
        public int x;
        public int y;
        public int g;  // g component of the heuristic function
        public int c;  // count value used to order nodes in a FIFO fashion if f and g are the same

        public Vector2dInt() {
            this.x = 0;
            this.y = 0;
            this.g = -1;
            this.c = 0;
        }

        public Vector2dInt(int x, int y) {
            this.x = x;
            this.y = y;
            this.g = -1;
            this.c = 0;
        }

        public Vector2dInt(int x, int y, int g) {
            this.x = x;
            this.y = y;
            this.g = g;
            this.c = 0;
        }

        public Vector2dInt(Vector2dInt v) {
            this.x = v.x;
            this.y = v.y;
            this.g = v.g;
            this.c = 0;
        }

        public Vector2dInt(Vector2d v) {
            this.x = (int) v.x;
            this.y = (int) v.y;
            this.g = -1;
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
    public int manhattanDistance(Vector2dInt n1, Vector2dInt n2) {
        return Math.abs(n1.x - n2.x) + Math.abs(n1.y - n2.y);
    }

    // heuristic function f
    public int f(Vector2dInt node) {
        return node.g + manhattanDistance(node, portal);
    }

    // used to order the PriorityQueue representing the open queue. the lower the value, the higher priority.
    // firstly ordered by f, if they are equal ordered by g, if they are equal ordered using FIFO.
    public class CostComparator implements Comparator<Vector2dInt> {
        @Override
        public int compare(Vector2dInt v1, Vector2dInt v2) {
            int result = f(v1) - f(v2);
            if (result == 0) {
                result = v1.g - v2.g;
                if (result == 0) {
                    result = v1.c - v2.c;
                }
            }
            return result;
        }
    }

    public static Vector2dInt fscale;
    public static int count; // count value used to order nodes in a FIFO fashion

    public static Vector2dInt portal;
    public static ArrayList<ArrayList<Boolean>> obstacles;
    public static Vector2dInt avatar_position;

    public static boolean route_computed;
    public static CostComparator comparator;
    public static PriorityQueue<Vector2dInt> open; // open nodes
    public static ArrayList<ArrayList<Vector2dInt>> openAux; // auxiliary data structure used to access the best node in the open queue in O(1) given its coordinates
    public static ArrayList<ArrayList<Vector2dInt>> closed; // closed nodes
    public static int closedSize; // used to measure the memory footprint
    public static ArrayList<ArrayList<Vector2dInt>> parent;


    public static LinkedList<Types.ACTIONS> actions;
    public static int countExpandedNodes;
    public static int maxMemoryConsumption;


    public AgenteAStar(StateObservation so, ElapsedCpuTimer elapsedTimer) {
        // scale factor to transform world to grid coordinates
        fscale = new Vector2dInt(so.getWorldDimension().width / so.getObservationGrid().length, so.getWorldDimension().height / so.getObservationGrid()[0].length);
        count = 0;

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

        // start position initialization
        avatar_position = scale(so.getAvatarPosition());
        avatar_position.g = 0;
        avatar_position.c = count;
        count++;

        route_computed = false;

        comparator = new CostComparator();
        open = new PriorityQueue<>(comparator);

        // initialize openAux matrix, null values by default
        openAux = new ArrayList<>(so.getObservationGrid().length);
        for (int i = 0; i < so.getObservationGrid().length; i++) {
            openAux.add(new ArrayList<>(so.getObservationGrid()[0].length));
            for (int j = 0; j < so.getObservationGrid()[0].length; j++) {
                openAux.get(i).add(null);
            }
        }

        // initialize closed queue (represented by a matrix), null by default
        closed = new ArrayList<>(so.getObservationGrid().length);
        for (int i = 0; i < so.getObservationGrid().length; i++) {
            closed.add(new ArrayList<>(so.getObservationGrid()[0].length));
            for (int j = 0; j < so.getObservationGrid()[0].length; j++) {
                closed.get(i).add(null);
            }
        }
        closedSize = 0;

        // initialize parent matrix, null parent by default
        parent = new ArrayList<>(so.getObservationGrid().length);
        for (int i = 0; i < so.getObservationGrid().length; i++) {
            parent.add(new ArrayList<>(so.getObservationGrid()[0].length));
            for (int j = 0; j < so.getObservationGrid()[0].length; j++) {
                parent.get(i).add(null);
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

    public void processChild(Vector2dInt expandedNode, Vector2dInt child) {
        int x = expandedNode.x;
        int y = expandedNode.y;

        // if child equals grandparent do nothing
        if (child.equals(parent.get(x).get(y))) {
            ;
        } else {
            // null if the child is not in the closed queue. if it is, get it to access g in next steps
            Vector2dInt closedNode = closed.get(child.x).get(child.y);
            // null if the child is not in the open queue. if it is, get it to access g in next steps
            Vector2dInt prevOpenNode = openAux.get(child.x).get(child.y);

            // if the child is already in the closed queue and its g was bigger than now,
            // remove it from closed and add it to open
            if (closedNode != null && child.g < closedNode.g) {
                closed.get(child.x).set(child.y, null);
                closedSize--;
                open.add(child);
                openAux.get(child.x).set(child.y, child);
                parent.get(child.x).set(child.y, expandedNode);
            // if the child is neither in closed nor open queue, add it to open
            } else if (closedNode == null && prevOpenNode == null) {
                open.add(child);
                openAux.get(child.x).set(child.y, child);
                parent.get(child.x).set(child.y, expandedNode);
            // if the child is already in the open queue and its g was bigger than now,
            // update it with the newer g.
            } else if (prevOpenNode != null && child.g < prevOpenNode.g) {
                open.remove(prevOpenNode);
                open.add(child);
                openAux.get(child.x).set(child.y, child);
                parent.get(child.x).set(child.y, expandedNode);
            }
        }

    }

    // executed at each step
    @Override
    public Types.ACTIONS act(StateObservation so, ElapsedCpuTimer elapsedTimer) {

        // route computed only once, before the first step
        if (!route_computed) {

            // start measuring execution time
            double tStart = System.nanoTime();

            //add start node to the open queue
            open.add(avatar_position);
            openAux.get(avatar_position.x).set(avatar_position.y, avatar_position);


            while (true) {
                // extract the node with lower cost in the open queue
                Vector2dInt expandedNode = open.remove();
                openAux.get(expandedNode.x).set(expandedNode.y, null);
                countExpandedNodes++;

                // if the expanded node is the goal
                if (expandedNode.equals(portal)) {
                    Vector2dInt child_node = expandedNode;
                    Vector2dInt parent_node = parent.get(expandedNode.x).get(expandedNode.y);

                    // using the parent-child relationship, generate actions to be performed by the agent.
                    // start from the goal node and end in the start node
                    // store the actions in the actions list
                    while (parent_node != null) {
                        if (parent_node.y - child_node.y < 0) {
                            actions.addLast(Types.ACTIONS.ACTION_DOWN);
                        } else if (parent_node.y - child_node.y > 0) {
                            actions.addLast(Types.ACTIONS.ACTION_UP);
                        } else if (parent_node.x - child_node.x < 0) {
                            actions.addLast(Types.ACTIONS.ACTION_RIGHT);
                        } else if (parent_node.x - child_node.x > 0) {
                            actions.addLast(Types.ACTIONS.ACTION_LEFT);
                        }

                        child_node = parent_node;
                        parent_node = parent.get(parent_node.x).get(parent_node.y);
                    }

                    route_computed = true;
                    // exit the loop
                    break;
                }

                int x = expandedNode.x;
                int y = expandedNode.y;
                int g = expandedNode.g;

                // generate up, down, left and right children. they are generated only if:
                //      -> they are inside the grid
                //      -> there are no obstacles on that position
                // by following these rules, they are passed to the processChild() function.
                // the c attribute is used to store the order in which the children are added to the queue,
                // so in case of draw of the f and g values, we can use that order.
                if (y - 1 >= 0) {
                    if (!obstacles.get(x).get(y - 1)) {
                        Vector2dInt up = new Vector2dInt(x, y - 1, g + 1);
                        up.c = count;
                        count++;
                        processChild(expandedNode, up);
                    }
                }

                if (y + 1 < so.getObservationGrid()[0].length) {
                    if (!obstacles.get(x).get(y + 1)) {
                        Vector2dInt down = new Vector2dInt(x, y + 1, g + 1);
                        down.c = count;
                        count++;
                        processChild(expandedNode, down);
                    }
                }

                if (x - 1 >= 0) {
                    if (!obstacles.get(x - 1).get(y)) {
                        Vector2dInt left = new Vector2dInt(x - 1, y, g + 1);
                        left.c = count;
                        count++;
                        processChild(expandedNode, left);
                    }
                }

                if (x + 1 < so.getObservationGrid().length) {
                    if (!obstacles.get(x + 1).get(y)) {
                        Vector2dInt right = new Vector2dInt(x + 1, y, g + 1);
                        right.c = count;
                        count++;
                        processChild(expandedNode, right);
                    }
                }

                // insert the expanded node in the closed queue
                closed.get(expandedNode.x).set(expandedNode.y, expandedNode);
                closedSize++;

                // check closed + open queues size. stores the maximum size reached during the program execution
                int memoryConsumption = closedSize + open.size();
                if (memoryConsumption > maxMemoryConsumption) {
                    maxMemoryConsumption = memoryConsumption;
                }

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

            // log results -- max nb. of nodes in memory (max(|open| + |closed|))
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
