package tracks.singlePlayer.evaluacion.src_BEDMAR_LOPEZ_PEDRO;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Vector2d;

import java.util.*;

public class AgenteBFS extends AbstractPlayer {

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

    public static Vector2dInt fscale;

    public static Vector2dInt portal;
    public static ArrayList<ArrayList<Boolean>> obstacles;
    public static Vector2dInt avatar_position;

    public static boolean route_computed;
    public static LinkedList<Vector2dInt> queue;
    public static ArrayList<ArrayList<Vector2dInt>> parent;
    public static ArrayList<ArrayList<Boolean>> visited;

    public static LinkedList<Types.ACTIONS> actions;
    public static int countExpandedNodes;


    public AgenteBFS(StateObservation so, ElapsedCpuTimer elapsedTimer) {
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

        // initialize parent matrix, null parent by default
        parent = new ArrayList<>(so.getObservationGrid().length);
        for (int i = 0; i < so.getObservationGrid().length; i++) {
            parent.add(new ArrayList<>(so.getObservationGrid()[0].length));
            for (int j = 0; j < so.getObservationGrid()[0].length; j++) {
                parent.get(i).add(null);
            }
        }

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

    // generate up, down, left and right children. they are generated only if:
    //      -> they are inside the grid
    //      -> they haven't been visited before
    //      -> there are no obstacles on that position
    // by following these rules, they are marked as visited, get a parent assigned and are added to the queue
    public void generateChildren(StateObservation so, Vector2dInt expandedNode) {
        int x = expandedNode.x;
        int y = expandedNode.y;

        Vector2dInt up = new Vector2dInt(x, y - 1);
        if (y - 1 >= 0) {
            if (!obstacles.get(x).get(y - 1) && !visited.get(up.x).get(up.y)) {
                visited.get(up.x).set(up.y, true);
                parent.get(up.x).set(up.y, expandedNode);
                queue.addLast(up);
            }
        }

        Vector2dInt down = new Vector2dInt(x, y + 1);
        if (y + 1 < so.getObservationGrid()[0].length) {
            if (!obstacles.get(x).get(y + 1) && !visited.get(down.x).get(down.y)) {
                visited.get(down.x).set(down.y, true);
                parent.get(down.x).set(down.y, expandedNode);
                queue.addLast(down);
            }
        }

        Vector2dInt left = new Vector2dInt(x - 1, y);
        if (x - 1 >= 0) {
            if (!obstacles.get(x - 1).get(y) && !visited.get(left.x).get(left.y)) {
                visited.get(left.x).set(left.y, true);
                parent.get(left.x).set(left.y, expandedNode);
                queue.addLast(left);
            }
        }

        Vector2dInt right = new Vector2dInt(x + 1, y);
        if (x + 1 < so.getObservationGrid().length) {
            if (!obstacles.get(x + 1).get(y) && !visited.get(right.x).get(right.y)) {
                visited.get(right.x).set(right.y, true);
                parent.get(right.x).set(right.y, expandedNode);
                queue.addLast(right);
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

            // add start node to the queue
            visited.get(avatar_position.x).set(avatar_position.y, true);
            parent.get(avatar_position.x).set(avatar_position.y, null);
            queue.addLast(avatar_position);

            // while there are nodes to visit and solution not found
            while (!queue.isEmpty() && !route_computed) {
                Vector2dInt expanded_node = queue.removeFirst();

                // if the expanded node is the goal
                countExpandedNodes++;
                if (expanded_node.equals(portal)) {
                    Vector2dInt child_node = expanded_node;
                    Vector2dInt parent_node = parent.get(expanded_node.x).get(expanded_node.y);

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

                // if the expanded node is not the goal
                } else {

                    generateChildren(so, expanded_node);
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

            // log results -- max nb. of nodes in memory (number of visited nodes)
            int countMaxNodesInMemory = 0;
            for (int i = 0; i < so.getObservationGrid().length; i++) {
                for (int j = 0; j < so.getObservationGrid()[0].length; j++) {
                    if (visited.get(i).get(j)) {
                        countMaxNodesInMemory ++;
                    }
                }
            }
            System.out.println("MAX NODOS EN MEMORIA: " + countMaxNodesInMemory);
        }

        // get next action to be performed by the agent
        Types.ACTIONS next = Types.ACTIONS.ACTION_NIL;
        if (!actions.isEmpty()) {
            next = actions.removeLast();
        }

        return next;
    }
}
