clear all; close all; clc;

%% ===================== INPUT =====================
load("sonido_motor_1.mat");   % loads x
Fs = 44100;

x = x(:);
x = x - mean(x);

%% ===================== STFT SETUP =====================
M       = 2048;
overlap = round(0.75*M);
nfft    = 4*M;

%% ===================== RAW SPECTROGRAM =====================
figure('Name','RAW Spectrogram','Color','w');
spectrogram(x, hanning(M), overlap, nfft, Fs, 'yaxis');
colormap(jet);
ylim([0 5]); % kHz (because 'yaxis' mode)
title('RAW audio spectrogram (before filtering)');
xlabel('Time [s]');
ylabel('Frequency [kHz]');

%% ===================== FILTER (ZERO-PHASE) =====================
fc_lp = 800;  % Low-pass cutoff [Hz]
[b,a] = butter(6, fc_lp/(Fs/2), 'low');
df = filtfilt(b, a, x);

%% ===================== FILTERED SPECTROGRAM =====================
figure('Name','FILTERED Spectrogram','Color','w');
spectrogram(df, hanning(M), overlap, nfft, Fs, 'yaxis');
colormap(jet);
ylim([0 2]); % kHz
title(sprintf('FILTERED audio spectrogram (Butterworth LP %d Hz, zero-phase)', fc_lp));
xlabel('Time [s]');
ylabel('Frequency [kHz]');

%% ===================== PSD (WELCH) — HARMONICS EVIDENCE =====================
% Plot RAW vs FILTERED PSD to show harmonic structure and filtering effect
figure('Name','Welch PSD','Color','w');
[Pr, fr] = pwelch(x,  hamming(M), overlap, nfft, Fs);
[Pf, ff] = pwelch(df, hamming(M), overlap, nfft, Fs);

plot(fr, 10*log10(Pr + 1e-18), 'LineWidth', 1.2); hold on; grid on;
plot(ff, 10*log10(Pf + 1e-18), 'LineWidth', 1.2);
xlabel('Frequency [Hz]');
ylabel('PSD [dB/Hz]');
title('Welch PSD (RAW vs FILTERED) — harmonic content visibility');
legend('RAW', 'FILTERED (LP)', 'Location', 'best');
xlim([0 10000]); % adjust if you want to see higher harmonics

%% ===================== SPECTROGRAM (FILTERED) FOR TRACKING =====================
[S, F, T] = spectrogram(df, hanning(M), overlap, nfft, Fs);
Mag = abs(S);

%% ===================== FUNDAMENTAL RIDGE TRACKING =====================
fmin = 60;
fmax = 450;

band = (F >= fmin & F <= fmax);
Fb = F(band);
Mb = Mag(band,:);

trackBW_Hz = 25;
f_track = zeros(1, numel(T));

[~, i0] = max(Mb(:,1));
f_track(1) = Fb(i0);

for k = 2:numel(T)
    f_prev = f_track(k-1);
    idxLocal = find(Fb >= (f_prev-trackBW_Hz) & Fb <= (f_prev+trackBW_Hz));
    if isempty(idxLocal)
        [~, ik] = max(Mb(:,k));
        f_track(k) = Fb(ik);
    else
        [~, imax] = max(Mb(idxLocal,k));
        f_track(k) = Fb(idxLocal(imax));
    end
end

f_med    = medfilt1(f_track, 11);
f_smooth = movmean(f_med, 9);

%% Plot tracked fundamental over time
figure('Name','Tracked Fundamental (Smoothed)','Color','w');
plot(T, f_smooth, 'LineWidth', 1.6); grid on;
xlabel('Time [s]');
ylabel('Tracked frequency [Hz]');
title('Tracked fundamental frequency (median + moving average smoothing)');

%% ===================== TAU ESTIMATION (FIXED t0) =====================
% ====== KEY SETTINGS ======
tA = 12;            % window start [s]
tB = 16;            % window end   [s]
t0 = 12.8987;       % step instant [s] (set manually)
% =========================

maskW = (T >= tA & T <= tB);
Tw = T(maskW);
fw = f_smooth(maskW);

if ~(t0 >= tA && t0 <= tB)
    error('t0 is outside the selected window [tA, tB].');
end

% Steady levels (adjust if needed)
preWin  = [t0-0.6, t0-0.15];  % before step
postWin = [t0+0.9, tB-0.2];   % after step

f0 = median(fw(Tw>=preWin(1)  & Tw<=preWin(2)));
ff_ = median(fw(Tw>=postWin(1) & Tw<=postWin(2)));

% 63% method
f63 = f0 + 0.632*(ff_ - f0);
idx_tau = find(Tw >= t0 & fw >= f63, 1, 'first');
tau_63 = Tw(idx_tau) - t0;

fprintf('t0 = %.4f s\n', t0);
fprintf('f0 = %.2f Hz, ff = %.2f Hz\n', f0, ff_);
fprintf('tau_63 = %.4f s\n', tau_63);

% Grid LS exponential fit (robust)
fit_end  = min(tB, t0 + 2.0);
fit_mask = (Tw >= t0) & (Tw <= fit_end);
tt = Tw(fit_mask) - t0;
yy = fw(fit_mask);

tau_grid = linspace(0.01, 0.50, 700);
err = zeros(size(tau_grid));

for k = 1:numel(tau_grid)
    tau = tau_grid(k);
    yhat = ff_ - (ff_ - f0)*exp(-tt/tau);
    err(k) = mean((yy - yhat).^2);
end

[~, kbest] = min(err);
tau_fit = tau_grid(kbest);

fprintf('tau_fit (LS) = %.4f s\n', tau_fit);

%% Plot tau estimation window
figure('Name','Tau Estimation Window','Color','w');
plot(Tw, fw, 'm', 'LineWidth', 2); grid on; hold on;
xline(t0, '--k', 't0');
yline(f63, '--', '63%');
plot(Tw(idx_tau), fw(idx_tau), 'ko', 'MarkerFaceColor', 'k');
xlabel('Time [s]');
ylabel('Frequency [Hz]');
title(sprintf('Tau63 = %.3f s | TauFit (LS) = %.3f s', tau_63, tau_fit));