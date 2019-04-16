import java.util.*;

public static final int INCREMENT = 20;
public static final int WIDTH = 560;
public static final int HEIGHT = 620;

public static final int EATEN_TURN_BLOCK = 5;
public static final int TURN_BLOCK = 4;
public static final int EMPTY = 3;
public static final int WALL = 0;
public static final int PELLET = 1;
public static final int POWER_PELLET = 2;

public static final int CHASING = 1;
public static final int FRIGHTENED = 2;
public static final int SCATTER = 3;

public final color WHITE = color(255, 255, 255);
public final color BLACK = color(0, 0, 0);
public final color BLUE = color(26, 53, 175);
public final color YELLOW = color(252, 235, 53);
public final color RED = color(244, 75, 66);
public final color PINK = color(255, 81, 205);
public final color ORANGE = color(255, 182, 81);
public final color LIGHT_BLUE = color(94, 239, 249);

public static final int FOUND = 1000;

// Flag for debug mode
boolean DEBUG = false;
// Flag to show the ghost paths
boolean SHOW_PATHS = true;
// Flag to use IDA*
boolean USE_IDA = false;
// Flag to use illustrator visualizations
boolean USE_VIZ = false;

int SCORE = 0;
int LIVES = 3;
int GHOST_APPEARANCE_TIMER = 0;
ArrayList<Cell> POWER_PELLET_POSNS;

Game game;

// Visualizations
PShape boardSvg;
PShape pacmanOSvg;
PShape pacmanCSvg;
PShape blinkySvg;
PShape pinkySvg;
PShape clydeSvg;
PShape inkySvg;
PShape frightenedGhost1;
PShape frightenedGhost2;
PShape ghostEyesSvg;

void setup() {
  //size(561, 621);
  size(561, 701);
  frameRate(120);
  
  // Load SVGs
  boardSvg = loadShape("board.svg");
  pacmanOSvg = loadShape("pacman_open.svg");
  pacmanCSvg = loadShape("pacman_closed.svg");
  blinkySvg = loadShape("blinky.svg");
  pinkySvg = loadShape("pinky.svg");
  clydeSvg = loadShape("clyde.svg");
  inkySvg = loadShape("inky.svg");
  frightenedGhost1 = loadShape("frightened_ghost_1.svg");
  frightenedGhost2 = loadShape("frightened_ghost_2.svg");
  ghostEyesSvg = loadShape("ghost_eyes.svg");
  
  POWER_PELLET_POSNS = new ArrayList();
  POWER_PELLET_POSNS.add(new Cell(3, 1));
  POWER_PELLET_POSNS.add(new Cell(3, 26));
  POWER_PELLET_POSNS.add(new Cell(22, 1));
  POWER_PELLET_POSNS.add(new Cell(22, 26));

  game = new Game();
}

void draw() {
  background(0);
  translate(WIDTH / 2, HEIGHT / 2);
  rectMode(CENTER);
  ellipseMode(CENTER);
  shapeMode(CENTER);
  
  game.render();
  
  this.displayScore();
  this.displayAlgorithmUsed();
  this.displayMode();
  
  Runtime runtime = Runtime.getRuntime();
  runtime.gc();
  long mem = (runtime.totalMemory() - runtime.freeMemory());
  println(mem);
  println(mem / (1024L * 1024L));
}

void keyPressed() {
  if (key == 'd') {
    DEBUG = !DEBUG; 
  } else if (key == 'a') {
    USE_IDA = !USE_IDA;
    game.clampGhostPosns();
  } else if (key == 'p') {
    SHOW_PATHS = !SHOW_PATHS;
  } else if (key == 'v') {
    USE_VIZ = !USE_VIZ;
  }else {
    game.pacman.onKey(); 
  }
}

// Convert x coord to column on grid
public int convertXtoC(int x) {
  int initX = (-WIDTH / 2) + (INCREMENT / 2);
  int c = 0;
  
  while (initX != x) {
    initX += INCREMENT;
    c++;
  }
  
  return c;
}

// Convert y coord to row on grid
public int convertYtoR(int y) {
  int initY = (-HEIGHT / 2) + (INCREMENT / 2);
  int r = 0;
  
  while (initY != y) {
    initY += INCREMENT;
    r++;
  }
  
  return r;
}

// Convert column on grid to an x coord
public int convertCtoX(int c) {
  int x = (-WIDTH / 2) + (INCREMENT / 2);
  
  while (c != 0) {
    c--;
    x += INCREMENT;
  }
  
  return x;
}

// Convert row on grid to y coord
public int convertRtoY(int r) {
  int y = (-HEIGHT / 2) + (INCREMENT / 2);
  
  while (r != 0) {
    r--;
    y += INCREMENT;
  }
  
  return y;
}

// A* algorithm
public ArrayList<Node> aStar(int sr, int sc, int er, int ec) {
  Node start = game.board.getNodeAt(sr, sc);
  Node end = game.board.getNodeAt(er, ec);
  
  PriorityQueue<Node> open = new PriorityQueue();
  Set<Node> closed = new HashSet();
  
  open.add(start);
  
  while (!open.isEmpty()) {
    Node current = open.poll();
    closed.add(current);
    
    // Found goal
    if (current.equals(end)) {
      ArrayList<Node> path = new ArrayList();
      Node n = current;
      
      while (n != null) {
         path.add(n);
         n = n.parent;
      }
      
      return path;
    }
    
    // Loop through neighbors
    if (current.isActive) { 
      
    }
    for (Node neighbor : current.getNeighbors()) {
      if (!game.board.getCellAt(neighbor.row, neighbor.col).isWall()) {
        neighbor.parent = current;
      
        if (closed.contains(neighbor)) {
          continue; 
        }
        
        neighbor.setG(current.getG() + 1);
        neighbor.setH(Math.abs(neighbor.row - end.row) + Math.abs(neighbor.col - end.col));
        neighbor.setF();
        
        for (Node n : open) {
          if (neighbor.equals(n) && neighbor.getG() > n.getG()) {            
            continue; 
          }
        }
        
        open.add(neighbor); 
      } else {
        //closed.add(neighbor);
        continue;
      }
    }
  }
  
  return new ArrayList();
}

// IDA* algorithm
public ArrayList<Node> idaStar(int sr, int sc, int er, int ec) {
  Node start = game.board.getNodeAt(sr, sc);
  Node end = game.board.getNodeAt(er, ec);
  
  int bound = Math.abs(start.row - end.row) + Math.abs(start.col - end.col);
  
  ArrayList<Node> path = new ArrayList();
  
  path.add(start);
  
  while (true) {
    int temp = idaSearch(path, 0, bound, er, ec);
    
    if (temp == FOUND) {
      return path; 
    }
    
    if (temp == Integer.MAX_VALUE) {
      return new ArrayList(); 
    }
    
    bound = temp;
  }
}

public int idaSearch(ArrayList<Node> path, int g, int bound, int er, int ec) {
  Node end = game.board.getNodeAt(er, ec);
  Node node = path.get(path.size() - 1);
  
  int f = g + Math.abs(node.row - end.row) + Math.abs(node.col - end.col);
  
  if (f > bound) {
    return f; 
  }
  
  if (node.equals(end)) {
    return FOUND; 
  }
  
  int min = Integer.MAX_VALUE;
  
  for (Node neighbor : node.getNeighbors()) {
    if (neighbor.getIsActive()) {
      if (!path.contains(neighbor)) {
        path.add(neighbor);
        
        node.parent = neighbor;
        
        int temp = idaSearch(path, g + 1, bound, er, ec);
        
        if (temp == FOUND) {
          return FOUND; 
        }
        
        if (temp < min) {
          min = temp;
        }
        
        path.remove(neighbor);
      }
    }
  }
  
  return min;
}

// Display score at bottom left
private void displayScore() {
  textAlign(LEFT);
  textSize(12);
  fill(WHITE);
  
  text("Score " + SCORE, (-WIDTH / 2) + INCREMENT, (700 / 2) - INCREMENT); 
}

private void displayMode() {
  int mode = game.getMode();
  String output;
  
  if (mode == CHASING) {
    output = "Chasing"; 
  } else if (mode == FRIGHTENED) {
    output = "Frightened"; 
  } else {
    output = "Scatter";
  }
  
  textAlign(LEFT);
  text("Mode: " + output, (-WIDTH / 2) + INCREMENT, (700 / 2));
}

// Display algorithm at bottom right
private void displayAlgorithmUsed() {
  textAlign(RIGHT);
  if (USE_IDA) {
    text("Using IDA*", (WIDTH / 2) - INCREMENT, (700 / 2) - INCREMENT);
  } else {
    text("Using A*", (WIDTH / 2) - INCREMENT, (700 / 2) - INCREMENT); 
  } 
}
