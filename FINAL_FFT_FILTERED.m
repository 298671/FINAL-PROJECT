% Create a figure window
fig = figure('Position', [100, 100, 600, 400], 'Name', 'Real-time Signal and FFT');

% Create a "Start" button
startButton = uicontrol('Style', 'pushbutton', 'String', 'Start', 'Position', [100,185,100, 30], 'Callback', @startCallback,'BackgroundColor', [1, 1, 0]);

% Create a "Stop" button
stopButton = uicontrol('Style', 'pushbutton', 'String', 'Stop', 'Position', [400, 185, 100, 30], 'Callback', @stopCallback,'BackgroundColor', [1, 0.65, 0]);

% Callback function for the "Start" button
function startCallback(~, ~)
    disp('Start button clicked!');
    
    % Prompt user for filter order (n)
    prompt = 'Enter the filter order (n):';
    dlgTitle = 'Filter Order';
    defaultAnswer = ''; % Default value
    n = str2double(inputdlg(prompt, dlgTitle, [1 40], {defaultAnswer}));
    
    % Call your existing code with the user-defined filter order
    runYourCode(n);
end

% Callback function for the "Stop" button
function stopCallback(~, ~)
    disp('Stop button clicked!');
    
    % Close the figure
    delete(gcf); % Use gcf to refer to the current figure
end

% Your existing code function with a modified function signature
function runYourCode(n)
    % Butterworth filter design using user-defined filter order (n)
    Wn = 0.6; % Normalized cutoff frequency
    [b, a] = butter(n, Wn);

    % Arduino setup
    arduinoPort = 'COM6'; % Change this to your Arduino port
    arduino = serial(arduinoPort, 'BaudRate', 4800);

    % Voltage range of the sensor
    voltageRange = 10; % Adjust this based on your sensor specifications

    % Set up plot
    subplot(2,1,1);
    hLine = plot(0, 0,'LineWidth',2);
    xlabel('Time');
    ylabel('Voltage');
    title('Real-time Signal from Arduino');
    grid on;

    subplot(2,1,2);
    hFFTLine = plot(0, 0,'LineWidth',2);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    title('Real-time FFT');
    grid on;

    % Set up serial communication
    fopen(arduino);

    % Set up variables
    bufferSize = 250;
    time = 1:bufferSize;
    data = zeros(1, bufferSize);

    % Main loop for real-time data acquisition
    while ishandle(hLine)
        % Read data from Arduino
        fprintf(arduino, 'R'); % Request data from Arduino
        rawData = fscanf(arduino, '%d'); % Read the incoming data

        % Convert raw data to voltage
        voltageData = (rawData / 1023) * voltageRange;

        % Update data buffer
        data = [data(2:end), voltageData];

        % Apply Butterworth filter
        filteredData = filter(b, a, data);

        % Update real-time signal plot
        subplot(2,1,1);
        set(hLine, 'XData', time, 'YData', filteredData);
        ylim([0, voltageRange]);

        % Compute and plot real-time FFT directly on the acquired data
        fftData = fft(filteredData);
        fftData = abs(fftData(1:bufferSize/2));
        frequency = (0:(bufferSize/2)-1) * (1500/(bufferSize/2)); % Assuming a sampling rate of 4800 Hz
        subplot(2,1,2);
        set(hFFTLine, 'XData', frequency, 'YData', fftData);
        customYLim = [0, max(fftData) * 0.2];
        ylim(customYLim);
        
        drawnow;
    end

    % Close serial connection
    fclose(arduino);
    delete(arduino);
    clear arduino;
end
