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
        public int g;

        public Vector2dInt() {
            this.x = 0;
            this.y = 0;
            this.g = -1;
        }

        public Vector2dInt(int x, int y) {
            this.x = x;
            this.y = y;
            this.g = -1;
        }

        public Vector2dInt(int x, int y, int g) {
            this.x = x;
            this.y = y;
            this.g = g;
        }

        public Vector2dInt(Vector2dInt v) {
            this.x = v.x;
            this.y = v.y;
            this.g = v.g;
        }

        public Vector2dInt(Vector2d v) {
            this.x = (int) v.x;
            this.y = (int) v.y;
            this.g = -1;
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

    public int f(Vector2dInt node) {
        return node.g + manhattanDistance(node, portal);
    }

    public class CostComparator implements Comparator<Vector2dInt> {
        @Override
        public int compare(Vector2dInt v1, Vector2dInt v2) {
            return f(v1) - f(v2);
        }
    }

    public static Vector2dInt fscale;

    public static Vector2dInt portal;
    public static ArrayList<ArrayList<Boolean>> obstacles;
    public static Vector2dInt avatar_position;

    public static boolean route_computed;
    public static CostComparator comparator;
    public static PriorityQueue<Vector2dInt> open;
    public static ArrayList<ArrayList<Vector2dInt>> visited;
    public static ArrayList<ArrayList<Vector2dInt>> closed;
    public static int closedSize;
    public static ArrayList<ArrayList<Vector2dInt>> parent;


    public static LinkedList<Types.ACTIONS> actions;
    public static int countExpandedNodes;
    public static int maxMemoryConsumption;


    public AgenteAStar(StateObservation so, ElapsedCpuTimer elapsedTimer) {
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
        avatar_position.g = 0;

        route_computed = false;
        comparator = new CostComparator();
        open = new PriorityQueue<>(comparator);

        // initialize openBest matrix, null by default
        visited = new ArrayList<>(so.getObservationGrid().length);
        for (int i = 0; i < so.getObservationGrid().length; i++) {
            visited.add(new ArrayList<>(so.getObservationGrid()[0].length));
            for (int j = 0; j < so.getObservationGrid()[0].length; j++) {
                visited.get(i).add(null);
            }
        }

        // initialize closed matrix, null by default
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

//        PriorityQueue<Vector2dInt> p = new PriorityQueue<>(comparator);
//        Vector2dInt v1 = new Vector2dInt(1,2);
//        v1.g = 2;
//        Vector2dInt v2 = new Vector2dInt(1,2);
//        v2.g = 3;
//        Vector2dInt v3 = new Vector2dInt(4,7);
//        v3.g = 1;
//
//        p.add(v1);
//        p.add(v2);
//        p.add(v3);

//        if (p.contains(v2)) {
//            System.out.println("true");
//        }
//        System.out.println(p.peek());
//        System.out.println(p.remove().g);
//        System.out.println(p.peek());
//        System.out.println(p.remove().g);
//        System.out.println(p.peek());
//        System.out.println(p.remove().g);
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
        closed.get(expandedNode.x).set(expandedNode.y, expandedNode);
        closedSize++;

        if (child.equals(parent.get(x).get(y))) {
            System.out.println("Hola 1");;
        } else {
            Vector2dInt closedNode = closed.get(child.x).get(child.y);
            Vector2dInt prevOpenNode = visited.get(child.x).get(child.y);
            if (closedNode != null) {
                if (child.g < closedNode.g) {
                    closed.get(child.x).set(child.y, null);
                    closedSize--;
                    open.add(child);
                    visited.get(child.x).set(child.y, child);
                    parent.get(child.x).set(child.y, expandedNode);
                    System.out.println("Hola 2");
                } else {
                    System.out.println("Hola 3");
                }
            } else if (closedNode == null && prevOpenNode == null) {
                open.add(child);
                visited.get(child.x).set(child.y, child);
                parent.get(child.x).set(child.y, expandedNode);
                System.out.println("Hola 3");
            } else if (prevOpenNode != null && child.g < prevOpenNode.g) {
                open.remove(prevOpenNode);
                open.add(child);
                visited.get(child.x).set(child.y, child);
                parent.get(child.x).set(child.y, expandedNode);
                System.out.println("Hola 4");
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
            double total = 0;

            open.add(avatar_position);
            visited.get(avatar_position.x).set(avatar_position.y, avatar_position);

            while (true) {

                Vector2dInt expandedNode = open.remove();
                countExpandedNodes++;
                if (expandedNode.equals(portal)) {
                    Vector2dInt child_node = expandedNode;
                    Vector2dInt parent_node = parent.get(expandedNode.x).get(expandedNode.y);

                    // using the parent-child relationship, generate actions to be performed by the agent.
                    // start from the goal node and end in the start node
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

                    System.out.println(actions.size());
                    route_computed = true;
                    break;
                }

                int x = expandedNode.x;
                int y = expandedNode.y;
                int g = expandedNode.g;

                if (y + 1 < so.getObservationGrid()[0].length) {
                    if (!obstacles.get(x).get(y + 1)) {
                        Vector2dInt up = new Vector2dInt(x, y + 1, g + 1);
                        processChild(expandedNode, up);
                    }
                }

                if (y - 1 >= 0) {
                    if (!obstacles.get(x).get(y - 1)) {
                        Vector2dInt down = new Vector2dInt(x, y - 1, g + 1);
                        processChild(expandedNode, down);
                    }
                }

                if (x - 1 >= 0) {
                    if (!obstacles.get(x - 1).get(y)) {
                        Vector2dInt left = new Vector2dInt(x - 1, y, g + 1);
                        processChild(expandedNode, left);
                    }
                }

                if (x + 1 < so.getObservationGrid().length) {
                    if (!obstacles.get(x + 1).get(y)) {
                        Vector2dInt right = new Vector2dInt(x + 1, y, g + 1);
                        processChild(expandedNode, right);
                    }
                }

                int memoryConsumption = closedSize + open.size();
                if (memoryConsumption > maxMemoryConsumption) {
                    maxMemoryConsumption = memoryConsumption;
                }

            }

            // end measuring execution time
            double tEnd = System.nanoTime();
            double totalTimeInSeconds = (tEnd - tStart) / 1000000000;

            for (Types.ACTIONS ac: actions) {
                System.out.println(ac);
            }

            // log results -- runtime
            System.out.println("RUNTIME: " + totalTimeInSeconds);

            // log results -- route length
            System.out.println("TAMANO DE LA RUTA: " + actions.size());

            // log results -- nb. of expanded nodes
            System.out.println("NODOS EXPANDIDOS: " + countExpandedNodes);

            // log results -- max nb. of nodes in memory
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
