# 🎙️ UAV Motor Audio-Based System Identification  
### Brushless Motor Time Constant Estimation via Spectral Ridge Tracking  

![MATLAB](https://img.shields.io/badge/MATLAB-R2020%2B-orange)
![Embedded%20Control](https://img.shields.io/badge/Embedded%20Control-UAV%20Flight%20Stack-1e88e5)
![System%20ID](https://img.shields.io/badge/System%20ID-First--Order%20Motor%20Lag-8e24aa)
![STFT](https://img.shields.io/badge/STFT-Spectrogram%20Ridge%20Tracking-00897b)
![Tau](https://img.shields.io/badge/Estimated%20Parameter-%CF%84%20(Time%20Constant)-f4511e)
![Status](https://img.shields.io/badge/Status-Validated%20on%20Bench-brightgreen)
![License](https://img.shields.io/badge/License-MIT-black)

This repository is part of the broader UAV development project and focuses on the **experimental dynamic identification of the propulsion system** using acoustic measurements.

The objective is to estimate the **motor time constant (τ)** by tracking the dominant acoustic frequency during throttle step inputs.

---

## 📌 Project Context (UAV Development)

This work supports:

- Flight controller tuning
- Inner rate loop bandwidth analysis
- Feedforward design
- Simulation model refinement
- ESC–motor dynamic characterization

The identified motor model contributes to the complete UAV dynamic model.

---

## 🔎 Key Results

### Spectrogram + Ridge Tracking
![Spectrogram Ridge](docs/images/cover_spectrogram_ridge.png)

### Step Window + Time Constant Estimation
![Tau Estimation](docs/images/cover_tau_estimation.png)

---

## 🧠 Theoretical Assumption

The dominant acoustic frequency is assumed proportional to motor angular velocity:

$$
f(t) \propto \omega(t)
$$

For a throttle step input:

$$
f(t)=f_\infty - (f_\infty-f_0)\exp\left(-\frac{t-t_0}{\tau}\right)
$$

Two estimation methods are implemented:

- 63% rise-time method (Tau63)
- Grid-based Least Squares exponential fitting


## 🛠 Signal Processing Pipeline

1. Audio acquisition (44.1 kHz)
2. DC removal
3. 6th-order zero-phase Butterworth low-pass filtering
4. STFT spectrogram computation
5. Band-limited ridge tracking
6. Median + moving average smoothing
7. Time constant estimation


## ▶️ Quick Start

### Record Audio
```matlab
run("matlab/01_record_audio.m");
save("matlab/data/sonido_motor_1.mat","x");
```
## Process and Estimate τ

run("matlab/02_process_audio_tau.m");
Export Results
run("matlab/03_export_results.m");

## 📊 Example Experiment

See:

experiments/exp_001_step_1100_1300/

Includes:

- Raw data
- Spectrogram
- Ridge tracking
- Tau estimation
- Parameter summary

##  📈 Relevance to Flight Control

The identified time constant directly affects:

Rate loop bandwidth

Closed-loop stability margins

Motor lag compensation

Transient thrust response

⚠️ Assumptions

- Dominant acoustic frequency represents rotor speed
- First-order approximation is valid locally
- Harmonic dominance does not corrupt ridge tracking


