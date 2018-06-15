function [vbl] = DisplayFixation(window, duration, color)
    DrawFormattedText(window, '+', 'center', 'center', color);
    vbl = Screen('Flip', window);
    WaitSecs(duration);
end