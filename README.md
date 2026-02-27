# 🛩️ DIY UAV Motor System Identification (Rotational Model Component)
### Brushless Motor Time Constant (τ) Estimation via Acoustic Spectral Ridge Tracking  
**CrissCCL – Applied Control & Embedded Engineering**

<!-- Badges -->
![MATLAB](https://img.shields.io/badge/MATLAB-R2020%2B-orange)
![Teensy](https://img.shields.io/badge/Teensy-Step%20Generator-3949ab)
![UAV](https://img.shields.io/badge/UAV-Rotational%20Dynamics-1e88e5)
![System%20ID](https://img.shields.io/badge/System%20Identification-First--Order%20Motor%20Lag-8e24aa)
![Signal%20Processing](https://img.shields.io/badge/Signal%20Processing-STFT%20%7C%20Welch-00897b)
![Status](https://img.shields.io/badge/Status-Validated%20Bench%20Test-brightgreen)
![License](https://img.shields.io/badge/License-MIT-black)


## 📌 Role Within the UAV Rotational Model

This repository contributes to the **rotational dynamic modeling of the UAV**.

Specifically, it identifies the **motor–ESC dynamic lag (τ)**, which is a critical component of the propulsion subsystem and directly affects:

- Roll, pitch, and yaw rate response
- Inner rate loop bandwidth
- Phase margin and stability
- Transient torque generation

The motor time constant becomes part of the rotational plant model:

$$
G_{motor}(s) = \frac{1}{\tau s + 1}
$$

## 📂 Contents
- `/Scripts` → New Version schematic, Gerbers and BOM+POS for PCBA.
- `/exp_motor` → C code for Arduino/Teensy.

## 🔎 Key Figures

### Spectrogram + Ridge Tracking
![Spectrogram Ridge](docs/images/cover_spectrogram_ridge.png)

### Step Window + Time Constant Estimation
![Tau Fit](docs/images/cover_tau_fit.png)


## 🧠 Modeling Assumption

The dominant acoustic frequency is assumed proportional to rotor angular speed:

$$
f(t) \propto \omega(t)
$$

Under a throttle step:

$$
f(t)=f_\infty-(f_\infty-f_0)e^{-(t-t_0)/\tau}
$$

Two estimation methods are implemented:

- **Tau63 (63% crossing method)**
- **Grid-based Least Squares exponential fit**


## 🛠 System Identification Pipeline

1. Controlled throttle step (Teensy)
2. Audio acquisition in MATLAB (44.1 kHz)
3. DC removal and zero-phase low-pass filtering
4. STFT spectrogram computation
5. Band-limited ridge tracking
6. Median + moving average smoothing
7. Time constant estimation

## 📊 Relevance to UAV Rotational Dynamics

The complete rotational axis model can be approximated as:

$$
G_{axis}(s) = \frac{K}{(\tau s + 1)(J s)}
$$

Where:
- $$J$$ = axis inertia
- $$\tau$$ = motor lag
- $$K$$ = control effectiveness

The motor time constant introduces:

- Additional phase lag
- Bandwidth limitation
- Torque response delay

A practical engineering guideline:

$$
\omega_{BW} \ll \frac{1}{\tau}
$$
to preserve stability margins.

## 📊 Numerical Example (Identified Case)

For the identified motor time constant:
$$
\tau = 0.17 \text{ s}
$$

The motor pole is located at:

$$
\omega_m = \frac{1}{\tau} = 5.88 \text{ rad/s}
$$

Equivalent frequency:

$$
f_m \approx 0.94 \text{ Hz}
$$

### Practical Bandwidth Guideline

To maintain sufficient phase margin:

$$
\omega_{BW} \lesssim \frac{1}{2\tau}
$$

$$
\omega_{BW} \lesssim 2.9 \text{ rad/s}
$$

This provides a conservative design bound for inner rate loop tuning.

Higher bandwidth values are possible but require careful gain selection and derivative filtering.


## 📈 Engineering Implications

Including τ in the plant model enables:

- Realistic controller tuning
- Accurate simulation of transient behavior
- Conservative and stable bandwidth selection
- Improved feedforward compensation design

Ignoring motor lag leads to:

- Overestimated achievable bandwidth
- Reduced phase margin
- Oscillatory response in real flight

## ▶️ Quick Start

### Record Audio
```matlab
01_record_audio.m
```

## Process and Estimate τ
```matlab
02_process_audio_tau.m
```
##🔗 Integration with Flight Controller

The identified motor lag model is directly integrated into:

- Rate loop tuning
- Simulation environment
- Embedded discrete-time controller design

## 🤝 Support projects
 Support me on Patreon [https://www.patreon.com/c/CrissCCL](https://www.patreon.com/c/CrissCCL)

## 📜 License
MIT License  
