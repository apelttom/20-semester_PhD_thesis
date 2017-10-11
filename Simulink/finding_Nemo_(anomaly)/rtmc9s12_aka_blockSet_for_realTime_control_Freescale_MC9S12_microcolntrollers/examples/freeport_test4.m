% receive on COM'1', at 115200 bps, using channel '0', '5' data elements,
% data type: 'SINGLE' (ID = 0), blockingFlag: '1' (blocking)

% this test program works with model 'FreePortComm_TX_simple_test' on the
% Dragon-12 board   (fw-10-06)

while(1 == 1)
    
    disp('Waiting for data...')
    
    % receive next character... (blocking)
    [myData, nElsRec] = freePortReceive(1, 115200, 0, 5, 0, 1);
    
    disp(['Received ' num2str(nElsRec) ' element(s) on channel 0'])
    myDataStr = 'Elements: ';
    for i=1:nElsRec
        myDataStr = [myDataStr num2str(double(myData(i))) ':'];
    end
    myDataStr(end) = [];
    disp(myDataStr);
    
    % allow this to be interrupted by ctrl-C (code blocks in
    % 'freePortReceive' - might need to press a button on the target to
    % reach this point => ctrl-C, then button on target)
    pause(0.3)

end

% never reached...
disp('done')

