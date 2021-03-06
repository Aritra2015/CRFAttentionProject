% Spectral Analysis of EEG signals for Contrast 
% Conditions for Monkey Microelectrode Data
% who performed GRF Protocol for stimuli centred on the RF of
% microelectrode grid

clear; close all; %clc

blRange = [-1 0]; stRange = [0.25 1.25];
a=1; e=1; s = 1; f = 1; t= 1; % o =1; % Stimulus Parameters

freqLims = [0 100];

plotPos = [0.1 0.1 0.85 0.85]; plotGap = 0.1;

% Data Loading
indexList = [473]; %[]; %471 = stationary Grating %473 = 8Hz Counterphase Grating 
                    %475 = 10 Hz Counterphase Grating %483 = 10 Hz On-Off Flicker Grating
[expDates,protocolNames,stimType] = getAllProtocols('kesari','Microelectrode');
folderSourceString='H:'; subjectName = 'kesari';gridType = 'Microelectrode';
load(fullfile(folderSourceString,'programs','DataMap','ReceptiveFieldData',[subjectName,'MicroelectrodeRFData.mat']));
electrodeNumLists{1} = [highRMSElectrodes([1 2 3])]; % Electrodes of Interest
% electrodeNumLists{2} = [29 28 60 61]; % Electrodes of Interest



for i=1:length(indexList)

%   subjectName = subjectNames{indexList(i)};
    expDate = expDates{indexList(i)};
    protocolName = protocolNames{indexList(i)};
    folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
    load(fullfile(folderName,'extractedData','parameterCombinations.mat'));    
    load(fullfile(folderName,'segmentedData','LFP','lfpInfo.mat'));           
    
    % Get bad trials

    folderExtract = fullfile(folderName,'extractedData');
    folderSegment = fullfile(folderName,'segmentedData');
    badTrialFile = fullfile(folderSegment,'badTrialsNew.mat');
    if ~exist(badTrialFile,'file')
        disp('Bad trial file does not exist...');
        badTrials=[];
    else
        badTrials = load(badTrialFile);
        disp([num2str(length(badTrials)) ' bad trials']);
    end
    

        Fs=2000;  
%         blRange = [-0.25 0]; stRange = [0.25 0.5];
        N = round(Fs*diff(blRange)); ysbl = Fs*(0:1/N:1-1/N);
        N = round(Fs*diff(stRange)); ysst = Fs*(0:1/N:1-1/N);        
        blPos = find(timeVals>=blRange(1),1) + (1:N);
        stPos = find(timeVals>=stRange(1),1) + (1:N);
        blPostf = find(timeVals>=blRange(1),1) + (1:N);
        stPostf = find(timeVals>=stRange(1),1) + (1:N);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%
     figure(i)
     [plotHandlesPSD,~,plotPosPSD] = getPlotHandles((length(cValsUnique))/4,(length(cValsUnique))/2,plotPos,plotGap,plotGap,0);
     
     figure(i+length(indexList)); colormap jet; %figure(i+numel(indexList));
%      [plotHandlesBasePower,~,plotPosBasePower] = getPlotHandles((length(cValsUnique))/4,(length(cValsUnique))/2,plotPos,plotGap,plotGap,0);
%      
%      figure(i+numel(indexList)); colormap jet;
%      plotHandlesTF = getPlotHandles((length(cValsUnique))/4,(length(cValsUnique))/2,plotPos,plotGap,plotGap,0);
     
%      figure(i+2*numel(indexList));
     
     electrodeNumList = electrodeNumLists{1}; % Right Side
    
     AlphaRange = [8 12]; BetaRange = [16 28]; GammaRange = [30 80]; HighGammaRange = [100 200]; SSVEPRange = 2*tValsUnique(t);
 
    commonBaselineAcrossContrasts = [];MeanStimAcrossContrasts = [];
         
     for c=1:length(cValsUnique)
         
         analogData = [];
         clear analogDataElecwise
         clear goodPos      
         
         analogDataElecwise = cell(length(oValsUnique),length(electrodeNumList));
            for iOri = 1:length(oValsUnique) 
                goodPos = parameterCombinations{a,e,s,f,iOri,c,t};
                goodPos = setdiff(goodPos,badTrials.badTrials);
                
                for j = 1:length(electrodeNumList) % Rigtht side 
                    disp(num2str([cValsUnique(c) iOri j]));
                    elecNum = electrodeNumList(j);
                    electrodeData = load(fullfile(folderSourceString,'data',subjectName,...
                        gridType,expDate,protocolName,'segmentedData','LFP',['elec' num2str(elecNum) '.mat']));
                    analogDataElecwise{iOri,j} = electrodeData.analogData(goodPos,:);
%                     analogData = cat(1,analogData,electrodeData.analogData(goodPos,:));
                end
            end                      
               clear dataMean sizeDTA dataToAnalyseBLMatrix dataToAnalyseBLCorrected
                
%                 dataMean = mean(analogData(:,blPos),2);
%                 sizeDTA = size(analogData,2);
%                 dataToAnalyseBLMatrix = repmat(dataMean,1,sizeDTA);
%                 dataToAnalyseBLCorrected = analogData;% - dataToAnalyseBLMatrix;
%                 erpData = mean(dataToAnalyseBLCorrected,1);   %You get one value for Raw EEG amplitude for all 2048 Time Points 
             
     
           
        params.tapers = [1 1]; %(where K is less than or equal to 2TW-1)
        params.pad = -1;
        params.Fs = Fs;
        params.fpass = freqLims;
        params.trialave = 1; 
        
        
        
%         blPowerpooledElec = [];
%         [blPower,blFreq] = mtspectrumc(dataToAnalyseBLCorrected(:,blPostf)',params);
%         plot(blFreq,log(mean(blPower,2)),'b'); hold on;
%         [stPower,stFreq] = mtspectrumc(dataToAnalyseBLCorrected(:,stPostf)',params);
%         plot(stFreq,log(mean(stPower,2)),'r');
%         title(['Contrast: ' num2str(cValsUnique(c)) '%']);
%         xlabel('Frequency(Hz)'); ylabel('log10(Power)'); ylim([-1 10]);
%         legend('Baseline','Stimulus');
%         
%         figure(i+numel(indexList));
%         subplot(plotHandlesTF(c));
% %         movingwin = [0.25 0.025];
%         movingwin = [diff(blRange) 0.01]; % in seconds. Change i from 1 to 4.
%         [tfPower,tfTime,tfFreq] = mtspecgramc(dataToAnalyseBLCorrected',movingwin,params);
%         chPower = 10*(log10(tfPower)' - repmat(log10(blPower),1,size(tfPower,1)));
%         pcolor(tfTime+timeVals(1),tfFreq,(chPower)); shading interp; xlabel('Time Period (second)'); ylabel('Frequency')
%         title(['Contrast: ' num2str(cValsUnique(c)) '%']);
%         colorbar; caxis([-10 10]);
%         xlim([-0.5 0.75]); 
        
        clear blPower blFreq stPower stFreq
        for iOri = 1:length(oValsUnique)
                for iElec = 1:size(analogDataElecwise,2)
                [blPower(iOri,iElec,:),blFreq] = mtspectrumc(squeeze(analogDataElecwise{iOri,iElec}(:,blPostf))',params);
        %          blPowerpooledElec = cat(2,blPowerpooledElec,blPower);
                [stPower(iOri,iElec,:),stFreq] = mtspectrumc(squeeze(analogDataElecwise{iOri,iElec}(:,stPostf))',params);
        %          stPowerpooledElec = cat(2,stPowerpooledElec,stPower);
                end
        end
                
            AlphaPos = find(blFreq>=AlphaRange(1) & blFreq<=AlphaRange(2));
            BetaPos = find(blFreq>=BetaRange(1) & blFreq<=BetaRange(2));
            GammaPos = find(blFreq>=GammaRange(1) & blFreq<=GammaRange(2));
            SSVEPPos = find(blFreq == SSVEPRange);
        
                
                commonBaselineAcrossOri = squeeze(mean(log10(blPower(iOri,:,:)),1));
                commonBaselineAcrossElec = squeeze(mean(commonBaselineAcrossOri,1));
                commonBaselineAcrossContrasts = cat(1,commonBaselineAcrossContrasts,commonBaselineAcrossElec);
                MeancommonBaselineAcrossContrasts = mean(commonBaselineAcrossContrasts,1);
                
                MeanStimAcrossOri = squeeze(mean(log10(stPower(iOri,:,:)),1));
                MeanStimAcrossElec = squeeze(mean(MeanStimAcrossOri,1));
                MeanStimAcrossContrasts = cat(1,MeanStimAcrossContrasts,MeanStimAcrossElec);
                
                stdStimAcrossElec = squeeze(std(MeanStimAcrossOri,1));
                semStimAcrossElec = stdStimAcrossElec./sqrt(size(MeanStimAcrossOri,1));
%                 SSVEPPos = find(blFreq1 == SSVEPRange);
%                 powerChangePerElectrode = 10*(squeeze(log10(stPower1(iOri,:,:))-commonBaseline));
%                 meanPowerChange = mean(powerChangePerElectrode,1);
%                 stdPowerChange = std(powerChangePerElectrode,[],1);%/sqrt(size(powerChangePerElectrode,1));
%                 powerChangeSSVEP(c,iOri,1) = meanPowerChange(SSVEPPos);
%                 powerChangeSSVEP(c,iOri,2) = stdPowerChange(SSVEPPos);
%                 
                figure(i);
                subplot(plotHandlesPSD(c));
%                 hax = axes;
%                 line([AlphaRange(1) AlphaRange(1)],get(hax,'YLim'),'color',[1 0 0]);
                plot(blFreq,commonBaselineAcrossElec,'g'); % squeeze(mean(log10(blPower1(iOri,:,:)),2))
                hold on;
                plot(stFreq,MeanStimAcrossElec,'k');  YLim =[-1 4]; yL = get(gca,'YLim');% squeeze(mean(log10(stPower1(iOri,:,:)),2)) 
                line([blFreq(AlphaPos(1)) blFreq(AlphaPos(1))],yL,'color','b'); line([blFreq(AlphaPos(end)) blFreq(AlphaPos(end))],yL ,'color', 'b');
                line([blFreq(BetaPos(1)) blFreq(BetaPos(1))],yL,'color','k'); line([blFreq(BetaPos(end)) blFreq(BetaPos(end))],yL ,'color', 'k');
                line([blFreq(GammaPos(1)) blFreq(GammaPos(1))],yL,'color','r'); line([blFreq(GammaPos(end)) blFreq(GammaPos(end))],yL ,'color', 'r');
                title(['Contrast: ' num2str(cValsUnique(c)) '%']);
                xlabel('Frequency(Hz)'); ylabel('Power (Bel)'); ylim(YLim);
                legend('Baseline','stimulus');
                
                drawnow;

            
                
                AlphaPowerChange(c) = mean(MeanStimAcrossElec(:,AlphaPos)-commonBaselineAcrossElec(:,AlphaPos),2);
                semAlphaPowerChange(c) = mean(semStimAcrossElec(:,AlphaPos),2);
                BetaPowerChange(c) = mean(MeanStimAcrossElec(:,BetaPos)-commonBaselineAcrossElec(:,BetaPos),2);
                semBetaPowerChange(c) = mean(semStimAcrossElec(:,BetaPos),2);
                GammaPowerChange(c) = mean(MeanStimAcrossElec(:,GammaPos)-commonBaselineAcrossElec(:,GammaPos),2);
                semGammaPowerChange(c) = mean(semStimAcrossElec(:,GammaPos),2);
                    if tValsUnique(t)>0
                            SSVEPPowerChange(c) = (MeanStimAcrossElec(:,SSVEPPos)-commonBaselineAcrossElec(:,SSVEPPos));
                            semSSVEPPowerChange(c) = semStimAcrossElec(:,SSVEPPos);
                    
                    end
%                 plot(scaledxaxis,BetaPowerChange,'ko-','LineWidth',2);
%                 plot(scaledxaxis,GammaPowerChange,'ro-','LineWidth',2);hold on;
%         
                
% 
%                 figure(i+length(indexList));
%                 subplot(plotHandlesBasePower(c));
%                 plot(blFreq1,(squeeze(mean(log10(stPower1(iOri,:,:)),2))...
%                     -commonBaseline)); hold on; % squeeze(mean(log10(blPower1(iOri,:,:)),2))))
%                 plot(blFreq1,0*(squeeze(mean(log10(stPower1(iOri,:,:)),2))...
%                     -commonBaseline))
%                 title(['Contrast: ' num2str(cValsUnique(c)) '%']);
%                 xlabel('Frequency(Hz)'); ylabel('Change in Power wrt to Baseline'); ylim([-0.5 1.2]);


%                 powerChangeSSVEPAllElecs(c,iOri,:,:) = powerChangePerElectrode;






        %         figure(i+numel(indexList));
        %         subplot(plotHandlesTF(c));
        % %         movingwin = [0.25 0.025];
        %         movingwin = [diff(blRange) 0.01]; % in seconds. Change i from 1 to 4.
        %         [tfPower(iOri,iElec,:),tfTime(iOri,iElec,:),tfFreq(iOri,iElec,:)] = mtspecgramc(squeeze(analogDataElecwise{iOri,iElec}(:,blPostf))',movingwin,params);
        %         chPower = 10*(log10(squeeze(tfPower(iOri,iElec,:))') - repmat(log10(blPower1(iOri,iElec,:),1,size(tfPower(iOri,iElec,:),2))));
        %         pcolor(tfTime(iOri,iElec,:)+timeVals(1),tfFreq,(chPower)); shading interp; xlabel('Time Period (second)'); ylabel('Frequency')
        %         title(['Contrast: ' num2str(cValsUnique(c)) '%']);
        %         colorbar; caxis([-10 10]);
        %         xlim([-0.5 0.75]); 
             
%         AlphaPos = find(blFreq>=AlphaRange(1) & blFreq<=AlphaRange(2));
%         BetaPos = find(blFreq>=BetaRange(1) & blFreq<=BetaRange(2));
%         GammaPos = find(blFreq>=GammaRange(1) & blFreq<=GammaRange(2));
%         SSVEPPos = find(blFreq == SSVEPRange);
%         
% %         clear AlphaPowerChange BetaPowerChange GammaPowerChange
%         AlphaPowerMean = 10*log10((mean(stPower1(:,AlphaPos),2)./(mean(blPower1(:,AlphaPos),2))));
%         BetaPowerMean = 10*log10((mean(stPower1(:,BetaPos),2)./(mean(blPower1(:,BetaPos),2))));
%         GammaPowerMean = 10*log10((mean(stPower1(:,GammaPos),2)./(mean(blPower1(:,GammaPos),2))));
%         
%         AlphaPowerChangeElecWise(c) = mean(AlphaPowerMean,1);
%         semAlphaPowerChange(c) = std(AlphaPowerMean)/sqrt(length(AlphaPowerMean));
%         BetaPowerChangeElecWise(c) = mean(BetaPowerMean,1);
%         semBetaPowerChange(c) = std(BetaPowerMean)/sqrt(length(BetaPowerMean));
%         GammaPowerChangeElecWise(c) = mean(GammaPowerMean,1);
%         semGammaPowerChange(c) = std(GammaPowerMean)/sqrt(length(GammaPowerMean));
        
%         AlphaPowerChange(c) = 10*log10(mean((stPower(AlphaPos,:)),1))-10*log10(mean((blPower(AlphaPos,:)),1));
%         BetaPowerChange(c) = 10*log10(mean((stPower(BetaPos,:)),1))-10*log10(mean((blPower(BetaPos,:)),1));
%         GammaPowerChange(c) = 10*log10(mean((stPower(GammaPos,:)),1))-10*log10(mean((blPower(GammaPos,:)),1));
%         SSVEPPowerChange(c) = 10*log10(stPower(SSVEPPos))-10*log10(blPower(SSVEPPos));
%         
%         semAlphaPowerChange(c) = std((10*log10(stPower(AlphaPos,:))-10*log10(blPower(AlphaPos,:))))/sqrt(length(stPower(AlphaPos,:)));
%         semBetaPowerChange(c) = std((10*log10(stPower(BetaPos,:))-10*log10(blPower(BetaPos,:))))/sqrt(length(stPower(BetaPos,:)));
%         semGammaPowerChange(c) = std((10*log10(stPower(GammaPos,:))-10*log10(blPower(GammaPos,:))))/sqrt(length(stPower(GammaPos,:)));

%         powerChangeSSVEPCon(c) = {powerChangeSSVEP};
      
     end
     
                figure(i+length(indexList));
                scaledxaxis = [log2(cValsUnique(2))-(log2(cValsUnique(3))-log2(cValsUnique(2))) log2(cValsUnique(2:end))];

                errorbar(scaledxaxis,AlphaPowerChange,semAlphaPowerChange,'bo-','LineWidth',2); hold on;
                errorbar(scaledxaxis,BetaPowerChange,semBetaPowerChange,'ko-','LineWidth',2);
                errorbar(scaledxaxis,GammaPowerChange,semGammaPowerChange,'ro-','LineWidth',2);
                    if tValsUnique(t)>0
                        errorbar(scaledxaxis,SSVEPPowerChange,semSSVEPPowerChange,'co-','LineWidth',2);
                    end    

        ax = gca;
        ax.XTick = scaledxaxis;
        ax.XTickLabel = {'0','1.5','3.1','6.2', '12.5', '25', '50', '100'};
            if tValsUnique(t)>0
                legend('Change in Alpha Power','Change in Beta Power','Change in Gamma Power ','change in SSVEP Power')
            else
                legend('Change in Alpha Power','Change in Beta Power','Change in Gamma Power')
            end
        xlabel('Contrast(%)'),ylabel('Change in Power (bel)');
        title(['Change in Power at Alpha-Beta-Gamma for Monkey: ',subjectName ' , Protocol Index: ',num2str(indexList(i))]);
        
                
                 figure(i+2*length(indexList));hold on;
                 contrastColor = hsv(length(cValsUnique));
                 plot(blFreq,0*(MeanStimAcrossContrasts(1,:)-MeancommonBaselineAcrossContrasts),'k','LineWidth',3); 
                 for iCon = 1:length(cValsUnique)
                 plot(blFreq, MeanStimAcrossContrasts(iCon,:)-MeancommonBaselineAcrossContrasts,'color',contrastColor(iCon,:),'LineWidth',1.5); 
                 end
                 YLim =[-0.4 0.6]; yL2 = get(gca,'YLim');
                 line([blFreq(AlphaPos(1)) blFreq(AlphaPos(1))],yL2,'color','b'); line([blFreq(AlphaPos(end)) blFreq(AlphaPos(end))],yL2 ,'color', 'b');
                 line([blFreq(BetaPos(1)) blFreq(BetaPos(1))],yL2,'color','k'); line([blFreq(BetaPos(end)) blFreq(BetaPos(end))],yL2 ,'color', 'k');
                 line([blFreq(GammaPos(1)) blFreq(GammaPos(1))],yL2,'color','r'); line([blFreq(GammaPos(end)) blFreq(GammaPos(end))],yL2 ,'color', 'r');
                 hold off;
                 
                 xlabel('Frequency (Hz)'); ylabel('Change in Power (Bel)');
                 title(['Change in Power with varying contrast for Monkey: ',subjectName ', Protocol Index: ', num2str(indexList(i))])
                 legend('baseline','0%','1.6%','3.1%','6.2%','12.5%','25%','50%','100%')
                 
%                   % Curve Fitting
%                   
%                   X = scaledxaxis';
%                    Y = AlphaPowerChange'; 
%                    Z = GammaPowerChange';
%                 fo = fitoptions('Method','NonlinearLeastSquares',...
%                        'Lower',[0,1],...
%                        'Upper',[Inf,max(X)],...
%                        'StartPoint',[1 1]);
%                 ft = fittype('a*(x^n/(x^n + b^n))','problem','n','options',fo);
%                 [curve2,gof2] = fit(X,Y,ft,'problem',2);
%                 [curve3,gof3] = fit(X,Z,ft,'problem',2);
%                 figure(i+length(indexList)); hold on;
%                 plot(curve2,'r-');xlabel('Contrast(%)'),ylabel('Change in Power');
%                 plot(curve3,'r-');xlabel('Contrast(%)'),ylabel('Change in Power');
%                 
%                     paramStart = [0,0];
%                     x = lsqcurvefit(@nakaRushton,paramStart,scaledxaxis,GammaPowerChange);
%         
%                     ydataprime = nakaRushton(x,scaledxaxis);
%                     plot(scaledxaxis,ydataprime,'r-');hold on
%                     legend('Actual','Estimated');

end        
 
