

% A little Matlab script to set some parameters.  Avoids 
% excessive command strings in a qsub script.
warning('off', 'MATLAB:maxNumCompThreads:Deprecated') ; 
maxNumCompThreads(nslots) ;
parpool(nslots) ;  
disp('Running on the SCC...') ; 





 
