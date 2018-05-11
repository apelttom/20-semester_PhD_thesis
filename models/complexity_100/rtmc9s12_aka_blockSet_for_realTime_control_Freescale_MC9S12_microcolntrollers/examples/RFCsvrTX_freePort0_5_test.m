% send on COM'1', at 115200 bps, using channel '0', '5' data elements, data type: 'UINT8' (ID = 2)

% this test program works with model 'RFComm_server_TX_freePort0_5.mdl' on the
% MiniDragon+ board   (fw-09-06)

% send next set of '5' characters...
i = 0;
while(1)
    myData = i*[1 2 3 4 5]
    disp(['sending [' num2str(myData) ']']);
    freePortSend(1, 115200, 0, 5, 2, myData)
    i = i + 1;
    if(i == 2) i = 0; end
    pause
end

disp('never reached')

