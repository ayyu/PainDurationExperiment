function [session] = InitUSB6501()
    try
        session = daq.createSession('ni');
        addDigitalChannel(session, 'Dev1', 'Port0/Line0', 'OutputOnly');
    catch ME
        warning('Unable to find NI USB-6501 device.');
    end
end