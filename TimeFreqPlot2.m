% Spectral Analysis of EEG signals for six Contrast Conditions for subjects 
% who performed GRF Protocol for all the spatial location of stimuli

clear; clc; close all;

electrodeNumLists{1} = [31 32 63 64]; % Electrodes of Interest(Right)      31 (O2),32(PO10),63(PO4),64(PO8)
electrodeNumLists{2} = [29 28 60 61]; % Electrodes of Interest(Left) 

blRange = [-0.5 0]; stRange = [0 0.5];
a=2; e=2; s = 1; f = 1; o =1; t= 1;

freqLims = [0 100];

plotPos = [0.1 0.1 0.85 0.85]; plotGap = 0.1;

indexList = [23 26];
[subjectNames,expDates,protocolNames,stimType,deviceName,capLayout] = allProtocolsCRFAttentionEEG;
folderSourceString='H:'; gridType = 'EEG';


for i=1:length(indexList)
    subjectName = subjectNames{indexList(i)};
    expDate = expDates{indexList(i)};
    protocolName = protocolNames{indexList(i)};
    load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'extractedData','parameterCombinations.mat'));    
    load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'segmentedData','LFP','lfpInfo.mat'));           
    

        Fs=1000;  
        blRange = [-0.5 0]; stRange = [0 0.5];
        N = round(Fs*diff(blRange)); ysbl = Fs*(0:1/N:1-1/N);
        N = round(Fs*diff(stRange)); ysst = Fs*(0:1/N:1-1/N);        
        blPos = find(timeVals>=blRange(1),1) + (1:N);
        stPos = find(timeVals>=stRange(1),1) + (1:N);
        blPostf = find(timeVals>=blRange(1),1) + (1:N);
        stPostf = find(timeVals>=stRange(1),1) + (1:N);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%
     figure(i)
     plotHandlesPSD = getPlotHandles(length(cValsUnique)/3,length(cValsUnique)/2,plotPos,plotGap,plotGap,0);
     
     figure(i+numel(indexList)); colormap jet;
     plotHandlesTF = getPlotHandles(length(cValsUnique)/3,length(cValsUnique)/2,plotPos,plotGap,plotGap,0);
     
     figure(i+2*numel(indexList));
     
     electrodeNumList = electrodeNumLists{1}; % Right Side
    
     AlphaRange = [8 12]; BetaRange = [16 30]; GammaRange = [30 80];
     
     
     for c=1:length(cValsUnique)
        clear goodPos
      
        goodPos = parameterCombinations{a,e,s,f,o,c,t};
       
         analogData = [];
            for j = 1:length(electrodeNumList) % Rigth side 
                    elecNum = electrodeNumList(j);
                    electrodeData = load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'segmentedData','LFP',['elec' num2str(elecNum) '.mat']));
                    analogData = cat(1,analogData,electrodeData.analogData(goodPos,:));
            end
       
               clear dataMean sizeDTA dataToAnalyseBLMatrix dataToAnalyseBLCorrected
                
                dataMean = mean(analogData(:,blPos),2);
                sizeDTA = size(analogData,2);
                dataToAnalyseBLMatrix = repmat(dataMean,1,sizeDTA);
                dataToAnalyseBLCorrected = analogData;% - dataToAnalyseBLMatrix;
%                 erpData = mean(dataToAnalyseBLCorrected,1);   %You get one value for Raw EEG amplitude for all 2048 Time Points 
                
        
           
        params.tapers = [1 1]; %(where K is less than or equal to 2TW-1)
        params.pad = -1;
        params.Fs = Fs;
        params.fpass = freqLims;
        params.trialave = 1; 
        
       
        figure(i);
        subplot(plotHandlesPSD(c));
        [blPower,blFreq] = mtspectrumc(dataToAnalyseBLCorrected(:,blPostf)',params);
        plot(blFreq,log(blPower),'b'); hold on;
        [stPower,stFreq] = mtspectrumc(dataToAnalyseBLCorrected(:,stPostf)',params);
        plot(stFreq,log(stPower),'r');
        title(['Contrast: ' num2str(cValsUnique(c)) '%']);
        xlabel('Frequency(Hz)'); ylabel('log10(Power)'); ylim([-8 4]);
        legend('Baseline','Stimulus');
        
        figure(i+numel(indexList));
        subplot(plotHandlesTF(c));
        movingwin = [diff(blRange) 0.01]; % in seconds. Change i from 1 to 4.
        [tfPower,tfTime,tfFreq] = mtspecgramc(dataToAnalyseBLCorrected',movingwin,params);
        chPower = 10*(log10(tfPower)' - repmat(log10(blPower),1,size(tfPower,1)));
        pcolor(tfTime+timeVals(1),tfFreq,(chPower)); shading interp; xlabel('Time Period (second)'); ylabel('Frequency')
        title(['Contrast: ' num2str(cValsUnique(c)) '%']);
        colorbar;
        xlim([-0.5 0.6]); caxis([-10 10]);
        
        
        AlphaPos = find(blFreq>=AlphaRange(1) & blFreq<=AlphaRange(2));
        BetaPos = find(blFreq>=BetaRange(1) & blFreq<=BetaRange(2));
        GammaPos = find(blFreq>=GammaRange(1) & blFreq<=GammaRange(2));
        
%         clear AlphaPowerChange BetaPowerChange GammaPowerChange
        AlphaPowerChange(c) = 10*log(mean((stPower(AlphaPos,:)),1))-10*log(mean((blPower(AlphaPos,:)),1));
        BetaPowerChange(c) = 10*log(mean((stPower(BetaPos,:)),1))-10*log(mean((blPower(BetaPos,:)),1));
        GammaPowerChange(c) = 10*log(mean((stPower(GammaPos,:)),1))-10*log(mean((blPower(GammaPos,:)),1));
        
        semAlphaPowerChange(c) = std((10*log10(stPower(AlphaPos,:))-10*log10(blPower(AlphaPos,:))))/sqrt(length(stPower(AlphaPos,:)));
        semBetaPowerChange(c) = std((10*log10(stPower(BetaPos,:))-10*log10(blPower(BetaPos,:))))/sqrt(length(stPower(BetaPos,:)));
        semGammaPowerChange(c) = std((10*log10(stPower(GammaPos,:))-10*log10(blPower(GammaPos,:))))/sqrt(length(stPower(GammaPos,:)));
       
     end
     
        figure(i+2*numel(indexList));
        scaledxaxis = [log2(cValsUnique(2))-(log2(cValsUnique(3))-log2(cValsUnique(2))) log2(cValsUnique(2:end))];
%         plot(scaledxaxis,AlphaPowerChange,'b-'); hold on;
%         plot(scaledxaxis,BetaPowerChange,'k-');
%         plot(scaledxaxis,GammaPowerChange,'r-');hold on;

        errorbar(scaledxaxis,AlphaPowerChange,semAlphaPowerChange,'bo-','LineWidth',2); hold on;
        errorbar(scaledxaxis,BetaPowerChange,semBetaPowerChange,'ko-','LineWidth',2);
        errorbar(scaledxaxis,GammaPowerChange,semGammaPowerChange,'ro-','LineWidth',2); hold on;
        ax = gca;
        ax.XTick = [scaledxaxis];
        ax.XTickLabel = {'0','6.25', '12.5', '25', '50', '100'};
        legend('Change in Alpha Power','Change in Beta Power','Change in Gamma Power')
        xlabel('Contrast(%)'),ylabel('Change in Power at different Freq. Bands');
        
     
       
 end        