function [vbl] = DisplayText(window, duration, text, color)
    if duration == 0
        text = strcat(text, '\n\n(Press any key to continue)');
    end
    
    DrawFormattedText(window, text, 'center', 'center', color);
    vbl = Screen('Flip', window);
    
    if duration == 0
        KbStrokeWait;
    else
        WaitSecs(duration);
    end
end