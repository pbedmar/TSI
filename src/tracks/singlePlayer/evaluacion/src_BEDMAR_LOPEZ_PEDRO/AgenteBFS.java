package tracks.singlePlayer.evaluacion.src_BEDMAR_LOPEZ_PEDRO;

import core.game.Observation;
import core.game.StateObservation;
import core.player.AbstractPlayer;
import ontology.Types;
import tools.ElapsedCpuTimer;
import tools.Pair;
import tools.Vector2d;
import tracks.singlePlayer.simple.greedyTreeSearch.TreeNode;

import java.util.*;

public class AgenteBFS extends AbstractPlayer {

    public class Vector2dInt {
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

//        @Override
//        public int hashCode() {
//            return this.x + this.y;
//        }

        public String toString() {
            return "(" + x + ", " + y + ")";
        }


    }

    public static Random random;
    public static Vector2dInt fscale;

    public static Vector2dInt portal;
    public static ArrayList<ArrayList<Boolean>> obstacles;
    public static Vector2dInt avatar_position;

    public static boolean route_computed;
    public static LinkedList<Vector2dInt> queue;
    public static ArrayList<ArrayList<Vector2dInt>> parent;
    public static ArrayList<ArrayList<Boolean>> visited;

    public static LinkedList<Types.ACTIONS> actions;

    public AgenteBFS(StateObservation so, ElapsedCpuTimer elapsedTimer) {
        fscale = new Vector2dInt(so.getWorldDimension().width / so.getObservationGrid().length, so.getWorldDimension().height / so.getObservationGrid()[0].length);

        ArrayList<Observation>[] portals = so.getPortalsPositions();
        portal = scale(portals[0].get(0).position);

        obstacles = new ArrayList<>(so.getObservationGrid().length);
        for (int i = 0; i < so.getObservationGrid().length; i++) {
            obstacles.add(new ArrayList<>(so.getObservationGrid()[0].length));
            for (int j = 0; j < so.getObservationGrid()[0].length; j++) {
                obstacles.get(i).add(false);
            }
        }
//        System.out.println(so.getObservationGrid()[0].length);
//        System.out.println(so.getObservationGrid().length);

        for (ArrayList<Observation> observations : so.getImmovablePositions()) {
            for (Observation obs : observations) {
                Vector2dInt scaled_pos = scale(obs.position);
                obstacles.get(scaled_pos.x).set(scaled_pos.y, true);
            }
        }

        avatar_position = scale(so.getAvatarPosition());


//        //portal.x = Math.floor(portal.x / scale.x);
//        //portal.y = Math.floor(portal.y / scale.y);
//
//        Vector2dInt v1 = new Vector2dInt(2,5);
//        Vector2dInt v2 = new Vector2dInt(2,5);
//        Vector2dInt v3 = new Vector2dInt(3,4);
//        HashSet<Vector2dInt> hs2 = new HashSet<>();
//        HashMap<Vector2dInt, Vector2dInt> hm = new HashMap<>();
//
//        ArrayList<Vector2dInt> al2 = new ArrayList<>();
//
//        hs2.add(v1);
//        if(hs2.contains(v2)) {
//            System.out.println("Contenido");
//        }
//
//        al2.add(v1);
//        if(al2.contains(v2)) {
//            System.out.println("Contenido");
//        }
//
//        if(v2.equals(v1)) {
//            System.out.println("Iguales");
//        }
//
//          hm.put(v1,v3);
//          if(hm.containsKey(v1)) {
//              System.out.println("Contenido");
//          }

        route_computed = false;
        queue = new LinkedList<>();

        parent = new ArrayList<>(so.getObservationGrid().length);
        for (int i = 0; i < so.getObservationGrid().length; i++) {
            parent.add(new ArrayList<>(so.getObservationGrid()[0].length));
            for (int j = 0; j < so.getObservationGrid()[0].length; j++) {
                parent.get(i).add(null);
            }
        }

        visited = new ArrayList<>(so.getObservationGrid().length);
        for (int i = 0; i < so.getObservationGrid().length; i++) {
            visited.add(new ArrayList<>(so.getObservationGrid()[0].length));
            for (int j = 0; j < so.getObservationGrid()[0].length; j++) {
                visited.get(i).add(false);
            }
        }

        actions = new LinkedList<>();

//        System.out.println(portal);
    }

    @Override
    public Types.ACTIONS act(StateObservation so, ElapsedCpuTimer elapsedTimer) {

        if (!route_computed) {

            visited.get(avatar_position.x).set(avatar_position.y, true);
            //parent.put(avatar_position, null);
            queue.addLast(avatar_position);

            while (!queue.isEmpty() && !route_computed) {
                Vector2dInt expanded_node = queue.removeFirst();
//                System.out.println(expanded_node.x+" "+expanded_node.y);
                int x = expanded_node.x;
                int y = expanded_node.y;

                if (expanded_node.equals(portal)) {

                    Vector2dInt child_node = expanded_node;
                    Vector2dInt parent_node = parent.get(x).get(y);

//                    if (parent_node == null) {
//                        actions.addLast(Types.ACTIONS.ACTION_NIL);
//                    }

                    while (parent_node!=null) {
                        if (parent_node.y - child_node.y < 0) {
                            actions.addLast(Types.ACTIONS.ACTION_DOWN);
                        } else if (parent_node.y - child_node.y > 0) {
                            actions.addLast(Types.ACTIONS.ACTION_UP);
                        } else if (parent_node.x - child_node.x < 0) {
                            actions.addLast(Types.ACTIONS.ACTION_RIGHT);
                        } else if (parent_node.x - child_node.x > 0) {
                            actions.addLast(Types.ACTIONS.ACTION_LEFT);
                        }

                        System.out.println(parent_node);

                        child_node = parent_node;
                        parent_node = parent.get(parent_node.x).get(parent_node.y);

                    }

                    System.out.println("");
                    for (Types.ACTIONS ac: actions) {
                        System.out.println(ac);
                    }

                    route_computed = true;

                } else {

                    Vector2dInt up = new Vector2dInt(x, y + 1);
                    if (y + 1 < so.getObservationGrid()[0].length && !visited.get(up.x).get(up.y)) {
                        if (!obstacles.get(x).get(y + 1)) {
                            visited.get(up.x).set(up.y, true);
                            parent.get(up.x).set(up.y, expanded_node);
                            queue.addLast(up);
                        }
                    }

                    Vector2dInt down = new Vector2dInt(x, y - 1);
                    if (y - 1 >= 0 && !visited.get(down.x).get(down.y)) {
                        if (!obstacles.get(x).get(y - 1)) {
                            visited.get(down.x).set(down.y, true);
                            parent.get(down.x).set(down.y, expanded_node);
                            queue.addLast(down);
                        }
                    }

                    Vector2dInt left = new Vector2dInt(x - 1, y);
                    if (x - 1 >= 0 && !visited.get(left.x).get(left.y)) {
                        if (!obstacles.get(x - 1).get(y)) {
                            visited.get(left.x).set(left.y, true);
                            parent.get(left.x).set(left.y, expanded_node);
                            queue.addLast(left);
                        }
                    }

                    Vector2dInt right = new Vector2dInt(x + 1, y);
                    if (x + 1 < so.getObservationGrid().length && !visited.get(right.x).get(right.y)) {
                        if (!obstacles.get(x + 1).get(y)) {
                            visited.get(right.x).set(right.y, true);
                            parent.get(right.x).set(right.y, expanded_node);
                            queue.addLast(right);
                        }
                    }
                }
            }
        }

        Types.ACTIONS next = Types.ACTIONS.ACTION_NIL;
        if (!actions.isEmpty()) {
            next = actions.removeLast();
        }

        return next;
    }

    public Vector2dInt scale(Vector2dInt position){
        return new Vector2dInt(position.x / fscale.x,
                                        position.y / fscale.y);
    }

    public Vector2dInt scale(Vector2d position){
        return new Vector2dInt((int) position.x / fscale.x,
                (int) position.y / fscale.y);
    }
}
