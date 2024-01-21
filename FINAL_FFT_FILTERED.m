
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
    defaultAnswer = ''; 
    n = str2double(inputdlg(prompt, dlgTitle, [1 40], {defaultAnswer}));
    
   
    runYourCode(n);
end

% Callback function for the "Stop" button
function stopCallback(~, ~)
    disp('Stop button clicked!');
    
    
    delete(gcf); % Use gcf to refer to the current figure
end


function runYourCode(n)
    % Butterworth filter design 
    Wn = 0.6;
    [b, a] = butter(n, Wn);

   
    arduinoPort = 'COM6'; 
    arduino = serial(arduinoPort, 'BaudRate', 4800);

   
    voltageRange = 10; 
    
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

    
    fopen(arduino);

    
    bufferSize = 250;
    time = 1:bufferSize;
    data = zeros(1, bufferSize);

  
    while ishandle(hLine)
        % Read data from Arduino
        fprintf(arduino, 'R'); 
        rawData = fscanf(arduino, '%d'); 

      
        voltageData = (rawData / 1023) * voltageRange;

      
        data = [data(2:end), voltageData];

        % Apply Butterworth filter
        filteredData = filter(b, a, data);

        % Update real-time signal plot
        subplot(2,1,1);
        set(hLine, 'XData', time, 'YData', filteredData);
        ylim([0, voltageRange]);

        % plot real-time FFT 
        fftData = fft(filteredData);
        fftData = abs(fftData(1:bufferSize/2));
        frequency = (0:(bufferSize/2)-1) * (1500/(bufferSize/2)); 
        subplot(2,1,2);
        set(hFFTLine, 'XData', frequency, 'YData', fftData);
        customYLim = [0, max(fftData) * 0.2];
        ylim(customYLim);
        
        drawnow;
    end

  
    fclose(arduino);
    delete(arduino);
    clear arduino;
end
