function lflib_polyline_intersect(block)
    setup(block);
end

function setup(block)

    % Register number of ports
    block.NumInputPorts  = 6;
    block.NumOutputPorts = 1;

    % Setup port properties to be inherited or dynamic
    block.SetPreCompInpPortInfoToDynamic;

    % Override input port properties
    block.InputPort(1).Dimensions  = 1;
    block.InputPort(1).DirectFeedthrough = false;

    block.InputPort(2).Dimensions  = 1;
    block.InputPort(2).DirectFeedthrough = false;

    block.InputPort(3).Dimensions  = 1;
    block.InputPort(3).DirectFeedthrough = false;

    block.InputPort(4).Dimensions  = 1;
    block.InputPort(4).DirectFeedthrough = false;

    block.InputPort(5).Dimensions  = 1;
    block.InputPort(5).DirectFeedthrough = false;

    block.InputPort(6).Dimensions  = 1;
    block.InputPort(6).DirectFeedthrough = false;


    block.OutputPort(1).Dimensions  = 1;
    block.OutputPort(1).DatatypeID = 8; % boolean - http://www.mathworks.com/help/simulink/slref/simulink.blockdata.html#f29-108672

    block.NumDialogPrms     = 2;
    block.DialogPrmsTunable = {'Nontunable', 'Nontunable'};

    block.SampleTimes = [-1 0]; %Inherited sample time

    block.SimStateCompliance = 'HasNoSimState';

    block.RegBlockMethod('Outputs', @Outputs);     % Required
    block.RegBlockMethod('Terminate', @Terminate); % Required

end
%end setup


function Outputs(block)

    tr1X = block.InputPort(1).Data;
    tr1Y = block.InputPort(2).Data;
    tr1Angle = block.InputPort(3).Data;

    tr2X = block.InputPort(4).Data;
    tr2Y = block.InputPort(5).Data;
    tr2Angle = block.InputPort(6).Data;
    
    line1 = block.DialogPrm(1).Data;
    line2 = block.DialogPrm(2).Data;

    tr1AngleCos = cos(tr1Angle);
    tr1AngleSin = sin(tr1Angle);

    tr2AngleCos = cos(tr2Angle);
    tr2AngleSin = sin(tr2Angle);

    line1Tr = zeros(length(line1), 2);
    for i=1:(length(line1))
        x = line1(i, 1); y = line1(i, 2);
        line1Tr(i, 1) = x * tr1AngleCos + y * tr1AngleSin + tr1X;
        line1Tr(i, 2) = y * tr1AngleCos - x * tr1AngleSin + tr1Y;
    end
    
    line2Tr = zeros(length(line2), 2);
    for i=1:(length(line2))
        x = line2(i, 1); y = line2(i, 2);
        line2Tr(i, 1) = x * tr2AngleCos + y * tr2AngleSin + tr2X;
        line2Tr(i, 2) = y * tr2AngleCos - x * tr2AngleSin + tr2Y;
    end
    
    x1b = line1Tr(1, 1);
    y1b = line1Tr(1, 2);
    
    for i=1:(length(line1) - 1)
        x1a = x1b; 
        y1a = y1b;
        x1b = line1Tr(i+1, 1);
        y1b = line1Tr(i+1, 2);

        x2b = line2Tr(1, 1);
        y2b = line2Tr(1, 2);
        
        for j=1:(length(line2) - 1)
            x2a = x2b;
            y2a = y2b;

            x2b = line2Tr(j+1, 1);
            y2b = line2Tr(j+1, 2);

            t1 = ( (x1a-x2a) * (y1b-y1a) + (y2a-y1a) * (x1b-x1a) ) / ( (x2b-x2a) * (y1b-y1a) - (x1b-x1a) * (y2b-y2a) );
            t2 = ( (x2a-x1a) * (y2b-y2a) + (y1a-y2a) * (x2b-x2a) ) / ( (x1b-x1a) * (y2b-y2a) - (x2b-x2a) * (y1b-y1a) );

            if isnan(t1) % parallels with same origin: ((x1b - x1a) * (y2b-y1a)) == ((y1b - y1a) * (x2b-x1a))
                blx = min(x1a, x1b);
                bly = min(y1a, y1b);
                urx = max(x1a, x1b);
                ury = max(y1a, y1b);

                match = (blx <= x2a && x2a <= urx && bly <= y2a && y2a <= ury) || (blx <= x2b && x2b <= urx && bly <= y2b && y2b <= ury);
            elseif isinf(t1) % parallels with different origin
                match = false;
            else
                match = t1 >= 0 && t1 <= 1 && t2 >= 0 && t2 <= 1;
            end

            if match
                block.OutputPort(1).Data = match;
                return
            end
        end
    end
    
    block.OutputPort(1).Data = match;
end
%end Outputs


function Terminate(block)

end
%end Terminate

