% Define parameters
Fs = 192000;        % Sampling frequency (sampling rate)
Fc1 = 40000;        % Carrier frequency of the first signal
Fc2 = 75000;        % Carrier frequency of the second signal
nChannels = 1;      % Number of channels (1 for mono audio)
nBits = 16;         % Number of bits per sample
recDuration = 5;    % Record for 5 seconds
gain = 2;           % Amplifier gain

% Record the input audio signals and plot them in time domain
r1 = audiorecorder(Fs, nBits, nChannels);
disp('Recording started for the first signal');
recordblocking(r1, recDuration);
disp('Recording stopped for the first signal');
x1 = getaudiodata(r1);      % First audio signal

tSubplot(1, 1, 2, 1, Fs, x1, "Audio 1 (Time Domain)")
sound(x1, Fs);
pause(7);

r2 = audiorecorder(Fs, nBits, nChannels);
disp('Recording started for the second signal');
recordblocking(r2, recDuration);
disp('Recording stopped for the second signal');
x2 = getaudiodata(r2);      % Second audio signal

tSubplot(1, 1, 2, 2, Fs, x2, "Audio 2 (Time Domain)")
sound(x2, Fs);
pause(7);

% Find the frequency domain representation of the signal
X1 = fftshift(fft(x1));     
X2 = fftshift(fft(x2));

% Plot the input signals in frequency domain
fSubplot(2, 1, 2, 1, Fs, X1, "Audio 1 (Frequency Domain)")
fSubplot(2, 1, 2, 2, Fs, X2, "Audio 2 (Frequency Domain)")
pause(3);

% Modulate the input singals
y1 = ammod(x1, Fc1, Fs);        % Modulation of signal 1
y2 = ammod(x2, Fc2, Fs);        % Modulation of signal 2
y = y1 + y2;                    % Summation of the two modulated signals for transmission

% Calculate the Fast Fourier Transform of modulated signals
Y1 = fftshift(fft(y1));     
Y2 = fftshift(fft(y2));
Y = fftshift(fft(y));

% Plot the modulated signals
fSubplot(3, 1, 3, 1, Fs, Y1, "Modulated Audio 1 (Freq)")
fSubplot(3, 1, 3, 2, Fs, Y2, "Modulated Audio 2 (Freq)")
fSubplot(3, 1, 3, 3, Fs, Y, "Transmission Signal (Freq)")
pause(3);

% Amplify the transmission signal
y_amp = y * gain;

% Select the desired signal
switch_pos = 0;                 % Switch position (0 or 1)
if switch_pos == 0
    f0 = Fc1;
else
    f0 = Fc2;
end
y_select = bandpass(y_amp, [f0-10000 f0+10000], Fs);

% Demodulate the selected signal
y_demod = amdemod(y_select, f0, Fs);                % Demodulated signal

% Filter, amplify and play the output signal
y_output = y_demod * gain;      % Amplified output audio signal
sound(y_output, Fs);            % Play signal through speaker
Y_output = fftshift(fft(y_output));
tSubplot(4, 1, 2, 1, Fs, y_output, "Output Signal (Time)")
fSubplot(4, 1, 2, 2, Fs, Y_output, "Output Signal (Freq)")

% Creating subplot for the given parameters
function tSubplot(fig_num, height, width, position, a, b, Title)
    t = linspace(0, length(b)/a, length(b));
    figure(fig_num)
    subplot(height, width, position)
    plot(t, b)
    title(Title)
    xlabel('time')
    ylabel('amplitude')
end

function fSubplot(fig_num, height, width, position, a, b, Title)
    f = linspace(-a/2, a/2, length(b));
    figure(fig_num)
    subplot(height, width, position)
    plot(f, abs(b))
    xlim([-a/2 a/2])
    title(Title)
    xlabel('frequency')
    ylabel('amplitude')
end