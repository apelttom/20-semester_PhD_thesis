% compute a simple CRC16 of any given string
function crc = crc16(C)

persistent crc16_tab_init crc16_tab

% has the local function crc16_tab_init ever been run?
if isempty(crc16_tab_init)
    
    % run it now...
    crc16_tab = i_crc16_tab_init;
    
    % set flag
    crc16_tab_init = true;
    
end
    
% compute CRC
crc = uint16(0);
for ii = 1:length(C)

    tmp = bitxor(crc, uint16(C(ii)));
    crc = bitxor(bitshift(crc, -8), crc16_tab(1 + bitand(tmp, 255)));

end

    
% local functions -------------------------------------------------------
function crc16_tab = i_crc16_tab_init

% P_16 = 0xA001
P_16 = uint16(16^3*10 + 1);

crc16_tab = zeros(1, 256);
for ii = 0:255
   
    crc = uint16(0);
    c = uint16(ii);
    
    for jj = 0:7
        
        if logical(bitand(bitxor(crc, c), uint16(1)))
            crc = bitxor(bitshift(crc, -1), P_16);
        else
            crc = bitshift(crc, -1);
        end
        
        c = bitshift(c, -1);
        
    end

    % store value
    crc16_tab(ii + 1) = crc;
   
end
