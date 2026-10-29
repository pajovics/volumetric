
clc;
clear;
close all;

%% 1. Select the main data folder.
% Get current folder.
homeFolder = pwd;
addpath(homeFolder); % Add to path.

% Find the main data folder.
mainFolder = uigetdir(pwd, 'Select data folder.');
if mainFolder == 0
    disp('User cancelled folder selection! Womp womp.');
    return;
end
addpath(genpath(mainFolder)); % Add to path with subfolders.
cd(mainFolder);

%% 2. Process the background data folder.
bgFolder = fullfile(mainFolder, 'background');
if ~isfolder(bgFolder)
    error('The main folder must contain a subfolder named "background".');
end
cd(bgFolder);

% List .csv files in the background folder.
bgFiles = dir(fullfile(bgFolder, '*.csv'));
if isempty(bgFiles)
    error('No CSV files were found in the "background" folder.');
end

% Load each .csv file into a cell array.
numFiles = numel(bgFiles);
bgData = cell(numFiles, 1);
for i = 1:numFiles
    if isempty(regexp(bgFiles(i).name, '\d+.csv$', 'once'))
        continue; % Skip files that do not end with a number before ".csv".
    end
    filePath = fullfile(bgFolder, bgFiles(i).name);
    bgData{i} = readmatrix(filePath);
end
bgData = bgData(~cellfun(@isempty, bgData));

% Set display flag (1 to show figures, 0 to run silently).
displayResults = 1;
% Call autoAlignAvg.
disp('==1== Aligning and averaging background signal... ==1==');
[~,filename,~] = fileparts(bgFiles(1).name); % Get filename without extension.
baseFilename = regexprep(filename, '\d+$', ''); % Remove trailing digit(s).
avgBackground = autoAlignAvg(bgData, length(bgData), baseFilename, displayResults);
% Save the figure.
saveas(gcf, 'background.fig');
close(gcf);
fprintf('\n');

%% 3. Loop through the remaining subfolders.
% List items in the main folder.
cd(mainFolder);
list = dir(mainFolder);
for k = 1:length(list)
    if list(k).isdir && ~strcmp(list(k).name, '.') && ~strcmp(list(k).name, '..') && ~strcmp(list(k).name, 'background')
        currFolder = fullfile(mainFolder, list(k).name);
        cd(list(k).name);
        disp(['-- CURRENT FOLDER: ' list(k).name '--']);
        fprintf('\n');
        
        % Get a list of CSV files inside the current folder.
        fileList = dir(fullfile(currFolder, '*.csv'));
        if isempty(fileList)
            disp('No CSV files found in current folder.');
            continue;
        end
        
        % Separate files into patterned and unpatterned groups.
        patternedData = {};
        unpatternedData = {};
        for j = 1:length(fileList)
            filename = fileList(j).name;
            if isempty(regexp(filename, '\d+.csv$', 'once'))
                continue; % Skip files that do not end with a number before ".csv".
            end
            filePath = fullfile(currFolder, fileList(j).name);
            % Here, we assume the filename includes one of the strings
            % 'patterned' or 'unpatterned' (but not both).
            if contains(filename, 'patterned') && ~contains(filename, 'unpatterned')
                patternedData{end+1} = readmatrix(filePath);
                [~,filename,~] = fileparts(fileList(j).name);
                patternedFilename = regexprep(filename, '\d+$', '');
            elseif contains(filename, 'unpatterned')
                unpatternedData{end+1} = readmatrix(filePath);
                [~,filename,~] = fileparts(fileList(j).name);
                unpatternedFilename = regexprep(filename, '\d+$', '');
            else
                % Optionally, skip or handle files with unknown naming.
                disp(['Skipping file: ' fileList(j).name]);
            end
        end
        
        % Check if both groups were found.
        if isempty(patternedData) || isempty(unpatternedData)
            disp(['Folder ' list(k).name ' does not contain both patterned and unpatterned data. Skipping.']);
            continue;
        end
        
        %% 3. Process data.
        % Patterned.
        disp('==2== Aligning and averaging patterned signal... ==2==');
        avgPatterned = autoAlignAvg(patternedData, length(patternedData), ...
            patternedFilename, displayResults);
        saveas(gcf, 'patterned.fig');
%         close(gcf);
        fprintf('\n');
        % Unpatterned.
        disp('==4== Aligning and averaging unpatterned signal... ==4==');
        avgUnpatterned = autoAlignAvg(unpatternedData, length(unpatternedData), ...
            unpatternedFilename, displayResults);
        saveas(gcf, 'unpatterned.fig');
%         close(gcf);
        fprintf('\n');
        
        %% 4. Align the averaged signals (with the background) using autoAlignPUB.
        disp('==5== Aligning all three signals... ==5==');
        % The user has to confirm that they are satisfied with the alignment.
        % The code below will loop until they do.
        tryagain = 'Y';
        while tryagain == 'Y'
            method = input('Method? ("full", "part", or "manual") ', 's');
            baseFilename = regexprep(patternedFilename, '((patterned|unpatterned))_', '');
            alignedResults = autoAlignPUB(avgBackground, ...
                avgPatterned, avgUnpatterned, baseFilename, method, displayResults);
            fprintf('\n');
            tryagain = input('Try again? ("Y" or "N") ', 's');
        end
        
        %% 5. Calculate the spatial enhancement.
        [etaprime, error] = calculateEnhancement(...
            alignedResults(:,4), alignedResults(:,6), alignedResults(:,2), ...
            alignedResults(:,5), alignedResults(:,7), alignedResults(:,3));
        % Quick plot.
        figure;
        shadedErrorBar(alignedResults(:,1), etaprime, error);
        xlabel('Position (px)');
        ylabel('Enhancement (1)');
        
        % Save the data.
        [~, mainFolderName, ~] = fileparts(mainFolder);
        baseFilename = [mainFolderName '_' list(k).name '_enhancement.csv'];
        % Results array: pixel position, spatial enhancement, error.
        results = [(1:length(etaprime)).', etaprime, error];
        save(baseFilename, 'results', '-ascii');

        %% 6. Pause before moving on.
        disp([list(k).name ' complete. Press any key to continue...']);
        pause;
%        disp([list(k).name ' complete. Moving on to the next dataset...']);
%        pause(5); % Wait 5 seconds...
        clc;
        close all;
        % fprintf('\n');
        cd(mainFolder);
        
    end
end

cd(homeFolder);
disp('All data processing complete!');