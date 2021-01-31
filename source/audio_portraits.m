%% PROMPTS
%
% >JAN.3 
%  Make something human.
%
% >JAN.14
%  // SUBDIVISION
%
% >JAN.28 
%  Use sound.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc

isTest = false;

fprintf('Reading input audio..');
[signal,fs] = audioread('audio.mp3');
fprintf('.DONE\n');
centroid = spectralCentroid(signal,fs);
maxFreq = 2000;
centroid(centroid>maxFreq) = maxFreq;

%% Plotting centroid vs time
%  t = linspace(0,size(signal,1)/fs,size(centroid,1));
%  plot(t,centroid)
%  xlabel('Time (s)')
%  ylabel('Centroid (Hz)')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Setup of the AVI container..');
VideoFrameRate = 12;
if isTest
    uncut = signal;
    signal = signal(1:10 * fs, :); % select the first 10s
end
AudioStep = fs / VideoFrameRate;
videoFWriter = vision.VideoFileWriter('out.avi', 'FileFormat', 'AVI',...
    'FrameRate', VideoFrameRate, 'AudioInputPort', true);
fprintf('.DONE\n');

Nframes = round(VideoFrameRate * length(signal) / fs);
fprintf('STARTING TO BUILD A %d-FRAMES MOVIE\n',Nframes);
fprintf('****************************************\n');
for i = 1:Nframes
    TempIndexBeginning  = floor((i - 1) * AudioStep) + 1;
    TempIndexEnding     = ceil(TempIndexBeginning + AudioStep - 1);
    AudioFrame = signal(TempIndexBeginning:TempIndexEnding);
    AudioFrame = AudioFrame';
    centroid = spectralCentroid(AudioFrame,fs);
    centroid = sum(centroid);
    centroid(isnan(centroid))=maxFreq-10;
    centroid = maxFreq-sum(centroid);
    centroid = abs(centroid);
    fprintf('%d out of %d:\n',i,Nframes);
 %% Making centroid-controlled picture 
 %  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 %  Assuming 'epswartz/block_distortion' package to be installed (v.1.0.1)
 %
 %  If not just run:
 %
 %  $ pip3 install block_distortion
 %
 %  on a terminal
 %
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 %
 % Usage: block_dist single [OPTIONS] IMAGE_PATH
 % 
 %   Produce a single image with distortion effects.
 % 
 % Arguments:
 %   IMAGE_PATH  Input file (png, jpg, etc)  [required]
 % 
 % Options:
 %   --splits INTEGER  Number of times to split the image  [default: 2000]
 %   --out TEXT        Name of output file (gif)  [default: ./output.png]
 % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    pkg = 'block_dist';
    cmd = 'single';
    opt = sprintf('--splits %d --out temp.jpg',round(centroid));
    fid = './in.jpg';
    fprintf('> generating...');
    system([pkg,' ',cmd,' ',opt,' ',fid]);
    fprintf('  ...DONE\n');
 %% Appending Frames
    fprintf('> reading..');
    TempImage = imread('temp.jpg'); fprintf('.done\n');
    fprintf('> writing..');
    step(videoFWriter, TempImage, AudioFrame); fprintf('.done\n');
end
release(videoFWriter);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Assuming 'FFmpeg' package to be installed
%
% If not just run:
%
% $ sudo apt install ffmpeg
%
% on a terminal
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fprintf('********************\n');
fprintf('CONVERTING TO MP4...\n\n');
system('ffmpeg -i out.avi out.mp4');
delete('temp.jpg');
delete('out.avi'); 
fprintf('\n\n!!FINISHED!!\n');
fprintf('********************\n');
fprintf('********************\n');
