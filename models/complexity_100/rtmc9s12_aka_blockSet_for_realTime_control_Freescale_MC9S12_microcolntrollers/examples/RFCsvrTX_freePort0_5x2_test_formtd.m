% send on COM'1', at 115200 bps, using channel '0', '5' data elements, data type: 'UINT8' (ID = 2)

% this test program works with model 'RFComm_server_TX_freePort0_5.mdl' on the
% MiniDragon+ board   (fw-09-06)

% send next set of '5' characters...
i = 0;
while(1)
    myData1 = i*[1 2 3 4 5]
    myData2 = i*[1 2 3 4 5 6 7]
    disp(['sending [' num2str(myData1) ']']);
    freePortSend(1, 115200, 0, 5, 2, myData1)
    disp(['sending [' num2str(myData2) ']']);
    freePortSend(1, 115200, 1, 7, 2, myData2)
    i = i + 1;
    if(i == 2) i = 0; end
    pause
end

disp('never reached')

