%% PROMPTS
%
% >JAN.9
%  Interference patterns.
%
% >JAN.19
%  Increase the randomness along the y-axis.
%
% >JAN.27
%  Monochrome gradients without lines.
%
% >JAN.30
%  Replicate a natural concept.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc

global N I0 d w k
%% Physical Constants
N = 2;               %  #{slits}
I0 = 1/N^2;          %  peak-intensity
d = 5;               %  distance between slits
w = 1;               %  width of the slits
k = 1;               %  wavevector of the beam

% Spatial Resolution (for classical)
r = 0.1;

%% Options
isTest = false;
isAnimated = false;
isWide = true;

% Number of Frames (for animation)
Nframes = 30;

%% Check & Tune 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isTest == true                                %
    x = linspace(-d,d,1000);                     %
    quantum = fraunhofer(x);                     %
    gauss = @(x,sig)exp(-((x.^2)/(2*sig.^2)));   %
    classical = gauss(x-d/2,r)+gauss(x+d/2,r);   %
    u = montecarlo(5e5);                         %
    histogram(u,1000,'Normalization','pdf');     %
    hold on                                      %
    plot(x,quantum,'r','LineWidth',1.2);         %
    plot(x,classical,'y','LineWidth',1.2);       %
end                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Main
if isTest == false
    if ~isAnimated
        Nframes = 1;
        filename = 'static.png';
    else
        filename = 'animated.gif';
    end
    %% Looping on Frames
    for i = 1:Nframes
        y = linspace(1,30,500);
        fprintf('Frame %d of %d:\n', i, Nframes)
        fprintf('> Generating[0%%]\n');
        fig = figure('visible','off');
        canvas = rectangle('position',[-d 1 2*d 29]); hold on
        canvas.FaceColor = [0 0 0];
        xlim([-d,d])
        ylim([1,30])
        ax = gca;
        set(ax,'xtick',[])
        set(ax,'ytick',[])
        axis off
        if isWide
            set(gcf, 'Units', 'Normalized',...
                'OuterPosition', [0 0 1 1]);
        end
        %% Looping on horizontal lines
        for j = 1:500
           height = y(j);
           if mod(j,5) == 0
               clc
               fprintf('Frame %d of %d:\n', i, Nframes)
               fprintf('> Generating[%.d%%]\n',j/5);
           end
           if ~isAnimated
                nDraws = ceil(5*i*height^2);
           else
                nDraws = ceil(0.15*i*height^2);
           end
           quantum = montecarlo(nDraws); 
           hline = height*ones(size(quantum));
           scatter(quantum,hline,1,'g','filled',...
               'MarkerFaceAlpha',1/20,'MarkerEdgeAlpha',0);
           classicalSx = r.*randn(nDraws,1)-d/2;
           scatter(classicalSx,hline,1,'y','filled',...
               'MarkerFaceAlpha',1/70,'MarkerEdgeAlpha',0);
           classicalDx = r.*randn(nDraws,1)+d/2;
           scatter(classicalDx,hline,1,'y','filled',...
               'MarkerFaceAlpha',1/70,'MarkerEdgeAlpha',0);
        end
        fprintf('> Finalizing picture..');
        drawnow; fprintf('.DONE\n');
        fprintf('> Writing frame..');
        %[These two lines ensure filling of the fig]
        InSet = get(ax, 'TightInset'); 
        set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3),...
           1-InSet(2)-InSet(4)]);
        if isAnimated == true
            % [far better than getframe(), resolution-wise] 
            im = print(fig,'-RGBImage');
            % ['nodither' improves resolution]
            [imind,cm] = rgb2ind(im,256,'nodither');
            %% Write to the GIF File 
            if i == 1 
              imwrite(imind,cm,filename,'gif',...
                  'Loopcount',inf,'DelayTime',0.1); 
            else 
              imwrite(imind,cm,filename,'gif',...
                  'WriteMode','append','DelayTime',0.1); 
            end 
        else
            %% Write to the PNG File 
            print(fig,filename,'-dpng','-r600')
        end
        fprintf('.DONE\n');
    end
end

function I = fraunhofer(x)
%% Fraunhofer Theory for Diffraction
%  N:  #{slits}
%  I0: peak-intensity
%  d:  distance between slits
%  w:  width of the slits
%  k:  wavevector of the beam

    global N I0 d w k

    a = k*d/2; % optical renormalization
    b = k*w/2; % of the relevant lengths
    
    ax = a.*x; % vectorization of the
    bx = b.*x; % two relevant products
    
    single_slit_term = (sin(bx)./bx).^2;
    N_slit_term = (sin(N*ax)./sin(ax)).^2;
    
    norm_intensity = single_slit_term.*N_slit_term;
    
    I = I0*norm_intensity;

end

function u = montecarlo(nDraws)
%% HIT or MISS generation
%  Extracts nDraws numbers pseudo-distributed as
    global d
    x = linspace(-d,d,1000);
    v = max(fraunhofer(x));
    shape = [nDraws*10,1];
    nAccepted = 0;
    while nAccepted < nDraws
          u = random('uniform',-d,d,shape);
          t = fraunhofer(u);
          y = random('uniform',0,v,shape);
          condition = y<t; u = u(condition);
          nAccepted = length(u);
    end
    u = u(1:nDraws); % Trims out *exactly* nDraws elements
end