%% A MATLAB tutorial for seizure prediction
% The tutorial is built upon a winning solution from a previous Kaggle
% Competition (https://www.kaggle.com/c/seizure-prediction).
% The code is prepared by:
%   -Arunesh Mittal, Department of Biomedical Engineering, Columbia University, New York, NY 10027, and
%   -Jianghao Wang, PhD, The Mathworks, Inc., Natick, MA 01760
%
% Reference:
%   - http://brain.oxfordjournals.org/content/early/2016/03/29/brain.aww045
%   for details of the description of the algorithm;
%
%   - https://github.com/drewabbot/kaggle-seizure-prediction
%   for details of the implementation of the original algorithm. Licensing
%   information can be found here at:
%   - https://github.com/drewabbot/kaggle-seizure-prediction/blob/master/LICENSE
%
% Copyright 2016 The MathWorks, Inc.
%
%% Get started
close all; clear;  clc;
% Customize the following paths to where you store your data
dataDir      = '/project/ece601/Data/';      % data directory
featureDir   = '/project/ece601/Feature/';  % feature directory
modelDir     = '/project/ece601/Model/';    % model directory

if ~exist(dataDir,'dir')
    mkdir(dataDir)
elseif ~exist(featureDir,'dir')
    mkdir(featureDir)
elseif ~exist(modelDir,'dir')
    mkdir(modelDir)
end

% In total there are three patients
subjectNames = {'train_1','train_2','train_3','test_1','test_2','test_3'};
segmentTypes = {'0','1'}; % Preictal (1) or interictal (0)


%% A complete workflow consists of four steps

%% 1) Compute a set of features for the training and the test data.
%    Features of the training data will be later on used to train a LASSO
%    GLM model. And the trained model will be used to make predictions
%    based on features of the test data.
opt.dataDir     = dataDir;
opt.featureDir  = featureDir;
opt.clustername = 'local';  % Or other clusters
% Uncomment the following two lines if calling a non-local cluster
% opt.numChunk    = 50;       % Process data by chunk to avoid overhead in parallel computing
% opt.N           = 64;
step1_generate_features(subjectNames(1:6),segmentTypes,opt);

%% 2) Train a LASSO GLM based on features of the training data.
%     70% of the training data is actually used to train the model.
%     The remaining 30% will be used as validation data in step 3) for model
%     assessment.
opt.modelDir   = modelDir;
opt.trainSplit = 0.7;      % percentage of data for training
opt.cv_k       = 5;        % k-fold cross validation, in this case k = 5
step2_generate_models(subjectNames(1:3),segmentTypes,opt);

%% 3) Model assessment
%     Evaluate the performance of the LASSO GLM. Go back to step 2 and tune
%     model parameters if necessary.
%
% Set threshold for classification
% If predicted value > 0.5, classify to preictal (1); otherwise classify to
% interictal (0).
opt.thres                    = 0.5;   % modify according to your experience.
opt.submissionFile           = 'sample_submission.csv';
% NOTE: make sure the submission file is closed when executing MATLAB code.
% Otherwise MATLAB won't be able to open submissionFile for writing.
step3_evaluate_models(subjectNames(1:3),opt);

%% 4) Make seizure Prediction
%     Prediction is made on test data, with the model trained from step 2.
%
% No need to calculate features if already did in step 1)
opt.calculate = false;
tb            = step4_predict_seizure(subjectNames(4:6),opt);
