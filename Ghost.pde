abstract class Ghost {
  public int row, col;
  public PVector posn;
  public ArrayList<Node> path;
  protected PVector orientation;
  protected int appearanceTimer;
  protected float alpha;
  protected int mode;
  private boolean isActive;
  private boolean isReturning;
  protected float speed;
  protected int desiredScatterR, desiredScatterC;
  
  public Ghost() {
    this.appearanceTimer = 0;
    this.alpha = 200;
    this.path = new ArrayList();
    this.mode = CHASING;
    this.isActive = false;
    this.isReturning = false;
    this.speed = 1;
  }
 
  public abstract void createPath();
  
  protected void scatter() {
    this.createPathToDesiredCorner();
    this.chase();
  }
  
  protected abstract void createPathToDesiredCorner();
  
  public void setSpeed(float s) {
    this.speed = s; 
  }
  
  public float getSpeed() {
    return this.speed;
  }
  
  public void render(color c, PShape svg) {    
    if (this.mode == FRIGHTENED) {
      if (this.isReturning) {
        if (USE_VIZ) {
          shape(ghostEyesSvg, this.posn.x, this.posn.y, INCREMENT + 5, INCREMENT + 5);
        } else {
          fill(c, 70);
          stroke(c, this.alpha); 
        }
      } else {
        // Change ghost appearance
        if (floor(game.timer / 30) % 2 == 0) { 
          if (USE_VIZ) {
            shape(frightenedGhost1, this.posn.x, this.posn.y, INCREMENT + 5, INCREMENT + 5);
          } else {
            fill(WHITE, this.alpha);
            stroke(WHITE); 
          }
        } else {
          if (USE_VIZ) {
            shape(frightenedGhost2, this.posn.x, this.posn.y, INCREMENT + 5, INCREMENT + 5);
          } else {
            fill(BLUE, this.alpha);
            stroke(BLUE); 
          }
        } 
      }
    } else {
      if (this.isReturning) {
        if (USE_VIZ) {
          shape(ghostEyesSvg, this.posn.x, this.posn.y, INCREMENT + 5, INCREMENT + 5);
        } else {
          fill(c, 70);
          stroke(c, this.alpha); 
        }
      } else {
        if (USE_VIZ) {
          shape(svg, this.posn.x, this.posn.y, INCREMENT + 5, INCREMENT + 5);
        } else {
          fill(c, this.alpha);
          stroke(c);  
        }
      }
    }
    
    if (!USE_VIZ) {
      strokeWeight(2);
    
      rect(this.posn.x, this.posn.y, INCREMENT, INCREMENT, INCREMENT, INCREMENT, 2, 2);
     
      strokeWeight(3); 
    }
    
    if (SHOW_PATHS) {
      for (Node n : this.path) {
        if (this.isReturning) {
          n.renderPath(c, 70);
        } else {
          n.renderPath(c, this.alpha / 1.5); 
        }
      } 
    }
  }
  
  public void setInitialScatterDest() {
    if (USE_IDA) {
      this.path = idaStar(this.row, this.col, this.desiredScatterR, this.desiredScatterC);
    } else {
      this.path = aStar(this.desiredScatterR, this.desiredScatterC, this.row, this.col); 
    }
  }
  
  protected void move() {
    if (!this.getIsActive()) {
      this.setIsActive(true); 
    }
    
    if (this.mode == CHASING) {
      if (!this.isReturning) {
        this.createPath(); 
      }
      this.chase();
    } else if (this.mode == FRIGHTENED) {
      if (!this.path.isEmpty() && !this.isReturning) {
        this.path.clear(); 
      }
      
      if (this.isReturning) {
        this.createPathToStart();
        this.chase();
      } else {
        this.moveRandomly(); 
      }
      
    } else if (this.mode == SCATTER) {
      this.scatter();
    }
  }
  
  // Movement for "chase" mode
  protected void chase() {
    for (int i = 0; i < this.path.size() - 1; i++) {
      if (this.path.get(i).x == this.posn.x && this.path.get(i).y == this.posn.y) {
        Node next = this.path.get(i + 1);
        
        float x = 0;
        float y = 0;
        
        if (next.x < this.posn.x) {
          x = -(this.speed);
          this.col--;
        } else if (next.x > this.posn.x) {
          x = this.speed;
          this.col++;
        }
        
        if (next.y < this.posn.y) {
          y = -(this.speed);
          this.row--;
        } else if (next.y > this.posn.y) {
          y = this.speed;
          this.row++;
        }
        
        this.orientation = new PVector(x, y);
        
        break;
      }
    }
    
    this.posn.add(this.orientation);
    
    if (this.isBackAtStart() && this.isReturning) {
      this.isReturning = false;
      this.mode = CHASING; 
      this.speed = 1;
    }
    
    if (this.didHitPacman()) {
      if ((this.mode == FRIGHTENED && !this.isReturning) || this.mode == CHASING || this.mode == SCATTER) {
        game.pacman.reset();
        LIVES--;
        
        if (this.mode == CHASING) {
          game.setMode(SCATTER);
          game.setGhostsMode(SCATTER);
        }
      }
    }
  }
  
  // Frightened mode behavior
  protected void moveRandomly() {    
    if (this.isOnTurnBlock() || this.isOnEatenTurnBlock()) {
      this.orientation = this.getRandomDir();
    }
    
    this.posn.add(this.orientation);
  
    if (this.isOnCell()) {
      this.row = convertYtoR((int) this.posn.y);
      this.col = convertXtoC((int) this.posn.x);
    }
    
    if (this.didHitPacman()) {
      if (!this.isReturning) {
        SCORE += 10;
        this.isReturning = true;
        this.speed = 2;
        this.clampPosn();
      }
    }
  }
  
  protected void createPathToStart() {
    if (USE_IDA) {
      this.path = idaStar(this.row, this.col, 13, 13); 
    } else {
      this.path = aStar(13, 13, this.row, this.col);
    }
  }
  
  // Generate a random orientation
  private PVector getRandomDir() {
    float rand = random(0, 4);
    float vx = 0;
    float vy = 0;
    
    switch (Math.round(rand)) {
      case 0:
        vy = -(this.speed);
        break;
      case 1:
        vx = this.speed;
        break;
      case 2:
        vy = this.speed;
        break;
      case 3:
        vx = -(this.speed);
        break;
    }
    
    Cell cell = game.board.getCellAt(this.row + ((int) vy), this.col + ((int) vx));
    
    while (cell.isWall() || (vx == 0 && vy == 0)) {
      rand = random(0, 4);
      vx = 0;
      vy = 0;
      
      switch (Math.round(rand)) {
        case 0:
          vy = -(this.speed);
          break;
        case 1:
          vx = this.speed;
          break;
        case 2:
          vy = this.speed;
          break;
        case 3:
          vx = -(this.speed);
          break;
      }
      
      cell = game.board.getCellAt(this.row + ((int) vy), this.col + ((int) vx));
    }
    
    return new PVector(vx, vy);
  }
  
  protected void setIsActive(boolean a) {
    this.isActive = a; 
  }
  
  protected boolean getIsActive() {
    return this.isActive; 
  }
  
  protected boolean isAtDesiredScatterPosn() {
    return this.row == this.desiredScatterR && this.col == this.desiredScatterC; 
  }
  
  private boolean isBackAtStart() {
    return this.row == 13 && this.col == 13 && this.isReturning; 
  }
  
  private boolean isOnTurnBlock() {
    if (!this.isOnCell()) {
      return false; 
    }
    
    return game.board.getCellAt(this.row, this.col).isTurnBlock();
  }
  
  private boolean isOnEatenTurnBlock() {
    if (!this.isOnCell()) {
      return false; 
    }
    
    return game.board.getCellAt(this.row, this.col).isEatenTurnBlock();
  }
  
  /*
  [X][C][X]
  [C][G][C]
  [X][C][X]
  */
  private Cell[][] getNearby() {
    Cell[][] nearby = new Cell[3][3];
    
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        nearby[i][j] = null; 
      }
    }
    
    if (this.row - 1 > 0) {
      nearby[0][1] = game.board.getCellAt(this.row - 1, this.col);
    }
    
    if (this.row + 1 < game.board.numRows) {
      nearby[2][1] = game.board.getCellAt(this.row + 1, this.col);
    }
    
    if (this.col - 1 > 0) {
      nearby[1][0] = game.board.getCellAt(this.row, this.col - 1);
    }
    
    if (this.col + 1 < game.board.numCols) {
      nearby[1][2] = game.board.getCellAt(this.row, this.col + 1);
    }
    
    return nearby;
  }
  
  public boolean isMovingRight() {
    return this.orientation.x == this.speed; 
  }
  
  public boolean isMovingLeft() {
    return this.orientation.x == -(this.speed); 
  }
  
  public boolean isMovingUp() {
    return this.orientation.y == -(this.speed); 
  }
  
  public boolean isMovingDown() {
    return this.orientation.y == this.speed; 
  }
  
  public boolean isOnCell() {
    return (Math.abs(this.posn.x - game.board.initX) % INCREMENT == 0
    && Math.abs(this.posn.y - game.board.initY) % INCREMENT == 0);
  }
  
  public boolean didHitPacman() {
    return this.row == game.pacman.row && this.col == game.pacman.col; 
  }
  
  // Used when ghosts exit "frightened" mode in order to reset posn to use A* or IDA*
  public void clampPosn() {
    if (!this.isOnCell()) {
      int x = convertCtoX(this.col);
      int y = convertRtoY(this.row);
      
      this.posn = new PVector(x, y);
    }
  }
  
  public void setMode(int m) {
    this.mode = m;
    
    if (this.isReturning) {
      this.speed = 2;
    } else {
      this.speed = 1; 
    }
  }
}
