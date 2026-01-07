import processing.serial.*;
import java.util.ArrayList;

Serial myPort;

// ===== MPU DATA =====
float ax = 0;
float ay = 0;

// ===== SMOOTHING =====
float axSmooth = 0;
float aySmooth = 0;
float smoothFactor = 0.08;
float deadZoneValue = 1600;

// ===== GRID =====
int cols = 20;
int rows = 20;
int cellSize = 25;

// ===== SNAKE =====
ArrayList<PVector> snake;
PVector direction;
int moveDelay = 180;   // slow = easy
int lastMoveTime = 0;

// ===== FOOD =====
PVector food;

// ===== GAME STATE =====
boolean gameOver = false;
int score = 0;

// ===== DEAD ZONE =====
float deadZone(float v, float dz) {
  if (abs(v) < dz) return 0;
  return v;
}

void setup() {
  size(500, 500);          // ✅ ONLY HERE
  frameRate(60);
  textAlign(CENTER);

  myPort = new Serial(this, "COM4", 115200);
  myPort.bufferUntil('\n');

  resetGame();
}

void resetGame() {
  snake = new ArrayList<PVector>();
  snake.add(new PVector(cols/2, rows/2));
  direction = new PVector(1, 0);
  spawnFood();
  score = 0;
  gameOver = false;
}

void spawnFood() {
  food = new PVector(int(random(cols)), int(random(rows)));
}

void draw() {
  background(20);

  if (!gameOver) {
    handleTilt();
    updateSnake();
  }

  drawGrid();
  drawFood();
  drawSnake();

  fill(255);
  textAlign(LEFT);
  text("Score: " + score, 10, 20);

  if (gameOver) {
    textAlign(CENTER);
    fill(255, 0, 0);
    textSize(26);
    text("GAME OVER", width/2, height/2);
    textSize(16);
    fill(255);
    text("Press R to restart", width/2, height/2 + 30);
  }
}

// ===== TILT → DIRECTION =====
void handleTilt() {
  float axF = deadZone(ax, deadZoneValue);
  float ayF = -deadZone(ay, deadZoneValue);

  axSmooth = lerp(axSmooth, axF, smoothFactor);
  aySmooth = lerp(aySmooth, ayF, smoothFactor);

  if (abs(axSmooth) > abs(aySmooth)) {
    if (axSmooth > 0 && direction.x != -1) direction.set(1, 0);
    if (axSmooth < 0 && direction.x != 1)  direction.set(-1, 0);
  } else {
    if (aySmooth > 0 && direction.y != -1) direction.set(0, 1);
    if (aySmooth < 0 && direction.y != 1)  direction.set(0, -1);
  }
}

// ===== MOVE SNAKE =====
void updateSnake() {
  if (millis() - lastMoveTime < moveDelay) return;
  lastMoveTime = millis();

  PVector head = snake.get(0);
  PVector newHead = new PVector(head.x + direction.x, head.y + direction.y);

  // Wall collision
  if (newHead.x < 0 || newHead.x >= cols || newHead.y < 0 || newHead.y >= rows) {
    gameOver = true;
    return;
  }

  // Self collision
  for (PVector s : snake) {
    if (s.equals(newHead)) {
      gameOver = true;
      return;
    }
  }

  snake.add(0, newHead);

  if (newHead.equals(food)) {
    score++;
    spawnFood();
  } else {
    snake.remove(snake.size() - 1);
  }
}

// ===== DRAWING =====
void drawGrid() {
  stroke(40);
  for (int i = 0; i <= cols; i++) line(i * cellSize, 0, i * cellSize, height);
  for (int j = 0; j <= rows; j++) line(0, j * cellSize, width, j * cellSize);
}

void drawSnake() {
  noStroke();
  fill(0, 200, 255);
  for (PVector s : snake) {
    rect(s.x * cellSize, s.y * cellSize, cellSize, cellSize);
  }
}

void drawFood() {
  fill(255, 80, 80);
  rect(food.x * cellSize, food.y * cellSize, cellSize, cellSize);
}

// ===== SERIAL =====
void serialEvent(Serial myPort) {
  String data = myPort.readStringUntil('\n');
  if (data != null) {
    String[] v = split(trim(data), ',');
    if (v.length == 3) {
      ax = float(v[0]);
      ay = float(v[1]);
    }
  }
}

// ===== RESTART =====
void keyPressed() {
  if (key == 'r' || key == 'R') resetGame();
}
