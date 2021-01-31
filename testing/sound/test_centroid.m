clear all
clc

isTest = true;

fprintf('Reading audio input..');
[signal,fs] = audioread('music.mp3');
[signal2,fs2] = audioread('thunder.mp3');
fprintf('.DONE\n');
centroid = spectralCentroid(signal,fs);
maxFreq = 4000;

%% Plotting centroid vs time
   t = linspace(0,size(signal,1)/fs,size(centroid,1));
   plot(t,centroid)
   xlabel('Time (s)')
   ylabel('Centroid (Hz)')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Setup of the AVI container..');
VideoFrameRate = 24;
if isTest
    signal = signal(1:10 * fs, :); % select the first 10s
end
AudioStep = fs / VideoFrameRate;
videoFWriter = vision.VideoFileWriter('out.avi', 'FileFormat', 'AVI',...
    'FrameRate', VideoFrameRate, 'AudioInputPort', true);
fprintf('.DONE\n');
Nframes = (VideoFrameRate * length(signal) / fs);
for i = 1:Nframes
    TempIndexBeginning  = floor((i - 1) * AudioStep) + 1;
    TempIndexEnding     = ceil(TempIndexBeginning + AudioStep - 1);
    AudioFrame = signal(TempIndexBeginning:TempIndexEnding);
    AudioFrame2 = signal2(TempIndexBeginning:TempIndexEnding);
    AudioFrame = AudioFrame'; AudioFrame2 = AudioFrame2';
    centroid = spectralCentroid(AudioFrame,fs);
    fig = figure('visible','off');
    color = [0 centroid(1)/maxFreq centroid(2)/maxFreq];
    color(isnan(color))=1; color(color>1) = 1;
    rectangle('Position',[0,0,1,1],'FaceColor',color)
    ax = gca;
    ax.Visible = 'off';
    set(gca, 'Position', [0.02,0.1,1,0.82])
    set(gcf,'OuterPosition',[50 50 680 700]);
    outerpos = ax.OuterPosition;
    ti = ax.TightInset; 
    left = outerpos(1) + ti(1);
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];
    TempImage = print(fig,'-RGBImage');
    close(fig);
    fprintf('> [%d/%d] writing frame..',i,Nframes);
    step(videoFWriter, TempImage, AudioFrame2); fprintf('.done\n');
end
release(videoFWriter);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Assuming $sudo apt install ffmpeg$ to have been run
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fprintf('********************\n');
fprintf('CONVERTING TO MP4...\n\n');
system('ffmpeg -i out.avi out.mp4');
delete('out.avi'); 
fprintf('\n\n!!FINISHED!!\n');
fprintf('********************\n');
fprintf('********************\n');
