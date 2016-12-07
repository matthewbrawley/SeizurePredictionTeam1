function step1_generate_features(subjectNames,segmentTypes,options)
% step1_GENERATE_FEATURES genearates a set of features that will be
%    compared against a trained LASSO GLM model.
%
%    Input:
%       subjectNames:
%           Patient to look at (cell strings). e.g. {'test_3'}
%       segmentTypes:
%           Preictal (1) or interictal (0) (string). e.g. {'0','1'}
%       Options:
%           dataDir:
%                directory name of where (input) data is stored (string)
%           featureDir:
%                directory name of where output feature data will be stored (string)
%           clustername (optional):
%                name of the cluster to be used for parallel computing.
%                By default, clustername = 'local';
%           N (optional)
%                Preferred number of workers in a parallel pool.
%
%    See also parfor, parpool, gcp.
%
%    Copyright 2016 The MathWorks, Inc.
%
%% Options
fopts = fieldnames(options);

if sum(strcmp(fopts,'dataDir'))~=0
    dataDir = options.dataDir;
else
    error('Please specify the input data location.')
end

if sum(strcmp(fopts,'featureDir'))~=0
    featureDir = options.featureDir;
else
    error('Please specify the output feature location.')
end

if sum(strcmp(fopts,'clustername'))~=0
    clustername = options.clustername;
else
    clustername = 'local';
end

if ~strcmp(clustername,'local')
    if sum(strcmp(fopts,'N'))~=0
        N = options.N;
    else
        error('Please specify preferred number of workers in a parallel pool.')
    end
end

if ~strcmp(clustername,'local')
    if ~strcmp(fopts,'numChunk')
        error('Please specify the number of data chunks.')
    else
        numChunk    = options.numChunk;
    end
end

if ~iscell(subjectNames)
    subjectNames = cellstr(subjectNames);
end

if isempty(segmentTypes) % meaning that it's a test data segment
    segmentTypes = {'*'};
elseif ~iscell(segmentTypes)
    error('Input must be a cell string. Use num2str for conversion.')
end


%% Read data, compute and save features, for loop for more than one test subject
for i = 1:length(subjectNames)
        % Specify patient to look at
        subjectName = subjectNames{i};
       
        % Read and count number of files associated with this segment type
        sourceDir = [dataDir filesep subjectName];
        fileNames = dir([sourceDir filesep '*'  '.mat']);
        numFiles = length(fileNames);
        FileNames = {fileNames(:).name};
        FilePaths = fullfile(dataDir, subjectName, FileNames);
        savePath = fullfile(featureDir, subjectName);
        if ~isdir(savePath)
            mkdir(savePath);
        end
        
        %% Calculate features using parallel toolbox (cluster on the server)
        p = gcp('nocreate');
            %% Calculate features using parallel toolbox (local cluster)
            if isempty(p)
                p = parpool('local');
            else
                p = gcp;
            end
            disp('Start feature calculation on local workers...')
            parfor k = 1:numFiles
                
                % Load and display the file being read.
                fileName = strrep(fileNames(k).name,'.mat','');
                filePath = fullfile(dataDir, subjectName, fileNames(k).name);
                f = load(filePath);
                disp(filePath);
                
                % Calculate features
                feat = calculate_features(f);
                
                % Store features to featureDir
                parsave([savePath filesep fileName],'feat',feat);
            end
            disp(['Done. Saved all features to ' savePath])
            
        end
    

p = gcp('nocreate');
if ~isempty(p)
    delete(p);
end

end


function parsave(filepath, varStr, var)
evalc([varStr '=' 'var']);
save(filepath, varStr);
end

