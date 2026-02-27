#include <Arduino.h>
#include <Servo.h>

const int PIN_ESC = 5;

const int PWM_MIN  = 1000;  // apagado / idle
const int PWM_BASE = 1200;  // 0–5s y 10–15s
const int PWM_STEP = 1400;  // 5–10s

const unsigned long T_TOTAL    = 15000;
const unsigned long T_STEP_ON  = 5000;
const unsigned long T_STEP_OFF = 10000;

// Rampa de arranque para evitar hunting cerca del umbral
const unsigned long T_RAMP_MS  = 800; // 0.8s (ajusta 500–1200ms)

Servo esc;
unsigned long t0 = 0;

static inline int rampToBase(unsigned long t_ms) {
  if (t_ms >= T_RAMP_MS) return PWM_BASE;
  long num = (long)(PWM_BASE - PWM_MIN) * (long)t_ms;
  long den = (long)T_RAMP_MS;
  return PWM_MIN + (int)(num / den);
}

void setup() {
  Serial.begin(115200);

  esc.attach(PIN_ESC, PWM_MIN, 2000);

  // Armado ESC
  esc.writeMicroseconds(PWM_MIN);
  delay(5000);

  // Parte automáticamente
  t0 = millis();
}

void loop() {
  unsigned long t = millis() - t0;

  int pwm;
  if (t < T_STEP_ON) {
    // 0–5s: base, pero con rampa solo al inicio para que arranque estable
    pwm = (t < T_RAMP_MS) ? rampToBase(t) : PWM_BASE;
  }
  else if (t < T_STEP_OFF) {
    // 5–10s: escalón
    pwm = PWM_STEP;
  }
  else if (t < T_TOTAL) {
    // 10–15s: vuelve a base
    pwm = PWM_BASE;
  }
  else {
    // >15s: apaga y queda detenido
    esc.writeMicroseconds(PWM_MIN);
    while (1) delay(1000);
  }

  esc.writeMicroseconds(pwm);
}