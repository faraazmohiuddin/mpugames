import processing.serial.*;

Serial myPort;

// ===== RAW MPU DATA =====
float ax = 0;
float ay = 0;

// ===== SMOOTHED MPU DATA =====
float axSmooth = 0;
float aySmooth = 0;
float smoothFactor = 0.08;   // lower = smoother

// ===== BALL STATE =====
float ballX = 0;
float ballY = 0;
float ballRadius = 16;

// ===== GAME AREA =====
float circleRadius = 260;   // BIG circle (easy mode)

// ===== PHYSICS (VERY GENTLE) =====
float sensitivity = 0.00012;   // very slow
float friction = 0.997;        // strong damping
float velX = 0;
float velY = 0;

// ===== NOISE HANDLING =====
float deadZoneValue = 1600;

// ===== GAME STATE =====
boolean gameOver = false;
int score = 0;

// ===== DEAD ZONE FUNCTION =====
float deadZone(float v, float dz) {
  if (abs(v) < dz) return 0;
  return v;
}

void setup() {
  size(720, 720);
  textAlign(CENTER);

  myPort = new Serial(this, "COM4", 115200);
  myPort.bufferUntil('\n');

  println("Balance Game — Easy & Smooth Mode");
}

void draw() {
  background(20);

  translate(width/2, height/2);

  // ===== DRAW BALANCE CIRCLE =====
  noFill();
  stroke(0, 200, 255);
  strokeWeight(3);
  ellipse(0, 0, circleRadius * 2, circleRadius * 2);

  if (!gameOver) {

    // ===== FILTER + ORIENTATION FIX =====
    float axFiltered = deadZone(ax, deadZoneValue);
    float ayFiltered = -deadZone(ay, deadZoneValue);  // invert Y

    // ===== SMOOTH INPUT =====
    axSmooth = lerp(axSmooth, axFiltered, smoothFactor);
    aySmooth = lerp(aySmooth, ayFiltered, smoothFactor);

    // ===== PHYSICS UPDATE =====
    velX += axSmooth * sensitivity;
    velY += aySmooth * sensitivity;

    // Limit max speed
    velX = constrain(velX, -3, 3);
    velY = constrain(velY, -3, 3);

    // Damping
    velX *= friction;
    velY *= friction;

    // Auto-stop tiny motion
    if (abs(velX) < 0.02) velX = 0;
    if (abs(velY) < 0.02) velY = 0;

    // Update position
    ballX += velX;
    ballY += velY;

    score++;
  }

  // ===== DRAW BALL =====
  noStroke();
  fill(255, 100, 100);
  ellipse(ballX, ballY, ballRadius * 2, ballRadius * 2);

  // ===== GAME OVER CHECK =====
  float distance = dist(0, 0, ballX, ballY);
  if (distance > (circleRadius - ballRadius) && !gameOver) {
    gameOver = true;
  }

  // ===== UI =====
  resetMatrix();
  fill(255);
  textSize(20);
  text("Easy Mode — Score: " + score, width/2, 40);

  textSize(14);
  text("Smooth • Stable • Learning control", width/2, 65);

  if (gameOver) {
    textSize(30);
    fill(255, 0, 0);
    text("GAME OVER", width/2, height/2);
    textSize(18);
    fill(255);
    text("Press R to Restart", width/2, height/2 + 40);
  }
}

// ===== SERIAL INPUT =====
void serialEvent(Serial myPort) {
  String data = myPort.readStringUntil('\n');
  if (data != null) {
    data = trim(data);
    String[] values = split(data, ',');

    if (values.length == 3) {
      ax = float(values[0]);
      ay = float(values[1]);
    }
  }
}

// ===== RESTART =====
void keyPressed() {
  if (key == 'r' || key == 'R') {
    ballX = 0;
    ballY = 0;
    velX = 0;
    velY = 0;
    score = 0;
    gameOver = false;
  }
}
