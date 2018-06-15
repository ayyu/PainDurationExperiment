% Clear workspace
close all;
clearvars;
sca;

% Setup PTB with some default values
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

% Seed random number generator.
rng('default');

% SCREEN SETUP
% ===

% Set the screen number to the external secondary monitor if there is one
screenIndex = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenIndex);
black = BlackIndex(screenIndex);
grey = white / 2;

[window, windowRect] = PsychImaging('OpenWindow', screenIndex, black, [], 32, 2);
ifi = Screen('GetFlipInterval', window);

% Set the blend function for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Set process priority
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

waitframes = 1;

% Screen('TextFont', window, 'Arial');

% INSTRUCTIONS
% ===

Screen('TextSize', window, 40);
vbl = DisplayText(window, 'Instructions1', true, white);

Ntrials = 4;

% EXPERIMENT LOOP
% ===

s = InitUSB6501();

for trial = 1:Ntrials
    
    Rmax = 100;
    Tmax = 5;
    
    vbl = DisplayText(window, 'Settings', true, white);
    
    Tdelta = 0;
    Tnot = GetSecs;
    
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
    
    DisplayFixation(window,2,white);
end


% outputSingleScan(s, 1);


% outputSingleScan(s, 0);
% daqreset;

KbStrokeWait;
sca;