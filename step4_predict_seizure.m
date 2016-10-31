function tb = step4_predict_seizure(subjectNames,options)
% STEP4_PREDICT_SEIZURE(SUBJECTNAMES,OPTIONS) predicts whether a test
%   segment is preictal (1) or interictal (0)
%
%   Proceed to this step once you are satisfied with results from the
%   previous steps.
%
%   The basic idea is:
%      a) calculate features as in step 1)
%      b) load trained lassoGLM model from step 2)
%      c) make predictions with the trained models
%      d) save results in a spreadsheet for submission
%
%   Input:
%       subjectNames:
%           Patient to look at (strings or cell strings). e.g. {'train_1'}
%       Options:
%           featureDir:
%                 directory name of where feature data is stored (string)
%           modelDir:
%                 directory name of where model data will be stored (string)
%           thres:
%                 threshold of whether classifying to preictal(1) or interictal(0)
%                 preictal: when prediction > thres
%                 interictal: when prediction < thres
%                 By default, thres = 0.5
%           calculate:
%                 logical entry (1 or 0; true or false) to specify whether
%                 or not calculating features before making predictions.
%           submissionFile:
%                 submission file that stores file and label information.
%                 By default, submissionFile = 'sample_submission.csv' (downloaded from Kaggle).
%
%   Output:
%       tb: table structure that contains file names (column 1) and labels (column 2). 
%       Format and number of variables in tb is identical to the submissionFile.
%       label should be either 1 (preictal) or 0 (interictal).
%       Use writetable(tb) to convert a table to csv file.
%
%   See also table, writetable.
%
%   Copyright 2016 The MathWorks, Inc.
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
    error('Please specify the output feature location.')
end

if sum(strcmp(fopts,'thres'))~=0
    thres = options.thres;
else
    thres = 0.5;
end

if sum(strcmp(fopts,'calculate'))~=0
    calculate = options.calculate;
else
    calculate = true;
end

if ~iscell(subjectNames)
    subjectNames = cellstr(subjectNames);
end

if sum(strcmp(fopts,'submissionFile'))~=0
    submissionFile = options.submissionFile;
else
    error('Please download sample_submission.csv from Kaggle and have it in current working directory.')
end

%% a) Generate features for test data
% Repeat what was done in step 1
if calculate
    segmentTypes = '';
    step1_generate_features(subjectNames,segmentTypes,options);
end
%% b) Make predictions
savePath = fullfile(modelDir);
for i = 1:length(subjectNames) % loop over patients
    
    % Specify patient to look at
    subjectName = subjectNames{i};
    disp(['--- Process ' subjectName ' ---'])
    
    % Load features of test data
    sourceDir = [featureDir filesep subjectName];
    fileNames = dir([sourceDir filesep '*.mat']);
    numFiles = length(fileNames);
    
    disp('Load features just calculated...')
    for k = 1:numFiles
        % fileName = [num2str(i) '_' num2str(k) '_' num2str(segmentType)];
        fileName = strrep(fileNames(k).name,'.mat','');
        filePath = fullfile(featureDir, subjectName, fileName);
        f = load(filePath);
        % disp(filePath);
        C{k,1} = f.feat;
    end
    X_test = cell2mat(C);
    
    % Load the trained LASSO GLM model
    disp('Load trained model...')
    modelName = ['train_' subjectName(end)];
    model = load([savePath filesep modelName]);
    indx = model.FitInfo.IndexMinDeviance;
    
    B0 = model.B(:,indx);
    cnst = model.FitInfo.Intercept(indx);
    B1 = [cnst;B0];
    
    % Make predictions
    disp('Make prediction of test data label...')
    Ypreds = glmval(B1,X_test,'logit');
    
    % Decide whether it is preictal or ictal
    % Note: thres (threshold) can be modified.
    label    = Ypreds > thres;
    
    exp_name = {fileNames(:).name};
    save([savePath filesep subjectName '_predict'],'label','exp_name')
    % disp(sum(label))
    
    % save labels into the submission csv file
    tb              = readtable(submissionFile,'Delimiter','comma');
    file            = tb.File;
    [~,ind]         = intersect(file,exp_name);
    tb.Class(ind)   = label;
    writetable(tb,submissionFile,'Delimiter','comma');
    
end

end