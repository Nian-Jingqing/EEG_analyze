% function [DataReturn] = processForPlot(Data,TypeOfPlot,Run)
function [DataReturn] = processForPlot(varargin)
%This function returns the Data after optimizing it to plot
%           Author: Anany Dwivedi
%           Date  : May-09-18
%           The University of Auckland
%               INPUTS:
%                       Data       : The required channel from the Dataset
%                       TypeOfPlot : Specify if plot is for Alpha Rhythm or
%                           Stimulus ('R' => Alpha Rhythm 'S' => Stimulus)
%                       Run        : Specify the RUN to be plotted (0 => Take the mean of all the RUNS for 
%                           Alpha Rhythm and Take the MEAN for All the Trails of 1 RUN for Stimulus)
%                       Trial      : Trials Wanted to for calculations
%                       NumTrials  : Number of Trials in 1 RUN
%               OUTPUTS: 
%                       DataReturn : Data processed as needed to be plotted
%                     
Data = varargin{1};
Run = varargin{3};
TypeOfPlot = upper(varargin{2});

if size(Data,1) == 1
    warning('Not enough Data to Calculate MEAN.. Returning as is!');
    Run = 1;
end

if nargin == 3 && TypeOfPlot == 'S'
    error('Not Enough Arguments for Stimulus Plots')
end 
    switch(nargin)
        case 3
            %% For Alpha Rhythm
            if Run == 0
                DataReturn = mean(Data);                % Take 

            else
                DataReturn = Data(Run,:);
            end

        case 4
        %% For Stimulus
%             prompt = ['Enter the first Trial to be considered for plot!',char(10), '(Enter 0 to take the MEAN of all the trails of the required RUN): ' ];
            Trial = varargin{4};
            
            if Trial == 0
                DataReturn = mean(Data(((Run-1)*12)+1:(Run)*12,:));

            else
    %                 prompt = ['Enter the last of Trials to be considered for plot!: ' ];
    %                 TrialLast = input(prompt);
                ReqFiles = [];
                for tr = 1:length(Trial)
                    ReqFiles = [ReqFiles; Data(((Run-1)*12)+Trial(tr),:)];
    %                     FirstFile = ((Run-1)*10)+Trial;
    %                     LastFile = ((Run-1)*10)+TrialLast;

                end
                DataReturn = ReqFiles;
    %                 DataReturn = mean(ReqFiles);
            end
        case 5
            %% For Stimulus
%             prompt = ['Enter the first Trial to be considered for plot!',char(10), '(Enter 0 to take the MEAN of all the trails of the required RUN): ' ];
            Trial = varargin{4};
            NumTrials = varargin{5};
            if Run == 0
                DataReturn = Data(Trial,:);
            
            elseif Trial == 0
                DataReturn = mean(Data(((Run-1)*NumTrials)+1:(Run)*NumTrials,:));
                
            else
%                 prompt = ['Enter the last of Trials to be considered for plot!: ' ];
%                 TrialLast = input(prompt);
                ReqFiles = [];
                for tr = 1:length(Trial)
                    ReqFiles = [ReqFiles; Data(((Run-1)*NumTrials)+Trial(tr),:)];
%                     FirstFile = ((Run-1)*10)+Trial;
%                     LastFile = ((Run-1)*10)+TrialLast;
                    
                end
                DataReturn = ReqFiles;
%                 DataReturn = mean(ReqFiles);
            end
        otherwise
            error("Not specified type!!");
    end

end

