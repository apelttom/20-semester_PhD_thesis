% send on COM'1', at 115200 bps, using channel '0', '1' data elements, data type: 'UINT8' (ID = 2)

% this test program works with model 'RFComm_server_TX_freePort0.mdl' on the
% MiniDragon+ board   (fw-09-06)

% send next character...
i = 0;
while(i < 4)
    disp(['sending ' num2str(i)]);
    freePortSend(1, 115200, 0, 1, 2, i)
    i = i + 1;
    if(i == 4) i = 0; end
    pause
end

disp('never reached')

