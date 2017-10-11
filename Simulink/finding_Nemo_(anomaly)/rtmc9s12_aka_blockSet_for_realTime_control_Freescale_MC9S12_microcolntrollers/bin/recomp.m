% Recompile any of the MC s-functions into a Mex-DLL (file extension mexw32)
% This might become necessary when mofifying the call-up parameters of the masking block...
% (Matlab 2007a)
%
% (FW-06-07)

function recomp(varargin)

% set macro DEBUG_MSG_LVL
if (nargin == 0)
    name = 'all';
elseif (nargin == 1)
    name = varargin{1};
else
    error('USAGE: recomp  OR   recomp(''mySFCN.c'')')
end


temppath = cd;
bin_path = fileparts(mfilename('fullpath'));
bin_path = rtw_alt_pathname(fullfile(fileparts(bin_path), 'mc', 'blocks'));
cd (bin_path);

switch name
    
    case 'all'
        
        % all files *_sfcn_* in .../mc are to be compiled..
        mySfcns = dir(fullfile(bin_path, '*_sfcn_*.c'));
        
        % any files to be compiled?
        if ~isempty(mySfcns)
            
            % yep -> fetch file names
            mySfcnNames = { mySfcns(:).name };

        end

        % additional files...
        mySfcnNames{ end + 1 } = 'freePortComms_rxd.c';
        mySfcnNames{ end + 1 } = 'freePortComms_txd.c';
        mySfcnNames{ end + 1 } = 'fuzzy_ni1o.c';
        
        % compile, file by file
        for ii = 1:length(mySfcnNames)
            
            disp (['Compiling file ', mySfcnNames{ii}, ' into a DLL (file extension ''mexw32'').']);
            feval(@mex, mySfcnNames{ii}, '-v')
            
        end
        
    otherwise
        
        % compile a specific file...
        disp (['Compiling file ', name, ' into a DLL (file extension ''mexw32'').']);
        feval(@mex, name, '-v')
        
end % switch

cd(temppath);
clear temppath;

disp ('Done !');
