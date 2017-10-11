% send on COM'1', at 115200 bps, using channel '0', '8' data elements, data type: 'UINT8' (ID = 2)
% data = [x x x x x x x x], where x < 0.5 -> 'low', x >= 0.5 -> 'high'

% this test program works with model 'FreePortComm_RX_7Segment' on the
% MiniDragon+ board   (fw-09-06)

myAlphabet = { [1 0 0 0 0 0 0 0], ...
               [0 1 0 0 0 0 0 0], ...
               [0 0 1 0 0 0 0 0], ...
               [0 0 0 1 0 0 0 0], ...
               [0 0 0 0 1 0 0 0], ...
               [0 0 0 0 0 1 0 0], ...
               [0 0 0 0 0 0 1 0], ...
               [0 0 0 0 0 0 0 1], ...
               [1 1 1 1 1 1 0 1], ...   % 0
               [0 1 1 0 0 0 0 0], ...   % 1
               [1 1 0 1 1 0 1 1], ...   % 2
               [1 1 1 1 0 0 1 1], ...   % 3
               [0 1 1 0 0 1 1 1], ...   % 4
               [1 0 1 1 0 1 1 1], ...   % 5
               [1 0 1 1 1 1 1 1], ...   % 6
               [1 1 1 0 0 0 0 0], ...   % 7
               [1 1 1 1 1 1 1 1], ...   % 8
               [1 1 1 0 0 1 1 1], ...   % 9
               [1 1 1 0 1 1 1 1], ...   % A
               [1 1 1 1 1 1 1 1], ...   % B
               [1 0 0 1 1 1 0 1], ...   % C
               [1 1 1 1 1 1 0 1], ...   % D
               [1 0 0 1 1 1 1 1], ...   % E
             };

for(i = 1:length(myAlphabet))
    
    % send next character...
    freePortSend(1, 115200, 0, 8, 2, myAlphabet{i})
    
    % wait 0.3 second
    pause(0.5)
    
end

disp('done')

