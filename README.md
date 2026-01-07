# Tilt-Controlled Snake Game 🎮🐍

A Snake game controlled by tilting an MPU6050 sensor connected to an ESP32.
The ESP32 sends motion data over Serial, and Processing renders the game.

## Hardware Required
- ESP32
- MPU6050
- USB cable (data cable)
- Computer with USB port

## Software Required
- Arduino IDE
- Processing

## Setup Steps

## Pin Connections (ESP32 ↔ MPU6050)

The project uses I2C communication.

| MPU6050 | ESP32 |
|--------|-------|
| VCC | 3.3V |
| GND | GND |
| SDA | GPIO 21 |
| SCL | GPIO 22 |

Notes:
- ESP32 default I2C pins are used (Wire.begin()).
- AD0 is left unconnected (I2C address = 0x68).
- INT pin is not used.

### 1. Upload Arduino Code
- Open `arduino/esp32_mpu_serial.ino` in Arduino IDE
- Select correct ESP32 board and COM port
- Upload the sketch
- Close Arduino IDE

### 2. Run the Game
- Open `processing/TiltSnake.pde` in Processing
- Update COM port if needed (e.g., COM4)
- Click Run

## Controls
- Tilt left/right → snake turns left/right
- Tilt forward/back → snake moves up/down

## Notes
- Only one program can use the COM port at a time
- Close Arduino Serial Monitor before running Processing
