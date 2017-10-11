% find and replace in files
% EXAMPLE: 
% findinfilesandreplace('mc_timer.c', ...
%                       '( *)#if DEBUG_MSG_LVL > 0\r\n( *)const char( *)\*funct_name="(\w*)";\r\n( *)#endif', ...
%                       '$1DEFINE_DEBUG_FNAME\("$4"\)')
% ... substitutes
%
%   // local function name... debugging only
%   #if DEBUG_MSG_LVL > 0
%   const char     *funct_name="main";
%   #endif
%
% ... by
%
%   // local function name... debugging only
%   DEFINE_DEBUG_FNAME("main")
%
function findinfilesandreplace(filelist, regexpFind, regexpReplace)

% ensure the supplied list of files is a cell array
if ~iscell(filelist)
    filelist = {filelist};
end

% deal with the entire list of files...
for ii = 1:length(filelist)
    
    % next file
    currFile = which(filelist{ii});
    
    if ~isempty(currFile)
        
        % found the specified file -> process it
        disp(['Processing ' currFile])

        % read file
        lhd = fopen(currFile, 'r');
        txt = fscanf(lhd, '%c');
        fclose(lhd);

        % loop until the 'search expressions' cannot be found anymore
        nSubst = 0;
        while ~isempty(regexp(txt, regexpFind, 'match'))

            % replace the first 'search expression' with the corresponding
            % 'replace expression'
            txt = regexprep(txt, regexpFind, regexpReplace, 'once');
            
            % keep a count of the substitutions in this file
            nSubst = nSubst + 1;

        end
        
        % some feedback...
        disp(['Made ' num2str(nSubst) ' substitutions.'])

        % store modified file  --  if at all required
        if nSubst > 0
            
            lhd = fopen(currFile, 'wb');
            fwrite(lhd, txt);
            fclose(lhd);
            
        end
        
    end

end
