% interprete 'on', 'off', etc.
function outStr = mc_interpreteUserOption(inStr, varargin)

%% optional callup parameter given ('special option')?
if nargin > 1
    
    % yes -> fetch 'special option'
    specOption = varargin{1};
    
else
    
    % not a 'special option'
    specOption = [];
    
end


%% special option?
if ~isempty(specOption)
    
    % yes -> deal with this special case
    switch specOption
        
        case 'cpuFamily'
            
            % define CPUs
            allCPU_9s12 = {'BSP_MC9S12DP256B', 'BSP_MC9S12DG256', 'BSP_MC9S12C128', 'BSP_MC9S12C32', 'BSP_MC9S12DG128'};
            allCPU_c167 = {};
            
            % define families
            if ismember(inStr, allCPU_9s12)
                
                outStr = 'BSP_MC9S12';
                
            elseif ismember(inStr, allCPU_c167)
                
                outStr = 'BSP_C167';
                
            else
                
                outStr = 'UNKNOWN';
                
            end
            
        otherwise
            
            % unknown 'special option'
            disp(['WARNING: Unknown special option ''' specOption '''.'])
            
            % set result to ###
            outStr = '###';
            
    end  % switch
    
else
    
    % no special option given -> just interprete the string
    
    % already a string?
    if ischar(inStr)
        
        % yes -> translate (if applicaple)
        if isalphanum(inStr)
            
            % turn '00' into '0', '01' into '1', etc.
            outStr = num2str(str2double(inStr));
            
        else
            
            % all other strings
            switch inStr
                
                case 'on'
                    
                    outStr = '1';
                    
                case 'off'
                    
                    outStr = '0';
                    
                case 'Dragon12Plus'
                    
                    outStr = 'BSP_DRAGON12PLUS';
                    
                case 'Dragon12'
                    
                    outStr = 'BSP_DRAGON12';
                    
                case 'MiniDragonPlus'
                    
                    outStr = 'BSP_MINIDRAGONPLUS';
                    
                case 'MiniDragonPlus-RevE'
                    
                    outStr = 'BSP_MINIDRAGONPLUS2';
                    
                case 'DragonFly12-C128'
                    
                    outStr = 'BSP_DRAGONFLY12C128';
                    
                case 'DragonFly12-C32'
                    
                    outStr = 'BSP_DRAGONFLY12C32';
                    
                case 'Generic-DG128'
                    
                    outStr = 'BSP_GENERIC_DG128';
                    
                case 'RTI'
                    
                    outStr = 'CORE_RTI';
                    
                case 'T7I'
                    
                    outStr = 'CORE_T7ISR';
                    
                case '4 MHz'
                    
                    outStr = '4';
                    
                case '8 MHz'
                    
                    outStr = '8';
                    
                case '16 MHz'
                    
                    outStr = '16';
                    
                otherwise
                    
                    outStr = inStr;
                    
            end  % switch
            
        end  % alphanum
        
    else
        
        % not a string -> turn into string
        outStr = num2str(inStr);
        
    end
    
end  % special option
