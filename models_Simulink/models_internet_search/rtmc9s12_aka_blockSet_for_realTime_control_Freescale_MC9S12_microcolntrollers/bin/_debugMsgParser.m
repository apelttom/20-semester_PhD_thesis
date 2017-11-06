% filters out debug messages and builds a host based database of target based debug messages...

% find root installation folder
rootDir = fileparts(mfilename('fullpath'));

% directories to be scanned
scanDirs{1} = [rootDir '\mc'];
scanDirs{2} = [rootDir '\rtw\c\src\ext_mode\common'];
scanDirs{3} = [rootDir '\rtw\c\src\ext_mode\serial'];

% look for these strings...
scanStr{1}  = 'PRINT_DEBUG_MSG_LVL1("';
scanStr{2}  = 'PRINT_DEBUG_MSG_LVL2("';
scanStr{3}  = 'PRINT_DEBUG_MSG_LVL3("';
scanStr{4}  = 'PRINT_DEBUG_MSG_LVL4("';
scanStr{5}  = 'PRINT_DEBUG_MSG_LVL5("';
scanStr{6}  = 'PRINT_DEBUG_MSG_LVL1_Raw("';
scanStr{7}  = 'PRINT_DEBUG_MSG_LVL2_Raw("';
scanStr{8}  = 'PRINT_DEBUG_MSG_LVL3_Raw("';
scanStr{9}  = 'PRINT_DEBUG_MSG_LVL4_Raw("';
scanStr{10} = 'PRINT_DEBUG_MSG_LVL5_Raw("';

% global message identifier
msgIdentifier = 1;

% create debug message data base file
msgDataBaseFile = [rootDir '\bin\debugMsgDataBase.txt'];
fhd2 = fopen(msgDataBaseFile, 'w');


% files to be scanned
for i = 1:length(scanDirs)
    
    % create backup directory
    origDir = [scanDirs{i} '\_original_c'];
    if ~exist(origDir, 'dir')
        mkdir(origDir);
    end
    
    % find all '.c' files in this folder
    files = dir([scanDirs{i} '\*.c']);
    
    
    % scan files...
    for j = 1:length(files)
        
        currFileName = files(j).name;
        currFile = [scanDirs{i} '\' currFileName];

        % flag to indicate that a backup of the original source code file
        % has been made
        doneBackup = 0;
        
        % skip the debugMsgs definition file...
        if(findstr(currFile, 'debugMsgs.c'))
            continue;
        end
        
        disp(['Scanning file: ' currFileName])
        
        fhd = fopen(currFile, 'r');
        fcont = [];
        while ~feof(fhd)
            fcont = [fcont fgets(fhd)]; %#ok<AGROW>
        end
        %fcont = fscanf(fhd, '%s');
        fclose(fhd);
        
        l1 = find(fcont == 10);
        l2 = find(fcont == 13);
        
        % check consistency of end-of-line characters...
        if any((l1-l2) ~= 1)
            disp('WARNING: Found inconsistent end-of-line characters (not: LF CR)')
        end
        
        % replace

        % fill cell array with lines of the source file
        myLineDelimits = unique([0 l1 length(fcont)]);
        myLines = cell(1, length(myLineDelimits)-1);
        
        for k = 1:length(myLines)
            myLines{k} = fcont(myLineDelimits(k)+1:myLineDelimits(k+1));
        end
        
        % perform scan
        for k = 1:length(myLines)
            
            currLine = myLines{k};
            
            % cycle through all scan strings
            for m = 1:length(scanStr)
                
                currStr = scanStr{m};
                kk = findstr(currLine, currStr);
                if ~isempty(kk)
                    
                    % found a debug string that needs replaced -> mk backup
                    % of original source code file
                    if ~doneBackup
                        
                        % only do backup once
                        if ~exist([origDir '\' currFileName], 'file')
                            copyfile(currFile, origDir);
                        end

                        doneBackup = 1;
                        
                    end
                    
                    lvlStr = currStr(end-2);
                    if m > 5
                        formatStr = 'R';
                    else
                        formatStr = 'F';
                    end
                    
                    m1 = kk+length(scanStr{m});                           % beginning of txt section
                    m2 = m1 + min(findstr(currLine(m1:end), '");')) - 1;  % begining of end section
                    
                    currLine1 = currLine(1:m1-1);
                    currLine2 = currLine(m1:m2-1);
                    currLine3 = currLine(m2:end);

                    % string replacement
                    strReplacement = ['°' formatStr lvlStr '°' num2str(msgIdentifier) '°'];
                    
                    % replacement line
                    if length(strReplacement) < length(currLine2)
                        
                        % only replace strings which are longer in the
                        % original version
                        myLines{k} = [currLine1 strReplacement currLine3];
                        
                        disp(['Replacing: ' currLine])
                        disp(['by:        ' myLines{k}])

                        msgIdentifier = msgIdentifier + 1;
                        
                        % log replacement in message data base file
                        fprintf(fhd2, '%s\r\n', [strReplacement '°=°' currLine2]);

                    end
                    
                end  % found a debug string
                
            end  % for all scanStrings
            
        end  % for all lines
        
        % only create updated file if needed...
        if doneBackup
            
            fcont = [];
            for k = 1:length(myLines)
                fcont = [fcont myLines{k}]; %#ok<AGROW>
            end

            disp(['Writing modified file ' currFileName])
            fhd = fopen(currFile, 'w');
            fwrite(fhd, fcont);
            fclose(fhd);
            
        end  % doneBackup
        
    end  % for all files
    
end  % for all directories

% close data base file
fclose(fhd2);
