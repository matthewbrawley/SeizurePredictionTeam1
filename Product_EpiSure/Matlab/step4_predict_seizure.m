function label = step4_predict_seizure(subjectNames,options)
% STEP4_PREDICT_SEIZURE(SUBJECTNAMES,OPTIONS) predicts whether a test
%   segment is preictal (1) or interictal (0)
%   The basic idea is:
%      a) calculate features (if not already done)
%      b) load trained lassoGLM model
%      c) make predictions with the trained models
%      d) save results in a databse to update app and notify patient
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

%% a) Generate features for test data
% If necessary, calculate features
if calculate
    segmentTypes = '';
    step1_generate_features(subjectNames,segmentTypes,options);
end
%% b) Make predictions
savePath = fullfile(modelDir);
for i = 1:length(subjectNames) % loop over patients if more than 1
    
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
    
    %Open Database Connection
    conn = database.ODBCConnection('MySeizureData','root','root'); % open a database connection
    
    %make the cursor point after last row of data
    curs = exec(conn,'select * from seizure_data');
    curs = fetch(curs);
    %curs.Data
    
    colnames = {'patient_id','file_name','class','time_stamp'};
    tablename = 'seizure_data';
    
    exp_name = {fileNames(:).name};
    
    %save the data to database
    for k = 1:numFiles
        data = {patientId,exp_name(i),double(label(k)),{datestr(now,'yyyy-mm-dd HH:MM:SS')}};
        data_table = cell2table(data,'VariableNames',colnames);
        fastinsert(conn,tablename,colnames,data_table);
    end
    
    save([savePath filesep subjectName '_predict'],'label','exp_name')
    % disp(sum(label))
    
end

%close database connection
close(curs);
close(conn);

end
