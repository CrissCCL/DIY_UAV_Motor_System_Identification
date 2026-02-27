clear all; close all; clc;

%% ===================== AUDIO RECORDING =====================
Fs        = 44100;   % Sampling frequency [Hz]
nBits     = 16;      % Bit depth
nChannels = 1;       % Mono
ID        = -1;      % Default audio input device

recObj = audiorecorder(Fs, nBits, nChannels, ID);

recDuration = 20;    % Recording duration [s]
recordblocking(recObj, recDuration);
disp("End of recording.");

% Playback (optional)
play(recObj);

% Get recorded audio vector
x = getaudiodata(recObj);
x = x(:);

% Save to MAT file
save("sonido_motor_1.mat", "x");

disp("Saved: sonido_motor_1.mat");