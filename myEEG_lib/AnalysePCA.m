function [Acc,MisClass] = AnalysePCA(Data,compSelect,ch)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
AA_comp = [];
for i = 1:length(Data)
    AllEvokedOn = Data{i};
    X = AllEvokedOn(:,:,ch);
    X = X';

    [coeff, score] = pca(X);

    % figure; hold on
    % plot(score(:,1),'-k'); axis square
    % plot(score(:,2),'--k');
    % title('First 2 principal components (unscaled)')
    % xlabel('Trial time (sample number)')
    % ylabel('Unscaled, normalized amplitude')

    % fnInnerProduct = @(x,y) sum(x.*y);
    AA = [];
    for ii = 1:size(AllEvokedOn,1)
        PC_comp = [];
        for comp = 1:compSelect
            PC_comp = [PC_comp dot(score(:,comp),AllEvokedOn(ii,:,ch).')];
        end
        AA = [AA; PC_comp];
    end
    AA_comp = [AA_comp AA];
end
COL = {'red';'green';'blue';'black'};
% figure; hold on
% for ii = 1:size(AA,1)
%   this_col = COL{rem(ii,4)+1};
%   plot(AA(ii,1),AA(ii,2),'ok','Color',this_col); axis square
% end
% xlabel('Feature 1')
% ylabel('Feature 2')
% title('Electrode 1 projected onto feature space')

count_hit = 0;
group = repmat(1:4,[1 60])';
MisClass = zeros(4,4);
Importance = zeros(1,size(AA_comp,2));
for jj = 1:60
    ixout = [1:4] + (jj-1)*4;
    ixin = setdiff(1:240,ixout);
%   class = classify(AA_comp(ixout,:),AA_comp(ixin,:),group(ixin),'linear');

    MdlLinear = fitcdiscr(AA_comp(ixin,:),group(ixin));
%     MdlLinear = TreeBagger(50,AA_comp(ixin,:),group(ixin),'Method','classification','OOBPredictorImportance','on');
    TestPred = [];
    class = predict(MdlLinear,AA_comp(ixout,:));
    Importance = Importance + MdlLinear.DeltaPredictor;
    if iscellstr(class) == 1
        class = str2num(cell2mat(class));
    end
    count_hit = count_hit + sum(class==group(ixout));
    trueClass = group(ixout);
    for i = 1:length(class)
        MisClass(class(i),trueClass(i)) = MisClass(class(i),trueClass(i)) + 1;
    end
end
Acc = (count_hit/size(AllEvokedOn,1))*100;
end

