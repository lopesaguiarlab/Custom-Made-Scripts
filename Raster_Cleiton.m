%% Load events, LFPs and clusters

close all

%clear all

[data, timestamps, info] = load_open_ephys_data_faster('/Users/cleitonlopesaguiar/Documents/100_CH50.continuous');% please adjust according to your path
% 
[data2, timestamps2, info2] = load_open_ephys_data_faster('/Users/cleitonlopesaguiar/Documents/all_channels.events'); 



% X=hdf5read('home/kamran/Documents/RX-hippo.kwik', '/channel_groups/0/spikes/time_samples');
% Y=hdf5read('home/kamran/Documents/RX-hippo.kwik', '/channel_groups/0/spikes/clusters/main');

X=hdf5read('/Users/cleitonlopesaguiar/Documents/R10-7.kwik', '/channel_groups/6/spikes/time_samples'); 
Y=hdf5read('/Users/cleitonlopesaguiar/Documents/R10-7.kwik', '/channel_groups/6/spikes/clusters/main');

%% Organize time-stamps and run event-triggered field average

aux=[1:2:length(timestamps2)];

timestamps2N=timestamps2(aux);

timestamps2N=timestamps2N-timestamps2N(1);

Diff=diff(timestamps2N);
idx_pulses=find(Diff>20);
timestamps_Final=timestamps2N(idx_pulses);

for i=2:length(timestamps_Final-2); 
    
    a=round((timestamps_Final(i)-0.2).*30000); b=round((timestamps_Final(i)+0.3).*30000); 
    
    c=round((timestamps_Final(i)-0.5).*30000); d=round((timestamps_Final(i)+1).*30000); 
    
    dt=1/30000;
    v=((1:1:length(data(a:b)))*dt*1000);
    
    v2=((1:1:length(data(c:d)))*dt*1000);
   
   
   M1(:,i)=data(a:b);
    
    plot(v-200,data(a:b)); 
    ylim([-1000 1000]); 
    title(num2str(i));
    
    M2(:,i)=data(c:d);
    
    
    
    
    %M2(:,i)=M(1,a:b);
    
%     c=c+1;
%     d=d+1;
    
    pause(0.02); 
    
end;

close all

figure(2);
plot(v-200,mean(M1,2),'color',[0 0.44 0.74],'LineWidth',3);
 set(gca,'XTick',-100:50:300);
 ylim([-400 400]); 
 xlim([-100 300]);
 xlabel('Time (ms)')
 ylabel('Amplitude (uV)');
 set(gcf,'color',[1 1 1]);
 %line([15 15],[-1000 1000],'Color',[.5 .5 .5],'LineStyle', '--');
 box off
 
 %% Plot field response for all trials 

figure;
for i=2:40; 
    
    a=i-1;
    subplot(4,10,i); 
    
    plot(v2-500,M2(:,i)); 

    ylim([-1000 1000]); title(num2str(a)); 
    xlim([-500 1000]);
    
    xlabel('Time (ms)'); ylabel('Voltage (uV)'); 
    set(gcf,'color',[1 1 1]); 

end;

figure;
colormap parula; imagesc(v2-500,1:150,M2(:,1:150)'); set(gca,'YDir','normal'); colorbar;
hold on
line([0 0],[1 150],'color',[0.5 0.5 0.5],'linewidth',1.5);
line([-500 1000],[45 45],'color',[0 0 0],'linewidth',1);
line([-500 1000],[70 70],'color',[0 0 0],'linewidth',1);
xlabel('Time (ms)'); ylabel('Trials'); 
c=colorbar;
ylabel(c,'Voltage (uV)')
set(gcf,'color',[1 1 1]);


 
 %% Organize Spike data 
 
%good=[2,5,8,9,11,14,40,60,61,67,73,78,87,89,101,103];

%good=[2,5,6,7,12,18,19,21,22,46,51,53,54,55,59,60,61,64];

%good=[5,9,40,87,101,103]; % from the observation of clusters in the klustaviewa

%good=[4,12,17,20,24,40,45,46,55,56];

%good=[2,5,6,7,12,18,19,21,22,46];

%good=[3,8,9,15,27,33,35,46,48,50,57];

%good=[2,15,20,21,53,54,56,62,65];

%good=[1:1:max(Y)];

good=[1:1:54];

ntrials=length(timestamps_Final);


for i=1:length(good);
U=find(Y==good(i));
UT=X(U);
M=zeros(1,length(data));
M(UT)=1;

UT_double=double(UT);

All_spikes{i}=UT_double; 

end;


%% Raster plot for many trials - one raster per unit (adapted from Matlab for Neuroscientists - Chapter 13) 

ncells=length(good(1,:)); %see All_spikes size

for jj=1:ncells;
    
%figure(jj);
 
    
a=jj; % cell idx in All_spikes {1,ncells}

Fs=30000; % sample rate (default: 30000 Open Ephys)

unit=All_spikes{1,a}./Fs; % spike times in seconds

Neg=-0.5; % Before event (in seconds)

Pos=1; % After event (in seconds)

for i=1:length(timestamps_Final(:,1)); 
    
    
    aux=unit-timestamps_Final(i,1); % determine relative time (spike time - events)
    
    W=find(aux>=Neg & aux<=Pos); % W is the window to be considered in the raster plot
    
    test=aux(W);
    
    if isempty(test)==1;
        
        All_trials{i,:}=NaN; 
        
    else
        
        All_trials{i,:}=aux(W); 
        
    
        for j=1:length(All_trials{i,:}); %Loop through each spike time 
    
    subplot(2,ncells/2,jj);
    hold on;
    line([All_trials{i,:}(j,1) All_trials{i,:}(j,1)], [i-1 i],'color',[0 0.44 0.74],'linewidth',2); %Create a tick mark with a height of 1 for each spike time
    line([0 0],[1 length(timestamps_Final(:,1))],'color',[0.5 0.5 0.5],'linewidth',1.5);
    line([Neg Pos],[45 45],'color',[0.9290 0.6940 0.1250],'linewidth',1.5);
    line([Neg Pos],[70 70],'color',[0.9290 0.6940 0.1250],'linewidth',1.5);
    ylim([1 length(timestamps_Final(:,1))]) 
    xlim([Neg Pos])
    xlabel('Time (sec)');
    ylabel('Trials');
    
    title(num2str(good(jj)));
    
    set(gcf,'color',[1 1 1]);
  
    hold off;
    
        end;
        
    end
        
       
end;

end;



%% Raster for a single trial - several units 
for ii=1:150;
    
figure(ii);

ncells=length(good(1,:)); %see All_spikes size

T=ii; % desired trial number

for jj=1:ncells;
    
%figure(jj);
 
    
a=jj; % cell idx in All_spikes {1,ncells}

Fs=30000; % sample rate (default: 30000 Open Ephys)

unit=All_spikes{1,a}./Fs; % spike times in seconds

Neg=-0.5; % Before event (in seconds)

Pos=1; % After event (in seconds)

for i=T % trial number
    
    
    aux=unit-timestamps_Final(i,1); % determine relative time (spike time - events)
    
    W=find(aux>=Neg & aux<=Pos); % W is the window to be considered in the raster plot
    
    test=aux(W);
    
    if isempty(test)==1;
        
        All_trials{i,:}=NaN; 
        
    else
        
        All_trials{i,:}=aux(W); 
        
    
        for j=1:length(All_trials{i,:}); %Loop through each spike time 
    
    
    hold on;
    line([All_trials{i,:}(j,1) All_trials{i,:}(j,1)], [jj-1 jj],'color',[0 0.44 0.74],'linewidth',2); %Create a tick mark with a height of 1 for each spike time
    %line([0 0],[1 length(timestamps_Final(:,1))],'color',[0.5 0.5 0.5],'linewidth',1.5);
    %line([Neg Pos],[45 45],'color',[0.9290 0.6940 0.1250],'linewidth',1.5);
    %line([Neg Pos],[70 70],'color',[0.9290 0.6940 0.1250],'linewidth',1.5);
    ylim([1 ncells]) 
    xlim([Neg Pos])
    xlabel('Time (sec)');
    ylabel('Cells');
    
    %title(num2str(good(jj)));
    
    set(gcf,'color',[1 1 1]);
  
    hold off;
    
        end;
        
    end
        
       
end;

end;

end;