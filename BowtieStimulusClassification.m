%           Author: Anany Dwivedi
%           Date  : Jun-28-18
%           The University of Auckland
%      This is a script to process circular arc stimulus
%% File Setup
clc;
clear all;
close all;
addpath('myEEG_lib\');              %Path to User Defined Functions
%% Path Def
MainFolder = {'Data'};
SubFolder = {'20180525'};
Subjects = {'LH','YJ'};
FirstFile = 1;
LastFile = 20;

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
SigDurationToProcess_Stim = 2;
FreqToPlot = 30;
L = SigDurationToProcess_Stim*Fs;
freq_hz = Fs*(0:(L/2))/L;
FreqToLookFor = [8:0.5:12];                             % Frequency of interest is 15Hz
FreqOfInterest = (floor(L/Fs)*FreqToLookFor)+1;
ReqFreqIndex = (floor(L/Fs)*FreqToPlot)+1;
freq_hz_Stim = freq_hz(1:ReqFreqIndex);

%Stimuli Characteristics
StimRepeatNum = 3;
NumOfStim = 4;
StimPositions = [];
for s = 1:NumOfStim
    StimPositions(s,:) = s:NumOfStim:(NumFiles*NumTriggers);
end
Channel = 1;

R1 = 1;
C1 = 0;
%% Read Files
TotalItr = length(Subjects)*NumFiles*NumTriggers*TotalChannels;
SubjectItr = NumFiles*NumTriggers*TotalChannels;

TotalItrCompleted = 0;
SubjectItrCompleted = 0;
for sub = 1:length(Subjects)
    SubjectItrCompleted = 0;
    AllPowerOn = zeros(NumFiles*NumTriggers,length(freq_hz_Stim),TotalChannels);
    AllPowerOff = zeros(NumFiles*NumTriggers,length(freq_hz_Stim),TotalChannels);
    idx = 1;                    % To iterate the index of number of Stimuli
    for f = 1:NumFiles
        FileName = strcat('Exp',' ',int2str(FileToBeProcessed(f)),'.csv');
        FilePath = fullfile(MainFolder,SubFolder,Subjects{sub},FileName);
        FilePath = cell2mat(FilePath);
        Data = csvread(FilePath,R1,C1);
        
        % Clean the Trigger Data
    	[Trigger Trigger_sec] = cleanTrigger(Data(:,TriggerChannel),TriggerGap,FirstTrigger,NumTriggers,Fs);
        
        for i = 1:length(Trigger)
            for ch = 1:TotalChannels
                StimOn = calcPower(Data(:,ch),Trigger(i),SigDurationToProcess_Stim,FreqToPlot,Fs);
                AllPowerOn(idx,:,ch) = StimOn;

                StimOff = calcPower(Data(:,ch),Trigger(i)-(SigDurationToProcess_Stim*Fs),SigDurationToProcess_Stim,FreqToPlot,Fs);
                AllPowerOff(idx,:,ch) = StimOff;
                
                TotalItrCompleted = TotalItrCompleted + 1;
                SubjectItrCompleted = SubjectItrCompleted + 1;
                clc;
                fprintf('Processing File: %s\n',FileName);
                fprintf('Process Completion for %s:  %.2f%%\n',Subjects{sub},(SubjectItrCompleted/SubjectItr)*100);
                fprintf('Completion of the Script: %.2f%%\n',(TotalItrCompleted/TotalItr)*100);
            end
            idx = idx + 1;
        end

    end
    %% Separate the Stimuli
    StimOn = zeros(NumOfStim,length(freq_hz_Stim),TotalChannels);
    StimOff = zeros(NumOfStim,length(freq_hz_Stim),TotalChannels);
    StimOnForClassify = [];
    StimOffForClassify = [];
    for ch = 1:TotalChannels
        chSt = ((ch-1)*length(FreqOfInterest))+1;
        chEnd = chSt + length(FreqOfInterest)-1;
        for s = 1:NumOfStim
            DataForStim = AllPowerOn(:,:,ch);
            StimData = processForPlot(DataForStim,'S',0,StimPositions(s,:),NumOfStim);
            StimOn(s,:,ch) = mean(StimData,1);
            
                StimOnForClassify(((s-1)*NumFiles*NumTriggers/NumOfStim)+1:...
                    ((s)*NumFiles*NumTriggers/NumOfStim),chSt:chEnd) = StimData(:,FreqOfInterest);

                StimOnForClassify(((s-1)*NumFiles*NumTriggers/NumOfStim)+1:...
                    ((s)*NumFiles*NumTriggers/NumOfStim),(TotalChannels*length(FreqOfInterest))+1) = s-1;

            DataForStim = AllPowerOff(:,:,ch);
            StimData = processForPlot(DataForStim,'S',0,StimPositions(s,:),NumOfStim);
            StimOff(s,:,ch) = mean(StimData,1);
            
                StimOffForClassify(((s-1)*NumFiles*NumTriggers/NumOfStim)+1:...
                    ((s)*NumFiles*NumTriggers/NumOfStim),chSt:chEnd) = StimData(:,FreqOfInterest);

                StimOffForClassify(((s-1)*NumFiles*NumTriggers/NumOfStim)+1:...
                    ((s)*NumFiles*NumTriggers/NumOfStim),(TotalChannels*length(FreqOfInterest))+1) = s-1;
        end
    end
    




    %% Plot

%     for ch = 1:TotalChannels
%         figure,
%         for s = 1:NumOfStim
%             plot(freq_hz_Stim,StimOn(s,:,ch),'LineWidth',3);
%             hold on
%             title('12 stimulus')
%                     %     mx = [max(On_1_mean) max(On_2_mean) max(On_3_mean) max(On_4_mean)];
%             axis([0 max(freq_hz_Stim)+1 0 max(max(StimOn(:,:,ch)))+ max(max(0.2*StimOn(:,:,ch)))]);
%         %     axis square;
%         %     hold off
%             grid on;
%             clc;
%             fprintf('Processing File: %s\n',FileName);
%             fprintf('Process Completion for %s:  %.2f%%\n',Subjects{sub},(SubjectItrCompleted/SubjectItr)*100);
%             fprintf('Completion of the Script: %.2f%%\n',(TotalItrCompleted/TotalItr)*100);
%             fprintf('Showing Stimuli (Subject %d / %d): %d / %d for Channel %d / %d\n',...
%                 sub,length(Subjects),s,NumOfStim,ch,TotalChannels);
% 
%             disp('Press a key !')  % Press a key here.You can see the message 'Paused: Press any key' in        % the lower left corner of MATLAB window.
%             pause;
% 
%         end
%         legend('Stimulus 1','Stimulus 2','Stimulus 3','Stimulus 4','Stimulus 5','Stimulus 6',...
%                 'Stimulus 7','Stimulus 8','Stimulus 9','Stimulus 10','Stimulus 11','Stimulus 12')
%         disp('Press a key !')  % Press a key here.You can see the message 'Paused: Press any key' in        % the lower left corner of MATLAB window.
%             pause;
% 
%     end
    %% Write Files
    FileName = strcat('Non_Shuffle_12_ArcStim_On_',SubFolder,'_',Subjects{sub},'.csv');
    FileName = cell2mat(FileName);
    FilePath = fullfile('Data\ClassificationData',SubFolder);
    FilePath = cell2mat(FilePath);
    if(~exist(FilePath,'dir'))
        mkdir(FilePath);
    end
    FilePath = fullfile(FilePath,FileName);
    csvwrite(FilePath,StimOnForClassify);

    FileName = strcat('Non_Shuffle_12_ArcStim_Off_',SubFolder,'_',Subjects{sub},'.csv');
    FilePath = fullfile('Data\ClassificationData',SubFolder,FileName);
    FilePath = cell2mat(FilePath);
    csvwrite(FilePath,StimOffForClassify);
end









