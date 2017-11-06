function adjPktSize = ExtAdjPktSize(pktSize, totalBytesWritten, pktData)

MAX_SERIAL_PKT_SIZE = 400;
currRecStartIdx     = totalBytesWritten;
bytesStillToWrite   = pktSize - totalBytesWritten;
currPktDataSize     = 0;

while (currPktDataSize < bytesStillToWrite)
    
    % size info: last element of size array (bytes 5 - 8)
    currRecSize = double(pktData(currRecStartIdx + 8));
    
    % adjust packet size: each record is '4 (= type) + currRecSize + 4
    % (= size)' bytes long
    currPktDataSize = currPktDataSize + (8 + currRecSize);
    
    % are we done
    if (currPktDataSize > MAX_SERIAL_PKT_SIZE)
        
        % exceeding maximum admissible FIFO buffer size -> exit while
        % loop
        break;
        
    else
        
        % there still remains some space for further data -> next index
        currRecStartIdx = currPktDataSize;
        
    end
    
end


% return the number of bytes to be written in the call to ExtSetPkt
if (currPktDataSize > MAX_SERIAL_PKT_SIZE)
    
    % 'currPktDataSize' exceeds maximum admissible FIFO buffer size
    adjPktSize = currPktDataSize - (8 + currRecSize);
    
else
    
    % 'currPktDataSize' is the remainder of what's left to be sent (fits
    % into a FIFO buffer)
    adjPktSize = currPktDataSize;
    
end

