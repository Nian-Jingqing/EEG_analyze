function [Triggers,Triggers_sec] = cleanTrigger(TriggerData,TriggerGap,FirstTrigger,NumTrigger,SampFreq)
%This is to Find the Trigger positions and remove the False Triggers.
%           Author: Anany Dwivedi
%           Date  : May-09-18
%           The University of Auckland
%               INPUTS:
%                       TriggerData  : The Trigger Data from the Dataset
%                       TriggerGap   : The time (in sec) expected between two
%                           Trigger points
%                       FirstTrigger : The time (in sec) when the First
%                           Trigger point is expected
%                       NumTrigger   : The number of Triggers in the Data Sample
%                       SampFreq     : The Sampling Frequency of the Data
%               OUTPUTS: 
%                       Triggers     : The Location of the Triggers
%                       Triggers_sec : The time (in sec) of the Triggers
%%
% Data = varargin{1};
% Run = varargin{3};
% TypeOfPlot = upper(varargin{2});
%%

TriggersUnprocessed = find(TriggerData);                % Find the Trigger Positions 
Triggers_sec = TriggersUnprocessed/SampFreq;                      % Get the Trigger Time

%% Remove Triggers before FirstTrigger
Triggers_withFalse = TriggersUnprocessed(find(Triggers_sec > FirstTrigger));
Triggers_sec = TriggersUnprocessed/SampFreq;                      % Get the Trigger Time

%% Remove False Triggers
Triggers_sec = Triggers_withFalse/SampFreq;                      % Get the Trigger Time
loc = 1;                                                         % Store the Location of the legitimate Trigger
for i = 1:length(Triggers_sec)
    if Triggers_withFalse(i) > Triggers_withFalse(loc(end)) + TriggerGap*SampFreq
        loc = [loc;i];
    end
end
if length(loc) ~= NumTrigger
    error("More Than expected Triggers");
end
Triggers = Triggers_withFalse(loc);
Triggers_sec = Triggers/SampFreq;
end

