function [outputArg1,outputArg2] = EvkPotential(Data,TotElec)
%           Author: Anany Dwivedi
%           Date  : Oct-05-18
%           The University of Auckland
%      Plot Confidence intervals of the evoked potentials
%           INPUTS:
%                   Data    : The PSD Data with last column with the
%                      information about the class of stimulus
%                   TotElec : The number of electrode channels used
%%
Data(:,1:end-1) = sqrt(Data(:,1:end-1));
plt = 1;
s = size(Data);
stim = Data(:,end);
FreqPerChannel = (s(2)-1)/TotElec;
TotStim = max(stim)+1;
TotRun = s(1)/TotStim;
for c = 1:TotElec
    EvkPot = [];
    for stm = 1:TotStim
        for r = 1:TotRun
            EvkPot(stm,r) = trapz(Data(((stm-1)*TotRun)+r,((c-1)*FreqPerChannel)+1:((c)*FreqPerChannel)));
        end
    end
    if c == 1 | c == 5
        figure,
        plt = 1;
    end
    sp = 410+plt;
    plt = plt + 1;
    subplot(sp),boxplot(EvkPot.');
    title(['Channel:',int2str(c)]);
    ylim([0,6])
end


end

