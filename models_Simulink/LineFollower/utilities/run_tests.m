function [ output_args ] = run_tests()

mdl = 'tests';

load_system(mdl);

set_param(strcat(mdl, ''), '', '0');


sim(mdl);

close_system(mdl, 0);

end

