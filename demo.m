%---------------------------------------------------
%AUTHORS: Sofia Fernandes, Hadi Fanaee-T, Joao Gama
%---------------------------------------------------

%load data
load('synthdata')

%for results storage purposes, assign a name to the dataset being considered (or use '' otherwise)
dataset='synth';

%set params of the summarization
L=3; %window length
R=5;%number of supernodes of the summary
F=5;%number of CP tensor decomposition components (for tenClustS only)

%generate summaries using kM_euc
type='kM_euc';
[error_kmeuc,compression_kmeuc,time_kmeuc]=online_summarization(dataset,T,R,L,type);

%generatesummaries using kM_cos
type='kM_cos';
[error_kmcos,compression_kmcos,time_kmcos]=online_summarization(dataset,T,R,L,type);

%generate summaries using tenClustS
type='tenClustS';
[error_tcs,compression_tcs,time_tcs]=online_summarization(dataset,T,[R,F],L,type);

%compute results statistics
fprintf('\n\nResults report on:\n')
fprintf('- reconstruction error (RE)\n')
fprintf('- compression cost(CC)\n')
fprintf('- running time (T)\n\n')
fprintf('Method   |     RE              CC              T\n');
fprintf('------------------------------------------------------\n')
fprintf('kM-euc   | %.3f+/-%.3f %.3f+/-%.3f %.3f+/-%.3f \n',mean(error_kmeuc),std(error_kmeuc),mean(compression_kmeuc),std(compression_kmeuc),mean(time_kmeuc),std(time_kmeuc))
fprintf('kM-cos   | %.3f+/-%.3f %.3f+/-%.3f %.3f+/-%.3f \n',mean(error_kmcos),std(error_kmcos),mean(compression_kmcos),std(compression_kmcos),mean(time_kmcos),std(time_kmcos))
fprintf('tenClustS| %.3f+/-%.3f %.3f+/-%.3f %.3f+/-%.3f \n',mean(error_tcs),std(error_tcs),mean(compression_tcs),std(compression_tcs),mean(time_tcs),std(time_tcs))
