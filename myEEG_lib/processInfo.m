function [] = processInfo(FileName,Subjects,SubjectItrCompleted,SubjectItr,TotalItrCompleted,TotalItr)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
clc;
fprintf('Processing File: %s\n',FileName);
fprintf('Process Completion for %s:  %.2f%%\n',Subjects,(SubjectItrCompleted/SubjectItr)*100);
fprintf('Completion of the Script: %.2f%%\n',(TotalItrCompleted/TotalItr)*100);

end

