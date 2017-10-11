function [out_portstr, out_pinstr, in_portstr, in_pinstr] = mbc_sonar(out_port, out_pin, in_port, in_pin, sampletime)

% Check the sample time:
if sampletime < 0 && sampletime ~= -1
   fprintf ('Digital input: Inadmissible sample time !\n');
end


% Check port number
port_strings = {'PORTA', 'PORTB', 'PTH', 'PTJ', 'PTM', 'PTP', 'PTS', 'PTT'};
ddr_strings = {'DDRA', 'DDRB', 'DDRH', 'DDRJ', 'DDRM', 'DDRP', 'DDRS', 'DDRT'};
out_portstr = port_strings{out_port};
in_portstr = port_strings{in_port};
out_ddrstr = ddr_strings{out_port};
in_ddrstr = ddr_strings{in_port};
%disp([portstr, ' - ', ddrstr])

out_pin = out_pin-1;
in_pin = in_pin-1;

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
if(any(setdiff(out_pin, valid_pin{out_port})))
    out_pinstr = '???';
    fprintf ('Sonar: Inadmissible output pin number for %d.\n', out_pin);
else
    out_pinstr = num2str(out_pin);
end

if(any(setdiff(in_pin, valid_pin{in_port})))
    in_pinstr = '???';
    fprintf ('Sonar: Inadmissible input pin number for %d.\n', in_pin);
else
    in_pinstr = num2str(in_pin);
end

if(in_port==out_port)
    if(in_pin==out_pin)
        fprintf ('Sonar: Input pin and output pin clash.\n');
        out_pinstr = '???';
        in_pinstr = '???';
    end        
end

% assemble mask
out_pinmask = 2^out_pin;
in_pinmask = 2^in_pin;

% turn mask into string
out_pinmask = num2str(out_pinmask);
in_pinmask = num2str(in_pinmask);

% Create resource keywords to be reserved in resource database
modelRTWFields = struct( 'out_portStr', out_portstr, 'out_ddrStr', out_ddrstr, 'out_pinMask', out_pinmask, 'out_pinStr', out_pinstr, 'in_portStr', in_portstr, 'in_ddrStr', in_ddrstr, 'in_pinMask', in_pinmask, 'in_pinStr', in_pinstr ); 

% Insert modelRTWFields in the I/O block S-Function containing the Tag 'MC9S12DriverDataBlock'
MC9S12DriverDataBlock = find_system(gcb, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function', 'Tag', 'mcTarget_sonar');
set_param(MC9S12DriverDataBlock{1}, 'RTWdata', modelRTWFields);
