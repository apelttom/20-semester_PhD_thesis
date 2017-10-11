% model block configuration: ADCINPUT
%
% fw-08-10
function [portstr, pinstr, pins] = mbc_digitaloutput(port, pin, sampletime, Von, Voff)

% Check the sample time:
if sampletime < 0 && sampletime ~= -1

    fprintf ('Digital output: Inadmissible sample time !\n');

end

% Check Von & Voff
if Von < Voff

    fprintf ('Digital output: ''Von'' needs to be smaller or equal to ''Voff''.\n');
    
end


% Check port number
port_strings = {'PORTA', 'PORTB', 'PTH', 'PTJ', 'PTM', 'PTP', 'PTS', 'PTT'};
ddr_strings = {'DDRA', 'DDRB', 'DDRH', 'DDRJ', 'DDRM', 'DDRP', 'DDRS', 'DDRT'};
portstr = port_strings{port};
ddrstr = ddr_strings{port};
%disp([portstr, ' - ', ddrstr])

% determine chosen pins
pin = strrep(pin, '|', ' ');
pin = strrep(pin, ',', ' ');
pin = strrep(pin, ';', ' ');

% get pin numbers and number of pins
pins = str2num(pin);           %#ok<ST2NM> % this is the parameter to be passed to the sfunction (numeric)
numPins = length(pins);

% Check if all pin number are available on the chosen port
valid_pin = { [0 1 2 3 4 5 6 7]; ...
              [0 1 2 3 4 5 6 7]; ...
              [0 1 2 3 4 5 6 7]; ...
              [0 1 6 7]; ...
              [0 1 2 3 4 5 6 7]; ...
              [0 1 2 3 4 5 6 7]; ...
              [0 1 2 3 4 5 6 7]; ...
              [0 1 2 3 4 5 6 7] };

% Check the pin number and set pinstr (display)
if(any(setdiff(pins, valid_pin{port})))
    pinstr = '???';
    fprintf ('Digital output: Inadmissible pin number for %d.\n', min(setdiff(pins, valid_pin{port})));
else
    pinstr = [];
    for i = 1:numPins
        pinstr = [pinstr ',' num2str(pins(i))];
    end
    pinstr(1) = [];
end

% assemble mask
pinmask = 0;
for i = 1:numPins
    pinmask = pinmask + 2^pins(i);
end

% turn mask into string
pinmask = num2str(pinmask);

% Create resource keywords to be reserved in resource database
modelRTWFields = struct( 'portStr', portstr, 'ddrStr', ddrstr, 'pinMask', pinmask, 'pinStr', pinstr ); 


%% adjust number of block input ports...

% de-activate link to library (permanently)
if ~strcmp(get_param(gcb, 'LinkStatus'), 'inactive')
    
    %set_param(gcb, 'LinkStatus', 'inactive')
    set_param(gcb, 'LinkStatus', 'none')
    
end


% Insert modelRTWFields in the I/O block S-Function containing the Tag
% 'mcTarget_digOut'
MC9S12DriverDataBlock = find_system(gcb, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function', 'Tag', 'mcTarget_digOut');
set_param(MC9S12DriverDataBlock{1}, 'RTWdata', modelRTWFields);



% Get current number outputs
num_now = length (find_system (gcb, 'LookUnderMasks', 'on', 'BlockType', 'Inport'));
%disp(['num_now = ' num2str(num_now)]);
if numPins < num_now
    for k = numPins+1:num_now
        delete_line (gcb, ['In', num2str(k), '/1'], ['Mux/', num2str(k)])
        delete_block ([gcb, '/In', num2str(k)])
    end
    set_param ([gcb, '/Mux'], 'Inputs', num2str(numPins))
else
    set_param ([gcb, '/Mux'], 'Inputs', num2str(numPins))
    for i = num_now+1:numPins
        add_block ('built-in/Inport', [gcb, '/In', num2str(i)])
        set_param ([gcb, '/In', num2str(i)], 'Position', get_param ([gcb, '/In', num2str(i-1)], 'Position') + [0 45 0 45])
        set_param ([gcb, '/In', num2str(i)], 'FontSize', '12')
        add_line (gcb, ['In', num2str(i), '/1'], ['Mux/', num2str(i)])
    end
end
