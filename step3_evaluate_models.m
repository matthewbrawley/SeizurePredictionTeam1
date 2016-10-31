function tb = step3_evaluate_models(subjectNames,options)
% STEP3_EVALUATE_MODELS evaluate the trained LASSO GLM
%   See how well it does on the training data
%       and how good it makes prediction on validation data
%   Save prediction to the submission file.
%
%   Input:
%       subjectNames:
%           Patient to look at (strings or cell strings). e.g. {'train_1'}
%       Options:
%           dataDir:
%                 directory name of where (input) data is stored (string)
%           featureDir:
%                 directory name of where feature data is stored (string)
%           modelDir:
%                 directory name of where model data will be stored (string)
%           thres:
%                 threshold of whether classifying to preictal(1) or interictal(0)
%                 preictal: when prediction > thres
%                 interictal: when prediction < thres
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
%   See also table, writetable, glmval, lassoplot, perfcurve.
%
%   Copyright 2016 The MathWorks, Inc.
%
%% Options
fopts = fieldnames(options);

if sum(strcmp(fopts,'dataDir'))~=0
    dataDir = options.featureDir;
else
    error('Please specify the input data location.')
end

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

if sum(strcmp(fopts,'thres'))~=0
    thres = options.thres;
else
    thres = 0.5;
end

if sum(strcmp(fopts,'submissionFile'))~=0
    submissionFile = options.submissionFile;
else
    error('Please download sample_submission.csv from Kaggle and have it in current working directory.')
end

if ~iscell(subjectNames) && ischar(subjectNames)
    subjectNames = cellstr(subjectNames);
end

for i = 1:length(subjectNames)
    
    % Options
    subjectName = subjectNames{i};
    disp(['--- Process ' subjectName ' ---'])
    sourceDir   = [dataDir filesep subjectName];
    fileNames   = dir([sourceDir filesep '*.mat']);
    numFiles    = length(fileNames); 
    % Load models
    fileName    = [modelDir filesep subjectName];
    load(fileName)
    
    lassoPlot(B,FitInfo,'PlotType','CV');
    indx = FitInfo.IndexMinDeviance;
    
    B0 = B(:,indx);
    cnst = FitInfo.Intercept(indx);
    B1 = [cnst;B0];
    
    % Make predictions
    Ypreds_train = glmval(B1,X_train,'logit');
    
    label_train = Ypreds_train > thres;
    % plot residuals
    histogram(Ylabel_train - Ypreds_train)
    title('Residuals from lassoglm model')
    
    %% Plot ROC curve for classification by lasso GLM
    [roc_X,roc_Y,~,auc] = perfcurve(Ylabel_train,Ypreds_train,1);
    figure;
    plot(roc_X,roc_Y)
    xlabel('False positive rate')
    ylabel('True positive rate')
    title('Training ROC for Classification by LASSO GLM')
    % Display the area under the curve
    disp('The maximum AUC is 1, which corresponds to a perfect classifier.')
    disp('Larger AUC values indicate better classifier performance.')
    disp(['Trained LassoGLM with training data has an AUC of ' num2str(auc) '.'])
    
    %% Check how well the model performs on validation data
    Ypreds_VAL = glmval(B1,X_VAL,'logit');
    label_VAL  = Ypreds_VAL > thres;

    % Plot ROC curve for classification by lasso GLM
    [roc_X_VAL,roc_Y_VAL,~,auc_VAL] = perfcurve(Ylabel_VAL,Ypreds_VAL,1);
    figure;
    plot(roc_X_VAL,roc_Y_VAL)
    xlabel('False positive rate')
    ylabel('True positive rate')
    title('Validation ROC for Classification by LASSO GLM')
    % Display the area under the curve
    disp('The maximum AUC is 1, which corresponds to a perfect classifier.')
    disp('Larger AUC values indicate better classifier performance.')
    disp(['Trained LassoGLM with validation data has an AUC of ' num2str(auc_VAL) '.'])
    
    %% Make prediction on the whole training dataset and save results (file names and labels)
    C = cell(numFiles,1);
    for k = 1:numFiles
        fileName = strrep(fileNames(k).name,'.mat','');
        filePath = fullfile(featureDir, subjectName, fileName);
        f = load(filePath);
        % disp(filePath);
        C{k,1} = f.feat;
    end
    X = cell2mat(C);

    Ypreds = glmval(B1,X,'logit');    
    label  = Ypreds > thres;
    exp_name = {fileNames(:).name}';
    % label    = [label_train; label_VAL];
    % exp_name = {fileNames([Yind_train; Yind_VAL]).name}';
    % disp(sum(label))
    save([modelDir filesep subjectName '_predict'],'label','exp_name')
    % save labels into the submission csv file
    tb              = readtable(submissionFile,'Delimiter','comma');
    file            = tb.File;
    [~,ind]         = intersect(file,exp_name);
    tb.Class(ind)   = label;
    writetable(tb,submissionFile,'Delimiter','comma');
end
%% Look at other verification statistics
% Training error rate, test error rate, confusion matrix, etc.
%
%  Add your code here
%
% If results are not satisfying, go back to step 2 and tune the lasso GLM
% model.
end