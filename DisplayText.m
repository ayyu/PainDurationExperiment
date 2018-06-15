function [vbl] = DisplayText(window, textToShow, nextPrompt, color)
    if nextPrompt
        textToShow = strcat(textToShow, '\n\n(Press any key to continue)');
    end
    
    DrawFormattedText(window, textToShow, 'center', 'center', color);
    vbl = Screen('Flip', window);
    KbStrokeWait;
end