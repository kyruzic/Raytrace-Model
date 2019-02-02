function gainDat = getGain(pathToGain)
% Name:
%     getGain
%
% Author:
%     Kyle Ruzic
%
% Date: 
%     August 22nd 2018
%
% Purpose: 
%     load gain from data file this is a seperate function to make
%     it easier to change how this is handled in the future, so
%     that other radars gain patterns can be used
%
% Inputs: 
%     pathToGain - path to where gain file is saved
% 
% Outputs: 
%     gainDat    - array of gain pattern 

    gainDat = load(pathToGain);