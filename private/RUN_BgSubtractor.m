function [] = RUN_BgSubtractor(images_in_ch_folder, background_ch_folder, normalization_ratio)

%% input
signal_directory = images_in_ch_folder;
noise_directory = background_ch_folder;
ncores = 20; % Number of Cores


% Get file names
signal_files = dir([signal_directory, filesep, '*.tif']);
noise_files = dir([noise_directory, filesep, '*.tif']);

%parfor (i = 1:length(signal_files), ncores)
for i = 1:length(signal_files)
    %% loading data

    % Name the output file
    output_fileName = [fileparts(signal_files(i).folder), filesep, 'Signal_minus_Noise', filesep, 'signal_minus_noise__' signal_files(i).name];

    if isempty(dir(output_fileName))


        % Signal
        signal_fileName = [signal_files(i).folder, filesep, signal_files(i).name]; % Get name of signal file
        signaldata = imread(signal_fileName, "tif");% Read signal file

        %noise
        noise_fileName = [noise_files(i).folder, filesep, noise_files(i).name]; % Get Name of noise file
        noisedata = imread(noise_fileName, 'tif'); % Read noise file





        %% computation
        % Do signal minus noise subtraction
        % signal_minus_noise = signaldata - noisedata/2; % Original
        signal_minus_noise = signaldata - noisedata/normalization_ratio; % Normalization ratio for noise/background channel added by JL on 20221207

        
        

        
        %% output

        % Write the output file
        if i == 1
            mkdir(fileparts(output_fileName))
        end

        imwrite(signal_minus_noise, output_fileName, 'tif');

        disp(['Saved slice ', num2str(i), ' of ', num2str(length(signal_files))])
    else
        disp(['Already Exists: ', num2str(i), ' of ', num2str(length(signal_files))])
    end
end