%           Author: Anany Dwivedi
%           Date  : Oct-05-18
%           The University of Auckland
%      This is a script to process circular arc stimulus

%% Path Def
MainFolder = {'/Users/luke/EEG_data/'};
SubFolder = {'2018 05 25'};
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

%Stimuli Characteristics
DurationStim_s = 2;

CSVREAD_IX_ROW = 1;
CSVREAD_IX_COL = 0;
%% Read Files
TotalItr = length(Subjects)*NumFiles*NumTriggers*TotalChannels;
SubjectItr = NumFiles*NumTriggers*TotalChannels;

TotalItrCompleted = 0;
SubjectItrCompleted = 0;
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
                clc;
                fprintf('Processing File: %s\n',FileName);
                fprintf('Process Completion for %s:  %.2f%%\n',Subjects{sub},(SubjectItrCompleted/SubjectItr)*100);
                fprintf('Completion of the Script: %.2f%%\n',(TotalItrCompleted/TotalItr)*100);
            end
            idx = idx + 1;
        end % trigger
    end % files

    for ixstim = 1:4
        figure; hold on
        subplot(2,4,1);
        yscale = 0;
        for iich = 1:TotalChannels
          subplot(2,4,iich)
          plot(mean(AllEvokedOn((ixstim:4:size(AllEvokedOn,1)),:,iich),1),'-k'); axis square; hold on; axis([1 size(AllEvokedOn,2) max(abs(ylim))*[-1 1]]);
          plot(mean(AllEvokedOff((ixstim:4:size(AllEvokedOff,1)),:,iich),1),'-r'); axis square
          if (max(abs(ylim)) > yscale), yscale = max(abs(ylim)); end
        end
        for iich = 1:TotalChannels
          subplot(2,4,iich)
          axis([1 size(AllEvokedOn,2) yscale*[-1 1]]);
          text(0.8*max(xlim), 0.9*max(ylim), sprintf('ch %d',iich))
          if (iich == 5), xlabel('Trial time (samples)'); end
          if (iich == 5), ylabel('Response (uV)'); end
          if (iich == 1), title(sprintf('Sub: %s; Stim: %d',Subjects{sub},ixstim)); end
        end
    end
end % subject

