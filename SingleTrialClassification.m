%           Author: Anany Dwivedi
%           Date  : Jun-28-18
%           The University of Auckland
%      This script is used to for Single Trial Classification Task
%% File Setup
clc;
clear all;
close all;
%% Path Def
MainFolder = {'Data'};
SubFolder = {'ClassificationData\20180525'};
% FileName = {'ClassifyData_On_Off_20180507.csv'};
% FileName = {'ClassifyData_L_R_20180507.csv'};
% FileName = {'Non_Shuffle_ClassifyData_On_Off_20180518.csv'};
% FileName = {'Non_Shuffle_ClassifyData_L_R_20180518.csv'};
FileName = {'Non_Shuffle_12_ArcStim_On_20180525_LH.csv'};
FilePath = fullfile(MainFolder,SubFolder,FileName);
FilePath = cell2mat(FilePath);
Data = csvread(FilePath,0,0);

%% Important Variables for Processing

TotalChannels = 8;
%Trigger Related

%Signal Processing Related

%Stimuli Characteristics
StimRepeatNum = 2;
NumOfStim = max(Data(:,end))+1;
ClassWiseData = zeros(length(Data)/NumOfStim,size(Data,2)-1,NumOfStim);
%% Dictionary for Electrode Data
keySet = {1,2,3,4,5,6,7,8};
valueSet = {[1:9],[10:18],[19:27],[28:36],[37:45],[46:54],[55:63],[64:72]};
M = containers.Map(keySet,valueSet);
%% Separate Data
DataSize = length(Data)/NumOfStim;
for s = 1:NumOfStim
    ClassWiseData(:,:,s) = Data(DataSize*(s-1)+1:DataSize*s,1:TotalChannels*(size(Data,2)/TotalChannels)-1);
end


%% Classification Related Variables
Electrodes = 1:TotalChannels;
Accuracy = [];
A = [];
AccuracyMean = zeros(TotalChannels,1);
BestChannel = zeros(TotalChannels);
AllAccuracyMean = zeros(TotalChannels,1);
PossibleCombinations = [];
% Make rand_selection variable for different folds
% rand_select = zeros(size(Data,1),Folds);
% for f = 1:Folds
%     rand_select(:,f) = randperm(size(Data,1));
% end 

rand_select = randperm(size(Data,1)-NumOfStim);

for ch = 1:TotalChannels
    PossibleCombinations = combnk(Electrodes,ch);
    if (size(PossibleCombinations,1)==1)
        PossibleCombinations = padarray(PossibleCombinations,[size(PossibleCombinations,1),0],0,'post');
        NumberOfCombinations = size(PossibleCombinations,1)-1;
        
    else
        NumberOfCombinations = size(PossibleCombinations,1);
    end
    for i = 1:NumberOfCombinations
        elec = PossibleCombinations(i,:);
        Accuracy = [];
        elecData = [];
        for var = 1:length(elec)
            elecData = [elecData M(elec(var))];
        end
        for f = 1:size(ClassWiseData,1)
            DataSelect = [1:f-1 f+1:size(ClassWiseData,1)];
            Train = [];
            TrainLabels = [];
            Test = [];
            TestLabels = [];
            
            for stim = 1:NumOfStim
                Train = [Train; ClassWiseData(DataSelect,elecData,stim)];
                TrainLabels = [TrainLabels;  stim*ones(length(DataSelect),1)];
                
                Test = [Test; ClassWiseData(f,elecData,stim)];
                TestLabels = [TestLabels;  stim];
            end
            Train = Train(rand_select,:);
            TrainLabels = TrainLabels(rand_select);
                
            
            %% Create Model
            MdlLinear = fitcdiscr(Train,TrainLabels);
%             MdlLinear = TreeBagger(50,Train,TrainLabels,'Method','classification');
%             MdlLinear = fitctree(Train,TrainLabels);
            TestPred = [];
            TestPred = predict(MdlLinear,Test);
%             TestPred = str2num(str2mat(TestPred));
%             TestPred = str2num(TestPred);

%             Mdl = classRF_train(Train,TrainLabels,500);
%             TestPred = classRF_predict(Test,Mdl);
            
            CP = classperf(TestLabels,TestPred);

            Accuracy = [Accuracy,CP.CorrectRate];
%             clear MdlLinear
        end
        A = [A,Accuracy];
        if mean(Accuracy) > AccuracyMean(ch)
            AccuracyMean(ch) = mean(Accuracy);
            BestChannel(ch,:) = padarray(elec,[0,TotalChannels-ch],0,'post');
        end
        clc;
        AccuracyMean
        fprintf('Processing Set of %d Electrode(s)... %.2f%% completed... \n',ch,(i/NumberOfCombinations)*100);
        
        plot(1:TotalChannels,AccuracyMean,'*k','LineWidth',3,'MarkerSize',8)
        hold on 
        plot(0:TotalChannels+1,ones(TotalChannels+2,1)*(1/NumOfStim),'-.r','LineWidth',1,'MarkerSize',8)
        hold off;
        ylim([0,1])
        xlim([0,TotalChannels+1])
        text(1-0.1,AccuracyMean(1)-0.05,num2str(BestChannel(1,1:1)))
        text(2-0.2,AccuracyMean(2)-0.05,num2str(BestChannel(2,1:2)))
        text(3-0.3,AccuracyMean(3)-0.05,num2str(BestChannel(3,1:3)))
        text(4-0.4,AccuracyMean(4)-0.05,num2str(BestChannel(4,1:4)))
        text(5-0.5,AccuracyMean(5)-0.05,num2str(BestChannel(5,1:5)))
        text(6-0.6,AccuracyMean(6)-0.05,num2str(BestChannel(6,1:6)))
        text(7-0.7,AccuracyMean(7)-0.05,num2str(BestChannel(7,1:7)))
        text(8-0.8,AccuracyMean(8)-0.05,num2str(BestChannel(8,1:8)))
        xlabel('# of Electrode Channels');
        ylabel('Accuracy')
%         axis square;
        grid on;
        pause(0.001)

%         clear MdlLinear Accuracy
    end
    AllAccuracyMean(ch,1) = mean(A);
    A = [];
end
%%
        
        figure,plot(1:TotalChannels,AllAccuracyMean,'*k','LineWidth',3,'MarkerSize',8)
        hold on 
        plot(0:TotalChannels+1,ones(TotalChannels+2,1)*(1/NumOfStim),'-.r','LineWidth',1,'MarkerSize',8)
        hold off;
        ylim([0,1])
        xlim([0,TotalChannels+1])
        xlabel('# of Electrode Channels');
        ylabel('Accuracy')
%         axis square;
        grid on;
        pause(0.001)