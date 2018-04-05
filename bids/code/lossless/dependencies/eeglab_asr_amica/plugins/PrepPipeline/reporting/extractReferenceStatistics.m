function [statisticsTitles, statisticsIndex,  noisyChannels, ... 
          statistics] = extractReferenceStatistics(EEG)
% Creates st
    statisticsTitles = { ...
        'Median channel deviation original', ...
        'Median channel deviation referenced', ...
        'Robust SD channel deviation original', ...
        'Robust SD channel deviation, referenced', ...
        'Median window channel deviation original', ...
        'Median window channel deviation referenced', ...
        'Robust SD window channel deviation original', ...
        'Robust SD window channel deviation, referenced', ...
        'Median window correlation original', ...
        'Median window correlation referenced', ...
        'Average window correlation original', ...
        'Average window correlation referenced', ...
        'Median HF noisiness original', ...
        'Median HF noisiness referenced', ...
        'Robust SD HF noisiness original', ...
        'Robust SD HF noisiness referenced', ...
        'Median window HF noisiness original', ...
        'Median window HF noisiness referenced', ...
        'Robust window SD HF noisiness original', ...
        'Robust window SD HF noisiness referenced', ...
        };
    s = struct();
    s.medDevOrig = 1;
    s.medDevRef = 2;
    s.rSDDevOrig = 3;
    s.rSDDevRef = 4;
    s.medWinDevOrig = 5;
    s.medWinDevRef = 6;
    s.rSDWinDevOrig = 7;
    s.rSDWinDevRef = 8;
    s.medCorOrig = 9;
    s.medCorRef = 10;
    s.aveCorOrig = 11;
    s.aveCorRef = 12;
    s.medHFOrig = 13;
    s.medHFRef = 14;
    s.rSDHFOrig = 15;
    s.rSDHFRef = 16;
    s.medWinHFOrig = 17;
    s.medWinHFRef = 18;
    s.rSDWinHFOrig = 19;
    s.rSDWinHFRef = 20;
    statisticsIndex = s;
    noisyChannels = ...
            struct('numberReferenceChannels', [], ...
              'badChannelNumbers', [], 'badChannelLabels', [], ...
              'badInterpolated', [], 'channelsStillBad', [], ...
              'interpolatedNaN', [], 'interpolatedNoData', [], ...
              'interpolatedLowSNR', [], 'interpolatedDropOuts', [], ... 
              'interpolatedCorr', [],'interpolatedDev', [], ...
              'interpolatedRansac', [], 'interpolatedHF',  [], ...
              'actualInterpolationIterations', []);
    if nargin < 1
        statistics = [];
        return;
    end

    statistics = zeros(1, length(statisticsTitles));
    reference = EEG.etc.noiseDetection.reference;
    original = reference.noisyStatisticsOriginal;
    referenced = reference.noisyStatistics;
    referenceChannels = reference.referenceChannels;
    evaluationChannels = reference.evaluationChannels;
    %% Fill in the rest of the noisyChannels structure
    noisyChannels.numberReferenceChannels = length(referenceChannels);
    noisyChannels.actualInterpolationIterations = ...
        getFieldIfExists(reference, 'actualInterpolationIterations');

    channelLabels = {reference.channelLocations.labels};
    noisyChannels.badInterpolated = ...
        getFieldIfExists(reference.interpolatedChannels, 'all');
    noisyChannels.channelsStillBad = ...
        getFieldIfExists(reference.noisyStatistics.noisyChannels, 'all');
    bad = union(noisyChannels.badInterpolated, noisyChannels.channelsStillBad);
    noisyChannels.badChannelNumbers = bad(:)';
    noisyChannels.badChannelLabels = channelLabels(noisyChannels.badChannelNumbers);
 
    noisyChannels.interpolatedNaN = ...
        getFieldIfExists(reference.interpolatedChannels, 'badChannelsFromNaNs');
    noisyChannels.interpolatedNoData = ...
        getFieldIfExists(reference.interpolatedChannels, 'badChannelsFromNoData');
    noisyChannels.interpolatedLowSNR = ...
        getFieldIfExists(reference.interpolatedChannels, 'badChannelsFromLowSNR');
    noisyChannels.interpolatedHF = ...
        getFieldIfExists(reference.interpolatedChannels, 'badChannelsFromHFNoise');
    noisyChannels.interpolatedCorr = ...
        getFieldIfExists(reference.interpolatedChannels, 'badChannelsFromCorrelation');
    noisyChannels.interpolatedDev = ...
        getFieldIfExists(reference.interpolatedChannels, 'badChannelsFromDeviation');
    noisyChannels.interpolatedRansac = ...
        getFieldIfExists(reference.interpolatedChannels, 'badChannelsFromRansac');
    noisyChannels.interpolatedDropOuts = ...
        getFieldIfExists(reference.interpolatedChannels, 'badChannelsFromDropOuts');

%% Deviations
    statistics(s.medDevOrig) = original.channelDeviationMedian;
    statistics(s.medDevRef) = referenced.channelDeviationMedian;
    statistics(s.rSDDevOrig) = original.channelDeviationSD;
    statistics(s.rSDDevRef) = referenced.channelDeviationSD;
    beforeDeviationLevels = original.channelDeviations(evaluationChannels, :);
    afterDeviationLevels = referenced.channelDeviations(evaluationChannels, :);
    statistics(s.medWinDevOrig) = median(beforeDeviationLevels(:));
    statistics(s.medWinDevRef) = median(afterDeviationLevels(:));
    statistics(s.rSDWinDevOrig) = mad(beforeDeviationLevels(:), 1)*1.4826;
    statistics(s.rSDWinDevRef) = mad(afterDeviationLevels(:), 1)*1.4826;
%% Correlations
    beforeCorrelation = original.maximumCorrelations(evaluationChannels, :);
    afterCorrelation = referenced.maximumCorrelations(evaluationChannels, :);
    statistics(s.medCorOrig) = median(beforeCorrelation(:));
    statistics(s.medCorRef) = median(afterCorrelation(:));
    statistics(s.aveCorOrig) = mean(beforeCorrelation(:));
    statistics(s.aveCorRef) = mean(afterCorrelation(:));

%% Noisiness
    statistics(s.medHFOrig) = original.noisinessMedian;
    statistics(s.medHFRef) = referenced.noisinessMedian;
    statistics(s.rSDHFOrig) = original.noisinessSD;
    statistics(s.rSDHFRef) = referenced.noisinessSD;
    beforeNoiseLevels = original.noiseLevels(evaluationChannels, :);
    afterNoiseLevels = referenced.noiseLevels(evaluationChannels, :);
    statistics(s.medWinHFOrig) = median(beforeNoiseLevels(:));
    statistics(s.medWinHFRef) = median(afterNoiseLevels(:));
    statistics(s.rSDWinHFOrig) = mad(beforeNoiseLevels(:), 1)*1.4826;
    statistics(s.rSDWinHFRef) = mad(afterNoiseLevels(:), 1)*1.4826;
end