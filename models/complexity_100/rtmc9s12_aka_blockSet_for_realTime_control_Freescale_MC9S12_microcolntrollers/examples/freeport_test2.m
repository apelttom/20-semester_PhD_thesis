% receive on COM'1', at 115200 bps, using channel '0', '1' data element,
% data type: 'UINT8' (ID = 2), blockingFlag: '1' (blocking)

% this test program works with model 'FreePortComm_TX_counter' on the
% Dragon-12 board   (fw-09-06)

while(1 == 1)
    
    % receive next character...
    [myData, nElsRec] = freePortReceive(1, 115200, 0, 1, 2, 1);
    
    disp(['Received ' num2str(nElsRec) ' element(s) on channel 0'])
    disp(['Elements: ' num2str(double(myData))]);

end

% never reached...
disp('done')

