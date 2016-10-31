function step1_generate_features(subjectNames,segmentTypes,options)
%STEP1_GENERATE_FEATURES genearates a set of features that will be
%    later on used to train a LASSO GLM model.
%
%    Input:
%       subjectNames:
%           Patient to look at (cell strings). e.g. {'train_1'}
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
%           numChunk (optional):
%                ONLY REQUIRED IF USING A NON-LOCAL CLUSTER for parallel computing
%                Process data by chunk to enhance code performance. Users should
%                specify the number of chunks to be processed. In each chunk to
%                be processed, there will be # = number of files / numChunk data files.
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


%% Read data, compute and save features
for i = 1:length(subjectNames)
    for j = 1:length(segmentTypes)
        
        % Specify patient to look at
        subjectName = subjectNames{i};
        % Specify segment type
        segmentType = segmentTypes{j};
        
        % Read and count number of files associated with this segment type
        sourceDir = [dataDir filesep subjectName];
        fileNames = dir([sourceDir filesep '*' segmentType '.mat']);
        numFiles = length(fileNames);
        FileNames = {fileNames(:).name};
        FilePaths = fullfile(dataDir, subjectName, FileNames);
        savePath = fullfile(featureDir, subjectName);
        if ~isdir(savePath)
            mkdir(savePath);
        end
        
        %% Calculate features using parallel toolbox (cluster on the server)
        p = gcp('nocreate');
        if ~isempty(clustername) && ~strcmp(clustername,'local') % && ~strcmp(p.Cluster.Profile,'local')
            % Only start a parpool if there isn't an existing one
            if isempty(p)
                p = parpool(clustername, N);
                % Otherwise use the one that's already open
            else
                N = p.NumWorkers;
            end
            
            % Process data by chunk to avoid large data overhead
            chunkSize = max(floor(numFiles/numChunk),N);
            numChunk  = floor(numFiles/chunkSize);
            
            for m = 1:numChunk
                if m < numChunk
                    num = (m-1)*chunkSize + 1:m*chunkSize;
                else
                    num = (m-1)*chunkSize + 1:numFiles;
                end
                n = 1;
                f = cell(size(num));
                
                for k = num
                    % Load and display the file being read.
                    f{n} = load(FilePaths{k});
                    n = n + 1;
                    disp(FilePaths{k})
                end
                
                % NOTE: "parfor" is the parallel equivalent to "for". Type
                %       "doc parfor" in the Command Window to learn more about
                %       how "parfor" works.
                %
                %       If one does not want to use the parallel computing toolbox,
                %       simply replace "parfor" by "for" to execute the for look on a
                %       single worker (not recommended).
                
                disp(['Calculating features of data in chunk ' num2str(m) '...'])
                parfor k = 1:length(num)
                    % Load data and calculate features.
                    f_in = f{k};
                    feat_num{k} = calculate_features(f_in);
                    % fileName = fileNames(num(k)).name;
                    % disp(fileName)
                    
                end
                disp('Done!')
                
                for k = 1:length(num)
                    fileName = fileNames(num(k)).name;
                    feat = feat_num{k};
                    save([savePath filesep fileName],'feat')
                end
                disp(['Saved all features to ' savePath])
            end
            
        else
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
    end
    
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

