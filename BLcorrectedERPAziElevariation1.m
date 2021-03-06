clear;clc
load('H:\data\AD\EEG\140916\GRF_0003\extractedData\parameterCombinations.mat');    % Electrodes of Interest(Left)       29 (O1)    28(PO9),60(PO7),61(PO3)
load('H:\data\AD\EEG\140916\GRF_0003\segmentedData\LFP\lfpInfo.mat');              % Electrodes of Interest(Right)      31 (O2)    32(PO10),63(PO4),64(PO8)
load('H:\data\AD\EEG\140916\GRF_0003\segmentedData\badTrials.mat');
s = 1; f = 1; c = 1 ; t= 1; 
blPeriod = [-0.2 0];
yLims = [-30 15]; xLims = [-0.2 0.7];
% figure;
plotPos = [0.1 0.1 0.8 0.8]; plotGap = 0.05;
plotHandles = getPlotHandles(length(aValsUnique),length(eValsUnique),plotPos,plotGap,plotGap*2,0);

for o=1:length(oValsUnique)
    figure(o);
    for a = 1:length(aValsUnique)
        for e = 1:length(eValsUnique)

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            analogData = []; %badTrialsAllElec = []; totTrials = 0; 
            for elecNum = [28 29 60 61];%[26+32 26 31+32 31] ;%[26+32 26 31+32 31];%
                clear ElectrodeData analogDataSingleElec %badTrialsElec
                ElectrodeData = load(['H:\data\AD\EEG\140916\GRF_0003\segmentedData\LFP\elec',num2str(elecNum),'.mat']);
                
                analogDataSingleElec = ElectrodeData.analogData;
                
            
            clear goodPos
            goodPos =setdiff(parameterCombinations{a,e,s,f,o,c,t},allBadTrials{elecNum});
            analogData = cat(1,analogData,analogDataSingleElec(goodPos,:));   
            end
            %goodPos = parameterCombinations{a,e,s,f,o,c,t};

            clear dataToAnalyse
            dataToAnalyse = analogData;

            clear blPos data datamean sizeDTA dataToAnalyseBLMatrix dataToAnalyseBLCorrected
            blPos = (timeVals>blPeriod(1) & timeVals<=blPeriod(2));
            data = dataToAnalyse(:,blPos);
            datamean = mean(data,2);
            sizeDTA = size(dataToAnalyse,2);
            dataToAnalyseBLMatrix = repmat(datamean,1,sizeDTA);
            %dataToAnalyseBLMatrix = repmat(mean(dataToAnalyse(:,blPos),2),1,size(dataToAnalyse,2));
            dataToAnalyseBLCorrected = dataToAnalyse - dataToAnalyseBLMatrix;
            ERPdata = mean(dataToAnalyseBLCorrected,1);
            
%             figure ();
%             for iLoop = 1:size(ERPdata);
%                 plot(timeVals,dataToAnalyseBLCorrected(iLoop,:));
%                  hold on
%                 pause;
%             end

%             subplot(plotHandles(a,e));
            clear locPlotHandle
            locPlotHandle = subplot(2,2,2*(a-1)+e);
            hold on;
%             plot(timeVals,dataToAnalyseBLCorrected,'color',[0.5 0.5 0.5],'linewidth',1); hold on;
            plot(timeVals,ERPdata,'color','k','linewidth',2); axis tight; hold off
            ylim(yLims); xlim(xLims); title(['Azimuth: ' num2str(aValsUnique(a)) '; Elevation: ' num2str(eValsUnique(e))]);
            ylabel('EEG Raw Amplitude (�V)');xlabel('Time(second)');
        end
    end
end