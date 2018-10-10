function [Power] = calcPower(Data,TimeStart,Duration,FreqLimit,SampFreq)
%This function returns the PSD of the data for a certain time period of
%time
%           Author: Anany Dwivedi
%           Date  : May-09-18
%           The University of Auckland
%               INPUTS:
%                       Data      : The required channel from the Dataset
%                       TimeStart : The sample point in Data from which to
%                       start the Analysis
%                       Duration  : The time (in sec) upto which to process
%                       FreqLimit : The Frequecies upto which the data is
%                           needed
%                       SampFreq  : The Sampling Frequency of the Data
%               OUTPUTS: 
%                       Power     : PSD of the signal
%                       
    TimeStop = TimeStart + (Duration*SampFreq);
    Data_Snip = Data(TimeStart:TimeStop-1);
    FFT = fft(Data_Snip)/length(Data_Snip);
    RequiredFreq = (floor(length(Data_Snip)/SampFreq)*FreqLimit)+1;
    Power = reshape(abs(FFT(1:RequiredFreq)).^2,[1 RequiredFreq]);


end

