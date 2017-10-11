% receive on COM'1', at 115200 bps, using channel '0', '5' data elements,
% data type: 'UINT8' (ID = 2), blockingFlag: '1' (blocking)

% this test program works with model 'FreePortComm_TX_simple2' on the
% Dragon-12 board   (fw-10-06)

while(1 == 1)
    
    disp('Waiting for data...')
    
    % receive next character... (blocking)
    [myData, nElsRec] = freePortReceive(1, 115200, 0, 5, 2, 1);
    
    disp(['Received ' num2str(nElsRec) ' element(s) on channel 0'])
    myDataStr = 'Elements: ';
    for i=1:nElsRec
        myDataStr = [myDataStr num2str(double(myData(i))) ':'];
    end
    myDataStr(end) = [];
    disp(myDataStr);
    
    % allow this to be interrupted by ctrl-C
    pause(0.3)

end

% never reached...
disp('done')

