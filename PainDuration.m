% PARAMETERS
% ===

instTextSize = 40;
loopTextSize = 60;

% Clear workspace
close all;
clearvars;
sca;

% Setup PTB with some default values
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

% Seed random number generator.
rng('default');

% initalize NI USB DAQ
s = InitUSB6501();

% SCREEN SETUP
% ===

% Select external secondary monitor if there is one
screenIndex = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenIndex);
black = BlackIndex(screenIndex);

% Init the screen, get monitor refresh, set experiment fps
[window, windowRect] = PsychImaging('OpenWindow', screenIndex, black, [], 32, 2);
ifi = Screen('GetFlipInterval', window);
waitframes = 1;

% Set the blend function for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Set process priority
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% INSTRUCTIONS
% ===

Screen('TextSize', window, instTextSize);

% TODO: actual instructions text
vbl = DisplayText(window, 0, 'Instructions', white);

% PARAMETERS
% ===

Ntrials = 4;

% TODO: replace these with either randomly shuffled/generated lists of
% parameters, or load them from a pre-generated .mat file
Rmax = 100 * ones(Ntrials, 1);
Tmax = 5 * ones(Ntrials, 1);
Itrial = 1.5 * ones(Ntrials, 1);
Ttrial = zeros(Ntrials, 1);

% EXPERIMENT LOOP
% ===

Screen('TextSize', window, loopTextSize);

for trial = 1:Ntrials
    
    settingsText = ['For this trial:\n' ...
        'Current: ' num2str(Itrial(trial)) ' mA\n', ...
        'Maximum reward: $' num2str(Rmax(trial)) '\n', ...
        'Maximum duration: ' num2str(Tmax(trial)) ' seconds'];
    vbl = DisplayText(window, 0, settingsText, white);
    
    Tdelta = 0;
    Rtrial = 0;
    Tnot = GetSecs;
    TmaxN = Tmax(trial);
    RmaxN = Rmax(trial);
    
    % turn on stimulus with TTL through NI DAQ
    % outputSingleScan(s, 1);
    
    while Tdelta < TmaxN && ~KbCheck
        % calculate elapsed time and percentage completion
        Tdelta = GetSecs - Tnot;
        Tratio = min( (Tdelta/TmaxN) , 1);
        Rtrial = RmaxN * Tratio;

        % draw progress bar at top of screen
        progressBar = SetRect(0, 0, Tratio * windowRect(3), 100);
        Screen('FillRect', window, [1 0 0], progressBar);

        % draw reward amount text
        DrawFormattedText(window, sprintf('$%.2f', Rtrial), 'center', 'center', white);

        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    
    % turn off stimulus through TTL
    % outputSingleScan(s, 0);
    
    % calculate one last time directly after button press for most accuracy
    % otherwise data will be dependent on resolution/jitter of monitor
    % refresh rate
    Tdelta = GetSecs - Tnot;
    Tratio = min( (Tdelta/TmaxN) , 1);
    Rtrial = RmaxN * Tratio;
    Ttrial(trial) = Tdelta;

    % show reward earned for this trial
    rewardText = ['Reward earned: ', sprintf('$%.2f', Rtrial)];
    DisplayText(window, 3, rewardText, white);
    
    DisplayFixation(window, 1, white);
end

% release NI DAQ session
daqreset;

DisplayText(window, 0, 'End of experiment', white);

sca;