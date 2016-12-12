# SeizurePredictionTeam1
Product Name: 
EpiSure

Description: 
A team of students in Boston University's Graduate Program in Electrical and Computer Engineering use EEG signal data to predict seizures in patients with epilepsy. Develop an Android Application to notify patient of pre-seizure status before seizure onset, using provided data as a real-time input.

1) Types of files involved:
	1.1) Train files: Matlab files containing 16 channel EEG data. The LASSO GLM Models have been trained/ generated based on these files.
	1.2) Test files: Matlab files containing 16 channel EEG data. These files are assumed to be the incoming real time EEG data from the patient.

2) Running the MATLAB code:
	2.1) Back-end tasks (Already evaluated):
	2.1.1) Computation of the features array for the train files: Extracts certain aspects of the signals which may help categorising them as preictal or interictal.
	2.1.2) Creation of the LASSO GLM model based on the train files: Takes an EEG file and determines which stage the EEG depicts.
	2.1.3) Evaluation of the model based on train files: Checks against a threshold to determine whether the files show a preictal or interictal stage. We have pre-run Steps 1 to 3 for the Train data and hence, we have the LASSO GLM model ready.
	
	2.2) Checking for seizures in  the incoming EEG files (To be run by USER):
	STEP 1:
	We have to store the following files in the current directory of MATLAB:
	2.2.1) Trained model (File name: 'train_3')
	2.2.2) Folder containing Test files (Folder name: 'data') 
	2.2.3) MATLAB scripts
		i)   Episure_workflow.m
		ii)  step1_generate_features.m
		iii) step4_predict_seizure.m
		iv)  calculate_features.m
	STEP 2:
	Then we 'Run' the Episure_workflow.m, which will:
	-> Compute the features array for the test files
	-> Evaluate the model based on test files: To determine whether the test files show a preictal or interictal stage
3) Running the Android app
	3.1) New User- Registration
		3.1.1) On opening the app, we click on 'New User' at the bottom, for the patient registration.
		3.1.2) The patient enters their details (Name, email id, address, password) and checks the Terms and Conditions
	3.2) Existing User- Login
		3.2.1) The User logs in using the Username and password entered during registration and hits 'Log In'.
		3.2.2) Forgot password screen: In case the patient forgets the password, the 'Forgot Password' button sends a new password to the email id given by the user.
		3.2.3) In the next screen, the Patient adds the details of the Emergency Contact by clicking on 'Add/ Edit Emergency Contact'. This provides the patient with 2 options, either to enter the name and phone number on their own, or choose from the phone contacts list. To save the details, the patient hits the 'Submit' button. The next dialog box requests for confirmation before adding the Emergency contact.

4) Updates
	4.1) As soon as the Signal Processing part (Section 2) detects a seizure, the Android application sends a notification to the patient and emergency contacts' phones. 
