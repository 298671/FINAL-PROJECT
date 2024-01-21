
fig = figure;

% Create a button
btn = uicontrol('Style', 'pushbutton', 'String', 'Start', 'Position', [100,195,100, 30], 'Callback', @buttonCallback,'BackgroundColor', [1, 0.75, 0.8]);

% Callback function for the button
function buttonCallback(~, ~)
    % Create "Stop" button on the same figure
    stopBtn = uicontrol('Style', 'pushbutton', 'String', 'Stop', 'Position', [400, 195, 100, 30], 'Callback', @stopButtonCallback,'BackgroundColor',[0, 0.8, 0]);

  
    arduinoPort = 'COM6'; 
    arduino = serial(arduinoPort, 'BaudRate', 4800);
    
    % Set up plot
    subplot(2, 1, 1);
    hLine1 = plot(0, 0);
    xlabel('Time');
    ylabel('Analog Voltage (V)');
    title('Real-time Signal from Arduino');
    grid on;

    subplot(2, 1, 2);
    hLine2 = plot(0, 0);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title('Real-time FFT');
    grid on;

   
    fopen(arduino);

   
    bufferSize = 150;
    time = 1:bufferSize;
    data = zeros(1, bufferSize);

    
    sensorVoltageRange = 10;
    adcResolution = 1023;

  
    while ishandle(hLine1)
        fprintf(arduino, 'R');
        rawData = fscanf(arduino, '%d');
        voltageData = (rawData / adcResolution) * sensorVoltageRange;
        data = [data(2:end), voltageData];

        set(hLine1, 'XData', time, 'YData', data);
        ylim([0, sensorVoltageRange]);

        Y = fft(data);
        f = (0:bufferSize-1)*(4800/bufferSize);
        
        set(hLine2, 'XData', f, 'YData', abs(Y));
        xlim([0, 2000]);
        ylim([0, 200]);

        drawnow;
        
    end

    
    fclose(arduino);
    delete(arduino);
    clear arduino;
end

% Callback function for the "Stop" button
function stopButtonCallback(~, ~)
    disp('Stop button clicked!');
    close(gcf); 
end
