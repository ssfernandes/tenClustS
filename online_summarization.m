%---------------------------------------------------
%AUTHORS: Sofia Fernandes, Hadi Fanaee-T, Joao Gama
%---------------------------------------------------

function [error,compression,time]=online_summarization(dataset,T,R,L,type)
%------------------------------
% INPUT
%   dataset [str]:  name of the dataset 
%   T [sptensor]: tensor of format (entities)X(entities)X(time) where T(:,:,t) is the adjacency matrix of the
%				: network at time t
%   R [[x,y]-array]: summarization parameters with x=the number of summary supernodes and y=the number of CP 
%				   : tensor decomposition components (for tenClustS only)
%   L [int]: length of the sliding window
%   type [str]: summarization method {'kM_euc','kM_cos','tenClustS'}
%------------------------------
% OUTPUT
%   error [double list]: reconstruction error by window (error(i) is the
%                      : reconstruction error of the ith window summary)
%   compression [int list]: compression cost by window (compression(i) is
%                         : the compression cost of the ith window summary)
%   time [double list]: running time by window (time(i) is the time
%                     : required to generate the ith window summary)
%------------------------------
% DESCRIPTION
%   Computes the summaries of the graphs in a sliding window
%------------------------------

%---------------------------
%    DATA PRE-PROCESSING
%---------------------------

%remove network lacets/self-loops
N=max(size(T,1:2));
T(combvec([1:N; 1:N], 1:size(T,3))')=0;

%generate a symmetric tensor in  modes 1 and 2
T(T.subs(:,[2,1,3]))=1;

%discard weights
T=sptensor(T.subs,1,size(T));

%---------------------------
% 	   SUMMARIZATION
%---------------------------

%initialize parameters
Tt=size(T,3); %total number of time stamps
t=L+1; %incoming time stamp
W=T(:,:,1:L); %first window

%off-line processing - 1st window
%---------------------------
[S{1},Ag{1},Ag_{1},error(1),compression(1),time(1)]=summarize(W,R,type);

%on-line processing
%---------------------------  
while t<=Tt
    %generate summary of the current window
    [S{t-L+1},Ag{t-L+1},Ag_{t-L+1},error(t-L+1),compression(t-L+1),time(t-L+1)]=summarize(T(:,:,t-L+1:t),R,type);
    
    %update time stamp
    t=t+1;
end

%---------------------------
% 	   STORE RESULTS
%---------------------------
if length(R)==1 %store the results of the non-decomposition-based methods
    save(strcat(type,'_results_',dataset,'_NC_',num2str(R),'_WL_',num2str(L)), 'S', 'Ag','Ag_','compression', 'error','time')
else %store the results of tenClustS 
    save(strcat(type,'_results_',dataset,'_NC_',num2str(R(1)),'_F',num2str(R(2)),'_WL_',num2str(L)), 'S', 'Ag','Ag_','compression','error','time')
end
