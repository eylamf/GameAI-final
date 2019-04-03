class Cell {
  public int type, row, col, x, y;
  
  public Cell(int t, int r, int c, int x, int y) {
    this.type = t;
    this.row = r;
    this.col = c;
    this.x = x;
    this.y = y;
  }
  
  public void render() {
    if (DEBUG) {
      stroke(WHITE);
    } else {
      noStroke(); 
    }
    
    if (this.isWall()) {
      fill(BLUE);
    } else {
      
      if (DEBUG && this.isTurnBlock() || this.isEatenTurnBlock()) {
        fill(WHITE); 
      } else {
        fill(BLACK); 
      }
    }
    
    rect(this.x, this.y, INCREMENT, INCREMENT);
    
    if (this.isPellet() || this.isTurnBlock()) {
      fill(WHITE);
      ellipse(this.x, this.y, 3, 3);
    } else if (this.isFruit()) {
      fill(WHITE);
      ellipse(this.x, this.y, 10, 10);
    }
  }
  
  public boolean isWall() {
    return this.type == WALL; 
  }
  
  public boolean isPellet() {
    return this.type == PELLET; 
  }
  
  public boolean isFruit() {
   return this.type == FRUIT;
  }
  
  public boolean isEmpty() {
    return this.type == EMPTY; 
  }
  
  public boolean isTurnBlock() {
    return this.type == TURN_BLOCK; 
  }
  
  public boolean isEatenTurnBlock() {
    return this.type == 5; 
  }
  
  @Override
  public boolean equals(Object o) {
    if (o == this) return true;
    if (!(o instanceof Cell)) return false;
    
    Cell cell = (Cell) o;
    
    return this.row == cell.row && this.col == cell.col;
  }
  
  @Override
  public int hashCode() {
    return Objects.hash(this.row, this.col); 
  }
}