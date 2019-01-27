%           Author: Anany Dwivedi
%           Date  : Oct-12-18
%           The University of Auckland
%      This is a script to perform PC Analysis on the Evoked Response
%% File Setup
clc;
clear all;
close all;
addpath('myEEG_lib\');              %Path to User Defined Functions
%% Path Def
% MainFolder = {'/Users/luke/EEG_data/'};
% SubFolder = {'2018 05 25'};
% Subjects = {'LH','YJ'};
MainFolder = {'Data'};
SubFolder = {'20180525'};
Subjects = {'LH','YJ'};
Subjects = {'YJ'};
FirstFile = 1;
LastFile = 10;

FileToBeProcessed = FirstFile:LastFile;             %File Numbers
NumFiles = length(FileToBeProcessed);
%% Important Variables for Processing

TotalChannels = 8;                                  %Number of Electrode Channels used
%Trigger Related
TriggerChannel = 9;                                 %Channel for the Trigger
NumTriggers = 12;                                   %Number of Triggers Expected in the Data
TriggerGap = 3.5;                                   %The Gap (approx) in Triggers (To remove inter trial False Trigger)
FirstTrigger = 12;                                  %Approx time of the First Trigger
Fs = 1200;                                          %Sampling Freq

%Signal Processing Related

%Stimuli Characteristics
DurationStim_s = 2;

CSVREAD_IX_ROW = 1;
CSVREAD_IX_COL = 0;
%% Read Files
TotalItr = length(Subjects)*NumFiles*NumTriggers*TotalChannels;
SubjectItr = NumFiles*NumTriggers*TotalChannels;

TotalItrCompleted = 0;
SubjectItrCompleted = 0;
Acc_subj = [];
for sub = 1:length(Subjects)
    SubjectItrCompleted = 0;
DURATION_RESPONSE_SAMPLES = Fs*1;
    AllEvokedOn = zeros(NumFiles*NumTriggers,DURATION_RESPONSE_SAMPLES,TotalChannels);
    AllEvokedOff = zeros(NumFiles*NumTriggers,DURATION_RESPONSE_SAMPLES,TotalChannels);
    idx = 1;                    % To iterate the index of number of Stimuli
    for f = 1:NumFiles
        FileName = strcat('Exp',' ',int2str(FileToBeProcessed(f)),'.csv');
        FilePath = fullfile(MainFolder,SubFolder,Subjects{sub},FileName);
        FilePath = cell2mat(FilePath);
        Data = csvread(FilePath,CSVREAD_IX_ROW,CSVREAD_IX_COL);
        
        % Clean the Trigger Data
    	[Trigger Trigger_sec] = cleanTrigger(Data(:,TriggerChannel),TriggerGap,FirstTrigger,NumTriggers,Fs);
        
        for i = 1:length(Trigger)
            for ch = 1:TotalChannels
                AllEvokedOn(idx,:,ch) = Data(Trigger(i):(Trigger(i)+DURATION_RESPONSE_SAMPLES-1),ch);
                AllEvokedOff(idx,:,ch) = Data((Trigger(i)-Fs*DurationStim_s):((Trigger(i)-Fs*DurationStim_s)+DURATION_RESPONSE_SAMPLES-1),ch);
                
                TotalItrCompleted = TotalItrCompleted + 1;
                SubjectItrCompleted = SubjectItrCompleted + 1;
                processInfo(FileName,Subjects{sub},SubjectItrCompleted,SubjectItr,TotalItrCompleted,TotalItr)
                end
            idx = idx + 1;
        end % trigger
    end % files

    Acc_comp = [];
    d = {AllEvokedOn(:,:,1),AllEvokedOn(:,:,2),AllEvokedOn(:,:,3),AllEvokedOn(:,:,4),...
        AllEvokedOn(:,:,5),AllEvokedOn(:,:,6),AllEvokedOn(:,:,7),AllEvokedOn(:,:,8)};
    figure
    for pc = 2:240
        Acc = AnalysePCA(d,pc,1);
        Acc_comp = [Acc_comp;Acc];
        clf
        plot(2:pc,Acc_comp,'*k','MarkerSize',4)
        hold on; 
        plot(0:pc,ones(pc+1,1)*25,'--r')
        axis([0 pc 0 100])
        pause(0.1);
    end
    figure,plot(2:240,Acc_comp,'*k','MarkerSize',4);hold on; plot(0:240,ones(240,1)*25,'--r')
    axis([0 240 0 100])
    Acc_subj = [Acc_subj Acc_comp];
end % subject









