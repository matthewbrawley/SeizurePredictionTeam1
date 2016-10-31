function step2_generate_models(subjectNames,segmentTypes,options)
% STEP2_GENERATE_MODELS trains a LASSO GLM model using features from step 1.
%    Input:
%       subjectNames:
%           Patient to look at (strings or cell strings). e.g. {'train_1'}
%       segmentTypes:
%           Preictal (1) or interictal (0) (strings). e.g. {'0','1'}
%       Options:
%           featureDir:
%                 directory name of where feature data is stored (string)
%           modelDir:
%                 directory name of where model data will be stored (string)
%           trainSplit:
%                 percentage of training data to be used to train model (numeric)
%                 Think carefully before deciding to use 100%. You may want to
%                 retain some to check out-of-sample skill. 
%                 By default trainSplit = 0.7
%           cv_k:
%                 k-fold cross-validation. By default cv_k = 5.
%
%    See also calculate_features, lassoGLM
%
%    Copyright 2016 The MathWorks, Inc.
%
%% Options
fopts = fieldnames(options);

if sum(strcmp(fopts,'featureDir'))~=0
    featureDir = options.featureDir;
else
    error('Please specify the output feature location.')
end

if sum(strcmp(fopts,'modelDir'))~=0
    modelDir = options.modelDir;
else
    error('Please specify the output model location.')
end

if sum(strcmp(fopts,'trainSplit'))~=0
    trainSplit = options.trainSplit;
else
    trainSplit = 0.7;
end

if trainSplit > 1 || trainSplit < 0
    error('trainSplit must be a number within [0 1]')
end

if sum(strcmp(fopts,'cv_k'))~=0
    cv_k = options.cv_k;
else
    cv_k = 5;
end

if ~iscell(subjectNames) && ischar(subjectNames)
    subjectNames = cellstr(subjectNames);
end

%% Setup the design matrix
for i = 1:length(subjectNames)
    C = {}; C_VAL = {};
    n = 1; m = 1;
    
    for j = 1:length(segmentTypes)
        subjectName = subjectNames{i};
        segmentType = segmentTypes{j};
        sourceDir = [featureDir filesep subjectName];
        fileNames = dir([sourceDir filesep '*' segmentType '.mat']);
        numFiles = length(fileNames);
        
        population = nan(numFiles,1);
        for k = 1:numFiles
            tmp = regexp(fileNames(k).name,'_','split');
            population(k) = str2double(tmp{2});
        end
        
        trainIdx = sort(randsample(population,floor(trainSplit * numFiles)))';
        valIdx =  setdiff(1:numFiles,trainIdx);
        
        disp(['Segment Type ' num2str(j) ', load training data...'])
        for k = trainIdx
            fileName   = [subjectName(end) '_' num2str(k) '_' segmentType];
            % fileName = strrep(fileNames(k).name,'.mat','');
            filePath = fullfile(featureDir, subjectName, fileName);
            f = load(filePath);
            % disp(filePath);
            C{n,1} = [f.feat j-1 k];
            n = n + 1;
        end
        
        disp(['Segment Type ' num2str(j) ', load validation data...'])
        for k = valIdx
            fileName   = [subjectName(end) '_' num2str(k) '_' segmentType];
            % fileName = strrep(fileNames(k).name,'.mat','');
            filePath = fullfile(featureDir, subjectName, fileName);
            f = load(filePath);
            % disp(filePath);
            C_VAL{m,1} = [f.feat j-1 k];
            m = m + 1;
        end
    end
    X_train = cell2mat(C);
    
    Yind_train    = X_train(:,end);
    Ylabel_train  = X_train(:,end-1);
    X_train       = X_train(:,1:end-2);
    
    % Also save VAL data for verification
    % C_VAL(cellfun('isempty',C_VAL)) = [];
    X_VAL       = cell2mat(C_VAL);
    Yind_VAL    = X_VAL(:,end);
    Ylabel_VAL  = X_VAL(:,end-1);
    X_VAL       = X_VAL(:,1:end-2);
    
    % Construct a regularized binomial regression
    disp('Construct a regularized binomial regression with Lasso GLM:')
    [B,FitInfo] = lassoglm(X_train,Ylabel_train,'binomial','CV',cv_k,'RelTol',5e-2,'Options',statset('UseParallel',true));
    
    
    %% Store model to output dir
    savePath = fullfile(modelDir);
    save([savePath filesep subjectName],'B', 'FitInfo','X_train','X_VAL','Yind_train','Yind_VAL','Ylabel_train','Ylabel_VAL');
end
p = gcp('nocreate');
if ~isempty(p)
    delete(p);
end

end