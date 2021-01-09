%% PROMPTS
%
% #JAN.8
%  Curve only.
%
% #JAN.18
%  One process grows, another process prunes.
%
% #JAN.24
%  500 lines.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PHYSICAL SETUP
clear all
clc
% Imperturbed Band-Structure
t = 1;
ell = 1;
N = 10^4;
dk = 2*pi/N;
k = linspace(dk,pi/ell,N/2);
tk = -2*t*cos(k.*ell);

% Perturbative Physical Scales
  U = linspace(0.01,10,25); % 25 -> 250 for pretty graphics (but heavy!)
  a = linspace(-4,4,25);    % 25 -> 250 for pretty graphics (but heavy!)

%% MAIN 

if ~isfile('Data.mat')

% Cycle
D = zeros(length(U),length(a));
M = zeros(length(U),length(a));
Emb = zeros(length(U),length(a));
Ek = zeros(length(U),length(a),N/2);
Eku = zeros(length(U),length(a),N/2);
Ekd = zeros(length(U),length(a),N/2);
for i = 1:length(U)
    fprintf('~~~~~~~~~~\n');
    fprintf('U = %.2f\n', U(i));
    fprintf('~~~~~~~~~~\n');
    fprintf('a =', U(i));
    for j = 1:length(a)
        
        % INIT VALUES for mean-field parameters
        Delta = 0.5;
        Magn = 0.5; 
        x = U(i)*(Delta+Magn)/2;
        y = U(i)*(Delta-Magn)/2;
        fprintf('\t%.2f\n', a(j));
        % Looking for Self-Consistency
        [X,Y] = selfconsistence(x,y,U(i),a(j),N,tk);
        D(i,j) = (X+Y)/U(i);
        M(i,j) = (X-Y)/U(i);
        Emb(i,j) = -X*Y/U(i);
        Eku(i,j,:) = sqrt(tk.^2 + (a(j)-X)^2);
        Ekd(i,j,:) = sqrt(tk.^2 + (a(j)-Y)^2);
        Ek(i,j,:) = Eku(i,j,:)+Ekd(i,j,:);
    end
    fprintf('\n');
end

save('Data');

else
    
load('Data')
    
end

fprintf('Computation finished. Press any key to proceed to graphics...\n')
pause

%% GIF BUILDING

filename = 'animated.gif';
tot=0; z=1;
for jU = 1:2*length(U)-2
    fig = figure("Name",sprintf('jU=%d',jU)); Nlines=0;
    for ik = 1:ceil(N/250):N/2
            plot(a,-Ekd(abs(z*jU+tot),1:length(a),ik),'Color',[1 0 0 0.3]); hold on
            plot(a,-Eku(abs(z*jU+tot),1:length(a),ik),'Color',[0 0 1 0.3]); 
            plot(a,Ekd(abs(z*jU+tot),1:length(a),ik),'Color',[1 0 0 0.3]);
            plot(a,Eku(abs(z*jU+tot),1:length(a),ik),'Color',[0 0 1 0.3]); 
            Nlines = Nlines+4;
    end
    Nlines % -> 500 lines. (0^0~~,)
    ylim([-8,8])
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    fprintf('U=%.2f DONE\n',U(abs(z*jU+tot))); 
    drawnow
    InSet = get(gca, 'TightInset'); % [These two lines ensure filling of the fig]
    set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);
    % Capture the plot as an image 
    im = print(fig,'-RGBImage'); % [far better than getframe(), resolution-wise]
    [imind,cm] = rgb2ind(im,256,'nodither'); % ['nodither' improves resolution]
    
    % Write to the GIF File 
      if jU == 1 
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',0.02); 
      else 
          imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.02); 
      end 
      
      if jU == length(U)
         tot = 2*jU; z = -1;
      end
end

close all

%% SELF CONSISTENCY ROUTINE

function [x,y] = selfconsistence(x,y,U,a,N,tk)

% Self-Consistency definition parameters
SELFx = 0.00001;
SELFy = 0.00001;

% Mixing Parameter -> Tunable Speed
SELFmix = 0.9;
PRODmix = 1-SELFmix;

stepCOUNTER = 0;
exitFLAG = false;
while exitFLAG ~= true

    % Computing new parameters
    X = U/N*sum((a-y)./sqrt(tk.^2 + (a-y).^2));
    Y = U/N*sum((a-x)./sqrt(tk.^2 + (a-x).^2));
    if imag(X) ~= 0 || imag(Y) ~= 0
       fprinft('ERROR')
       break
    end

    % Computing relative distances from self-consistency
    Dx = abs(x-X); dx = norm(Dx/x);
    Dy = abs(y-Y); dy = norm(Dy/y);
    
    % ~Comparison and Move~
    if (dx < SELFx && dy < SELFy) || stepCOUNTER > 10*N
        exitFLAG = true;
    else
        x = SELFmix * x + PRODmix * X;
        y = SELFmix * y + PRODmix * Y;
    end
    stepCOUNTER = stepCOUNTER + 1;
end
Delta = (x+y)/U;
Magn = (x-y)/U;
end
