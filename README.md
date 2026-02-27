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


## 🔗 Part of the Main UAV Project

This repository is a dedicated **propulsion dynamics identification module** for the complete DIY UAV platform.

It is a submodule of the main UAV project:

👉 **DIY_UAV (main repository)**  
🔗 https://github.com/CrissCCL/DIY_UAV

Within the full UAV architecture, this module provides:

- Experimental motor–ESC lag estimation (τ)
- Rotational plant modeling component
- Basis for rate loop bandwidth design
- Realistic simulation plant integration

## 📌 Role Within the UAV Rotational Model

This repository contributes to the **rotational dynamic modeling of the UAV**.

It experimentally identifies the **motor–ESC dynamic lag (τ)**, which directly affects:

- Roll, pitch and yaw rate response  
- Inner rate loop bandwidth  
- Phase margin and stability  
- Transient torque generation  

The motor dynamics are modeled as:

$$
G_{motor}(s) = \frac{1}{\tau s + 1}
$$


## 📂 Repository Structure

- `/Scripts` → MATLAB acquisition and processing scripts  
- `/exp_motor` → Teensy PWM step generator firmware  


## 🔬 Experimental Hardware Setup

![Motor Bench Setup](docs/images/motor_bench_setup.jpg)

> Test performed with 1045 propeller installed to capture real aerodynamic load dynamics.

Brushless motor mounted on bench test configuration during acoustic identification.
Microphone positioned at fixed distance to ensure repeatability.

### 🎤 Acoustic Sensor
- **Microphone:** HyperX QuadCast (USB condenser microphone)
- Fixed distance positioning
- Ambient noise controlled environment

### ⚙️ Propulsion System
- **Brushless Motor:** 2212 – 920 kV
- **ESC:** 30A
- Hover reference PWM: 1400 µs (≈ 40% RC throttle)
- Step excitation: 1200 → 1400 µs

### 🧠 Step Generator
- **Controller:** Teensy (PWM deterministic step generator)
- No hardware logging (time reference defined in MATLAB)


### 📐 Identified Result

Motor time constant:

$$
\tau = 0.17 \text{ s}
$$

This value is integrated into the rotational axis models:

$$
G_p(s), \quad G_q(s), \quad G_r(s)
$$

# 🔬 System Identification

## 🛠 Identification Pipeline

1. Deterministic throttle step (Teensy)
2. Audio acquisition in MATLAB (44.1 kHz)
3. DC removal and zero-phase low-pass filtering
4. STFT spectrogram computation
5. Band-limited ridge tracking (60–450 Hz)
6. Median + moving average smoothing
7. Time constant estimation (Tau63 + LS fit)


## 🔎 Key Figures

### RAW vs FILTERED Spectrogram
<table>
  <tr>
    <td align="center">
      <img alt="spectrogram raw" src="https://github.com/user-attachments/assets/98d49158-bdcd-41ae-9b5f-1fa50abe36e3" width="520"><br>
      <sub>RAW Spectrogram</sub>
    </td>
    <td align="center">
      <img alt="spectrogram filtered" src="https://github.com/user-attachments/assets/b16b75b0-94f3-4cf7-a909-e504bda3b89e" width="520"><br>
      <sub>Filtered spectrogram</sub>
    </td>
  </tr>
</table>

### Tau Estimation Window

<p align="center">
  <img  alt="tau_est" src="https://github.com/user-attachments/assets/9ebe59d6-c62a-47a2-9ac0-8a4b2d4fc218" width="700">
</p>

## 📊 Power Spectral Density (Harmonic Analysis)

Welch PSD is computed for:

- RAW signal  
- Filtered signal  

This validates:

- Fundamental frequency dominance  
- Harmonic structure visibility  
- Filtering effectiveness  
- Proper tracking band selection  

PSD plot example:

<p align="center">
  <img  alt="psd" src="https://github.com/user-attachments/assets/379020fb-0599-47d7-9f66-68b38aa587e7" width="700">
</p>

# 🧮 Identified Rotational Axis Models

Using:

$$
\tau = 0.17 \text{ s}
$$

The identified continuous-time axis models are:

### Roll (p-axis)

$$
G_p(s) = \frac{45.92}{0.17 s^2 + s}
$$

### Pitch (q-axis)

$$
G_q(s) = \frac{56.39}{0.17 s^2 + s}
$$

### Yaw (r-axis)

$$
G_r(s) = \frac{2.232}{0.17 s^2 + s}
$$

Factored form:

$$
G(s) = \frac{K/J}{s(\tau s + 1)}
$$

This explicitly shows:

- Integrator from rigid-body rotational dynamics  
- First-order lag from propulsion system  


# 📐 Physical Interpretation

Denominator:

$$
s(0.17 s + 1)
$$

represents:

- $$s$$ → rotational inertia  
- $$(0.17 s + 1)$$ → motor–ESC lag  

Numerator constants (45.92, 56.39, 2.232) correspond to:

$$
\frac{K}{J}
$$

where:

- $$K=$$ torque per PWM effectiveness  
- $$J=$$ axis inertia  



# 📊 Bandwidth Limitation Due to Motor Lag

Motor pole:

$$
\omega_m = \frac{1}{\tau} = 5.88 \text{ rad/s}
$$

Equivalent frequency:

$$
f_m \approx 0.94 \text{ Hz}
$$

### Conservative Engineering Rule

$$
\omega_{BW} \lesssim \frac{1}{2\tau}
$$

$$
\omega_{BW} \lesssim 2.9 \text{ rad/s}
$$

This defines a safe inner rate-loop bandwidth region.

---

## 📋 Numerical Summary (Identified Case)

| Parameter | Value |
|------------|--------|
| Motor model | 2212 – 920 kV |
| ESC | 30A |
| Hover PWM | 1400 µs |
| Identified τ | 0.17 s |
| Motor pole | 5.88 rad/s |
| Equivalent frequency | 0.94 Hz |
| Conservative BW limit | < 2.9 rad/s |

This summary defines the propulsion dynamic constraint used in the UAV rotational model.

This propulsion identification module directly supports the design of the inner rate control loops implemented in the main DIY_UAV project.

# 🎯 Engineering Impact

Including τ in the plant model ensures:

- Realistic simulation  
- Correct phase margin prediction  
- Controlled bandwidth selection  
- Reduced oscillatory risk  
- Physically consistent tuning  

Ignoring motor lag results in:

- Overestimated bandwidth  
- Reduced stability margin  
- Instability in real flight despite stable simulation  


## ▶️ Quick Start

### Record Audio
```matlab
run("record_audio.m");
```

### Process and Estimate τ
```matlab
run("process_audio_tau.m");
```
🔗 Integration with Flight Controller

The identified motor lag model is directly integrated into:

- Rate loop tuning
- Simulation plant model
- Embedded discrete-time controller design



## 🤝 Support projects
 Support me on Patreon [https://www.patreon.com/c/CrissCCL](https://www.patreon.com/c/CrissCCL)

## 📜 License
MIT License  
