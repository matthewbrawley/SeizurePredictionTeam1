%% Workflow Script, view ReadME for more information
%% Get started
close all; clc;
% Customize the following paths to where you store your data
dataDir      = 'data';      % data directory
featureDir   = 'Features';  % feature directory
modelDir     = 'Models';    % model directory
% Check if directories exist.
if ~exist(dataDir,'dir')
    mkdir(dataDir)
elseif ~exist(featureDir,'dir')
    mkdir(featureDir)
elseif ~exist(modelDir,'dir')
    mkdir(modelDir)
end

% For current purpose we are sending in one patient.
subjectNames = {'test_3'};
segmentTypes = {'0','1'}; % Preictal (1) or interictal (0)

%% 1) Compute a set of features for the test data.
%    The trained model will be used to make predictions
%    based on features of the test data.
opt.dataDir     = dataDir;
opt.featureDir  = featureDir;
opt.clustername = 'local';  % Or other clusters

step1_generate_features(subjectNames,segmentTypes,opt);

%% 2) This step would generate a model.
%     This model has already been generated, however, it should be in 
%     the model directory.
opt.modelDir   = modelDir;
opt.trainSplit = 0.7;      % percentage of data for training
opt.cv_k       = 5;        % k-fold cross validation, in this case k = 5
%step2_generate_models(subjectNames(1:3),segmentTypes,opt);

%% 3) Model assessment
%     This step would evaluate the performance of the LASSO GLM. 
%     This has already been done though.
%
% Set threshold for classification
% If predicted value > 0.4, classify to preictal (1); otherwise classify to
% interictal (0).
opt.thres                    = 0.4;   % modify according to your experience.
%training_label = step3_evaluate_models(subjectNames(1:3),opt);

%% 4) Make seizure Prediction
%     Prediction is made on test data, with the provided trained model.
%
% No need to calculate features if already did in step 1
opt.calculate = false;
testing_label    = step4_predict_seizure(subjectNames,opt);

