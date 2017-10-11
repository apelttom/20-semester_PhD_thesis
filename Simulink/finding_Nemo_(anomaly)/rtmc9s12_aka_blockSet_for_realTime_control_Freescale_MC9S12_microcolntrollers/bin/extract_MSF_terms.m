% analyse Floulib input MSF file
function [textInputMSFs, textOutputMSFs, textInputMSFdef, textRules, textOutputSingletons, numMSFs_in1, numMSFs_in2, numMSFs_in3, numOutputMSFs] = ...
    extract_MSF_terms(I1name, I2name, I3name, Oname, Rname, myName)


% % input filenames
% I1name = 'x1.txt';
% I2name = 'x2.txt';
% I3name = 'x3.txt';
%
% % output filename
% Oname = 'y.txt';
%
% % rule base
% Rname = 'rb.txt';


% ii/p MSF (trapezoidal) ===================================================

% figure out how many inputs we're dealing with...
myValidInputs = [];
for kk = 1:3
    if ~strcmp(eval(['I' num2str(kk) 'name']), '-')
        myValidInputs = [myValidInputs kk]; %#ok<*AGROW>
    end
end

if(~isempty(myValidInputs))
    nInputs = length(myValidInputs);
end

% loop through all ii/p MSF
for kk = 1:nInputs
    
    % open file
    % eval(['fid = fopen(I' num2str(myValidInputs(kk)) 'name, ''r'');']);
    fid = feval(@fopen, eval(['I' num2str(myValidInputs(kk)) 'name']), 'r');
    
    
    % get ii/p MSF
    myInp = fread(fid, inf, 'uchar');
    
    fclose(fid);
    
    % reformat
    myInp(myInp == 10) = [];                    % get rid of all '10s'
    delims = find(myInp == 13);                 % delimiters
    delims = unique([0 delims' length(myInp)]);
    
    for ii = 1:length(delims)-1
        
        ll = myInp(delims(ii)+1:delims(ii+1)-1);
        myInputMSF{kk, ii} = char(ll)';
        
    end
    
end


% loop through all ii/p MSF
runningIDX = 1;
numInputMSFs = zeros(1,3);
for kk = 1:nInputs
    
    % output format:
    %
    % ; -------------------------------------------------------------
    % ; Fuzzy Membership sets
    % ; -------------------------------------------------------------
    % ; input membership variables
    %           absentry fuzvar
    % fuzvar:   ds.b 10   ; inputs
    %
    % x1_N2 :   equ  0    ; x1 very negative
    % x1_N1 :   equ  1    ; x1 negative
    % x1_Z  :   equ  2    ; x1 zero
    % x1_P1 :   equ  3    ; x1 positive
    % x1_P2 :   equ  4    ; x1 very positive
    %
    % x2_N2 :   equ  5    ; x2 very negative
    % x2_N1 :   equ  6    ; x2 negative
    % x2_Z  :   equ  7    ; x2 zero
    % x2_P1 :   equ  8    ; x2 positive
    % x2_P2 :   equ  9    ; x2 very positive
    
    nterms = str2double(myInputMSF{kk, 1});
    numInputMSFs(kk) = nterms;               % store for the calling function
    
    % loop through all terms
    for ii = 2:nterms+1
        
        termName = myInputMSF{kk, ii};
        termDelim = find(termName == ' ', 1 );
        inputNameline{2+runningIDX} = [myName '_x' num2str(myValidInputs(kk)) '_' termName(1:termDelim-1) ':     equ  ' num2str(runningIDX-1)];
        runningIDX = runningIDX + 1;
        
    end
    
    inputNameline{1} = ['           absentry ' myName '_fuzvar'];
    inputNameline{2} = [myName '_fuzvar:     ds.b  ' num2str(runningIDX-1)];
    
end



% define input MSFs
% loop through all ii/p MSF
runningIDX2 = 1;
for kk = 1:nInputs
    
    % x1_tab:   dc.b  0, 85, 0, 13
    %           dc.b  42, 128, 4, 10
    %           dc.b  85, 170, 6, 6
    %           dc.b  128, 213, 10, 4
    %           dc.b  170, 255, 13, 0
    % x2_tab:   dc.b  0, 85, 0, 13
    %           dc.b  42, 128, 4, 10
    %           dc.b  85, 170, 6, 6
    %           dc.b  128, 213, 10, 4
    %           dc.b  170, 255, 13, 0
    
    
    % find number of terms of this variable
    nterms = str2double(myInputMSF{kk, 1});
    
    % find effective universe of discourse
    ll = myInputMSF{kk, 2};
    termDelim = find(termName == ' ');
    lim1 = str2double(ll(termDelim(1)+1:termDelim(2)-1));
    ll = myInputMSF{kk, nterms+1};
    termDelim = find(termName == ' ');
    termDelim = termDelim(4);           % beginning of last term
    lim2 = str2double(ll(termDelim+1:end));
    
    uniDis  = lim2 - lim1;
    uniLeft = lim1;
    
    % loop through all terms
    for ii = 2:nterms+1
        
        termName = myInputMSF{kk, ii};
        termDelim = find(termName == ' ');
        MSFterms = [str2double(termName(termDelim(1)+1:termDelim(2)-1)), ...
            str2double(termName(termDelim(2)+1:termDelim(3)-1)), ...
            str2double(termName(termDelim(3)+1:termDelim(4)-1)), ...
            str2double(termName(termDelim(4)+1:end)) ];
        
        % reformat terms for the 9S12
        MSFterms = min(ceil((MSFterms - uniLeft) / uniDis * 255), 255);
        m1 = MSFterms(2) - MSFterms(1);
        if(m1 > 0)
            m1 = min(ceil(255/m1), 255);        % non-vertical ascend
        else
            m1 = 0;                             % vertical ascend
        end
        m2 = MSFterms(4) - MSFterms(3);
        if(m2 > 0)
            m2 = min(ceil(255/m2), 255);        % non-vertical ascend
        else
            m2 = 0;                             % vertical ascend
        end
        MSFterm  = [MSFterms(1) MSFterms(4) m1 m2];
        
        if(ii == 2)
            % 1st term -> add label...
            inputMSFline{runningIDX2} = [myName '_x' num2str(myValidInputs(kk)) '_tab:     dc.b  ' num2str(MSFterm(1)) ', ' num2str(MSFterm(2)) ', ' ...
                num2str(MSFterm(3)) ', ' num2str(MSFterm(4))];
        else
            % all other terms
            inputMSFline{runningIDX2} = ['            dc.b  ' num2str(MSFterm(1)) ', ' num2str(MSFterm(2)) ', ' ...
                num2str(MSFterm(3)) ', ' num2str(MSFterm(4))];
        end
        
        runningIDX2 = runningIDX2 + 1;
        
    end
    
end


% o/p MSF (trapezoidal) ===================================================

% open file
fid = fopen(Oname, 'r');

% get o/p MSF
myOutp = fread(fid, inf, 'uchar');

fclose(fid);

% reformat
myOutp(myOutp == 10) = [];              % get rid of all '10s'
delims = find(myOutp == 13);                  % delimiters
delims = unique([0 delims' length(myOutp)]);

for ii = 1:length(delims)-1
    
    kk = myOutp(delims(ii)+1:delims(ii+1)-1);
    myOutputMSF{ii} = char(kk)';
    
end

% determine number of o/p terms
nterms = str2double(myOutputMSF{1});
numOutputMSFs = nterms;                       % store for the calling function

% output section  (runningIDX continues from input section)
for kk = 1:nterms
    
    % ; -------------------------------------------------------------
    % ; Fuzzy Membership sets
    % ; -------------------------------------------------------------
    % ; output membership variables
    %           absentry fuzout
    % fuzout:   ds.b 5    ; outputs
    %
    % out_N2 :   equ  10    ; out very negative
    % out_N1 :   equ  11    ; out negative
    % out_Z  :   equ  12    ; out zero
    % out_P1 :   equ  13    ; out positive
    % out_P2 :   equ  14    ; out very positive
    
    % filter out MSF name
    ll = myOutputMSF{1+kk};
    ll = ll(1:find(ll == ' ', 1 )-1);
    
    outputNameline{2+kk} = [myName '_out_' ll ':     equ  ' num2str(runningIDX-1)];
    runningIDX = runningIDX + 1;
    
end

outputNameline{1} = ['           absentry ' myName '_fuzout'];
outputNameline{2} = [myName '_fuzout:     ds.b  ' num2str(nterms)];


% rule base ==============================================================

% open file
fid = fopen(Rname, 'r');

% get rule base
myRB = fread(fid, inf, 'uchar');

fclose(fid);

% reformat
myRB(myRB == 10) = [];               % get rid of all '10s'
delims = find(myRB == 13);                 % delimiters
delims = unique([0 delims' length(myRB)]);

for ii = 1:length(delims)-1
    
    kk = myRB(delims(ii)+1:delims(ii+1)-1);
    myRules{ii} = char(kk)';
    
end


% loop through all rules
kk = myRules{1};
nRules = length(myRules)-1;                          % number of rules
nInputs2 = str2double(kk(1:find(kk == ' ', 1, 'last' )));       % number of rules
if(nInputs2 ~= nInputs)
    error(['The rule base has an inconsistent number inputs (' num2str(nInputs2) ' instead of ' num2str(nInputs) ').']);
end

for kk = 1:nRules
    
    % rules:
    % ; to be completed ...
    %           dc.b  spErr_very_neg, accel_negative, $FE, power_add,  $FE
    %           dc.b  spErr_very_neg, accel_zero,     $FE, power_add,  $FE
    %           dc.b  spErr_very_neg, accel_positive, $FE, power_add,  $FE
    %           dc.b  spErr_negative, accel_negative, $FE, power_add,  $FE
    %           dc.b  spErr_negative, accel_zero,     $FE, power_zero, $FE
    %           dc.b  spErr_negative, accel_positive, $FE, power_zero, $FE
    %           dc.b  spErr_zero,     accel_negative, $FE, power_zero, $FE
    %           dc.b  spErr_zero,     accel_zero,     $FE, power_zero, $FE
    %           dc.b  spErr_zero,     accel_positive, $FE, power_zero, $FE
    %           dc.b  spErr_positive, accel_negative, $FE, power_zero, $FE
    %           dc.b  spErr_positive, accel_zero,     $FE, power_zero, $FE
    %           dc.b  spErr_positive, accel_positive, $FE, power_sub,  $FE
    %           dc.b  spErr_very_pos, accel_negative, $FE, power_sub,  $FE
    %           dc.b  spErr_very_pos, accel_zero,     $FE, power_sub,  $FE
    %           dc.b  spErr_very_pos, accel_positive, $FE, power_sub,  $FE
    %           dc.b  $FF
    
    % get current rule
    myRule = myRules{1+kk};
    delims = find(myRule == ' ');
    myX{1} = myRule(1:delims(1)-1);
    for ii = 2:nInputs
        myX{ii} = myRule(delims(ii-1)+1:delims(ii)-1);
    end
    myY  = myRule(delims(nInputs)+1:end);
    
    % assemble rule string
    zeRule = ['      dc.b ' myName '_x1_' myX{1}];
    for ii = 2:nInputs
        zeRule = [zeRule ', ' myName '_x' num2str(ii) '_' myX{ii}];
    end
    zeRules{kk} = [zeRule ', $FE, ' myName '_out_' myY ', ' '$FE'];
    
end
zeRules{end+1} = '      dc.b $FF';      % end of rule base


% output (singletons) ===========================================================

mySingletons = [];
nOutp = length(myOutputMSF)-1;

for kk = 1:nOutp
    
    % determine centre of the MSF
    ll = myOutputMSF{1+kk};
    delims = find(ll == ' ');
    myCentre = (str2double(ll(delims(3)+1:delims(4)-1)) + str2double(ll(delims(2)+1:delims(3)-1)))/2;
    
    mySingletons = [mySingletons myCentre];    % append to centres vector
    
end

% find effective universe of discourse (output)
ll = myOutputMSF{2};
termDelim = find(ll == ' ');
lim1 = str2double(ll(termDelim(1)+1:termDelim(2)-1));
ll = myOutputMSF{end};
termDelim = find(ll == ' ');
termDelim = termDelim(4);           % beginning of last term
lim2 = str2double(ll(termDelim+1:end));

uniDis  = lim2 - lim1;
uniLeft = lim1;

% normalize 'mySingetons'
mySingletons = min(ceil((mySingletons - uniLeft) / uniDis * 255), 255);


% produce formatted output

% output_singletons:
%      ; MoM -- Mean of Maximum (using 0 ... 255 range)
%      ; power_bigsub, power_sub, power_zero, power_add, power_bigadd
%      dc.b (64-0)/2, 103, 128, 154, (255+190)/2

myOutputSingletons = '    dc.b ';
for ii = 1:length(mySingletons)-1
    myOutputSingletons = [myOutputSingletons num2str(mySingletons(ii)) ', '];
end
myOutputSingletons = [myOutputSingletons num2str(mySingletons(end))];


% generate text blocks
textInputMSFs = [];
for ii = 1:length(inputNameline)
    textInputMSFs = [textInputMSFs inputNameline{ii} char(10) char(13)];
end

textOutputMSFs = [];
for ii = 1:length(outputNameline)
    textOutputMSFs = [textOutputMSFs outputNameline{ii} char(10) char(13)];
end

textInputMSFdef = [];
for ii = 1:length(inputMSFline)
    textInputMSFdef = [textInputMSFdef inputMSFline{ii} char(10) char(13)];
end

textRules = [];
for ii = 1:length(zeRules)
    textRules = [textRules zeRules{ii} char(10) char(13)];
end

textOutputSingletons = myOutputSingletons;

% other return parameters
numMSFs_in1 = numInputMSFs(1);
numMSFs_in2 = numInputMSFs(2);
numMSFs_in3 = numInputMSFs(3);
