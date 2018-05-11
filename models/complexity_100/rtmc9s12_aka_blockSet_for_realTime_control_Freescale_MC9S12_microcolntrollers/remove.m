% Remove all traces of the rtmc9S12_CW_R2008a from the MATLAB path.
% once run, it will be safe to delete the rtmc9S12 directory.
% possibly remove previous installations from the MATLAB path,
% by deleting any paths that contain *rtmc*
oldinstpath = regexp(path,'[:\\\/\w- ]*rtmc[:\\\/\w- ]*','match');
if ~isempty(oldinstpath)
  cellfun(@rmpath,oldinstpath);
end

savepath;
rehash;

display('rtmc9S12 has been removed from the MATLAB path.');
display('You may now delete the rtmc9S12_CW_R2008a directory.');