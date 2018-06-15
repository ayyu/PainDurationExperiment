% Clear workspace
close all;
clearvars;
sca;

% Setup PTB with some default values
PsychDefaultSetup(2);

% Seed random number generator.
rng('default');

% SCREEN SETUP

% Set the screen number to the external secondary monitor if there is one
screenIndex = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenIndex);
black = BlackIndex(screenIndex);
grey = white / 2;

[window, windowRect] = PsychImaging('OpenWindow', screenIndex, black, [], 32, 2);

vbl = Screen('Flip', window);
ifi = Screen('GetFlipInterval', window);

% Set the blend function for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Set process priority
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

waitframes = 1;

% Set the text size
Screen('TextSize', window, 60);
Screen('TextStyle', window, 1);
Screen('TextFont', window, 'Arial');

Rmax = 100;
Rnow = 0;
Tmax = 5;
    Tdelta = 0;
    Tnot = GetSecs;

try
    s = daq.createSession('ni');
    addDigitalChannel(s, 'Dev1', 'Port0/Line0', 'OutputOnly');
catch
    warning('Unable to find NI USB-6501 device.');
end

try
    outputSingleScan(s, 1);
end

while Tdelta < Tmax && ~KbCheck
    Tdelta = GetSecs - Tnot;
    Tratio = min((Tdelta/Tmax), 1);
    Rnow = Rmax * Tratio;
    
    % draw progress bar
    progressBar = SetRect(0, 0, Tratio * windowRect(3), 100);
    Screen('FillRect', window, [1 0 0], progressBar);
    
    % draw text
    DrawFormattedText(window, sprintf('$%.2f', Rnow), 'center', 'center', white);
    
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end

try
    outputSingleScan(s, 0);
end

daqreset;

KbStrokeWait;
sca;