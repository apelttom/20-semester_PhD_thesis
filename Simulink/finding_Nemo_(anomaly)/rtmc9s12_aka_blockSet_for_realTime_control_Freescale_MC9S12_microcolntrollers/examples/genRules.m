% generate i/p MSF, o/p MSF 
% and a rule base that implements an addition of input variables

% output filenames
Rname = 'rb_3i1o.txt';
Oname = 'y_3i1o.txt';
I1name = 'x1_3i1o.txt';
I2name = 'x2_3i1o.txt';
I3name = 'x3_3i1o.txt';

%%%%%%%%%%%
% Rule base
%%%%%%%%%%%
fid = fopen(Rname, 'w');

% input fuzzy values
Fi = { 'N2' 'N1' 'Z' 'P1' 'P2'; ...
       'N2' 'N1' 'Z' 'P1' 'P2'; ...
       'N2' 'N1' 'Z' 'P1' 'P2' };
   
% % input fuzzy values
% Fi = { 'N3' 'N2' 'N1' 'Z' 'P1' 'P2' 'P3'; ...
%        'N3' 'N2' 'N1' 'Z' 'P1' 'P2' 'P3'; ...
%        'N3' 'N2' 'N1' 'Z' 'P1' 'P2' 'P3' };

% number of i/p MSF
Ni = size(Fi,2);

% number of inputs
n = size(Fi,1);

% indices of i/p MSF (e.g.: -2 -1 0 1 2)
Di = -(size(Fi,2)-1)/2:(size(Fi,2)-1)/2;

% centres of o/p MSF
Co = [-1:2/(Ni-1)/n:1];

% labels of o/p MSF
Lo = cell(length(Co),1);
for i = 1:length(Co)
    Lo{i} = ['C' num2str(i)];
end

% print rule table header (# i/p variables, # o/p MSF)
fprintf(fid, [num2str(n) ' ' num2str(length(Co)) '\n\r']);

% loop through inputs
dCo = min(diff(Co))/2;
for i = 1:Ni
    for j = 1:Ni
        for k = 1:Ni
            kk = (Di(i) + Di(j) + Di(k))*2/(Ni-1)/n;
            % get associated o/p centre name (robust version)
            LLo = Lo{find(abs(Co-kk) < dCo)};
            fprintf(fid, [Fi{1,i} ' ' Fi{2,j} ' ' Fi{3,k} ' ' LLo '\n\r']);
        end
    end
end

fclose(fid);


%%%%%%%%%%%
% o/p MSF
%%%%%%%%%%%
fid = fopen(Oname, 'w');

% number of o/p MSF
fprintf(fid, [num2str(length(Co)) '\n\r']);

% optional: non-linear distribution of o/p centres
%CoNL = 2*Co + 5*sign(Co).*Co.^4;
CoNL = Co + 5*sign(Co).*Co.^4;

% define o/p MSF
if(exist('CoNL'))
    dC = diff(CoNL);
    dC = [dC(1) dC dC(end)];
    for i = 1:length(CoNL)
        fprintf(fid, ['C' num2str(i) ' ' num2str(CoNL(i)-dC(i)) ' ' ...
                          num2str(CoNL(i)) ' ' num2str(CoNL(i)) ' ' num2str(CoNL(i)+dC(i+1)) '\n\r']);
    end
else
    for i = 1:length(Co)
        fprintf(fid, ['C' num2str(i) ' ' num2str(Co(i)-2/(Ni-1)/n) ' ' ...
            num2str(Co(i)) ' ' num2str(Co(i)) ' ' num2str(Co(i)+2/(Ni-1)/n) '\n\r']);
    end
end

fclose(fid);


%%%%%%%%%%%
% i/p MSF
%%%%%%%%%%%

% loop through all i/p MSF
for(k = 1:n)
    
    % open file
    % eval(['fid = fopen(I' num2str(k) 'name, ''w'');']);
    fid = feval(@fopen, eval(['I' num2str(k) 'name']), 'w');

    % number of i/p MSF
    fprintf(fid, [num2str(Ni) '\n\r']);
    
    % normalized centres
    Ci = [-1:2/(Ni-1):1];
    di = Ci(2) - Ci(1);        % distance between adjacent centres

    % define o/p MSF
    for i = 1:Ni
        fprintf(fid, [Fi{k,i} ' ' num2str(max(-1, Ci(i)-di)) ' ' ...
                      num2str(Ci(i)) ' ' num2str(Ci(i)) ' ' num2str(min(1, Ci(i)+di)) '\n\r']);
    end

    fclose(fid);
    
end
