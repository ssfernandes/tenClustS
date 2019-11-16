%---------------------------------------------------
%AUTHORS: Sofia Fernandes, Hadi Fanaee-T, Joao Gama
%---------------------------------------------------

%load data
load('synthdata')

%set params of the summarization
R=5;%number of supernodes of the summary
F=5;%number of CP tensor decomposition components 

%generate summaries using tenClustS
[S,Ag,Ag_,error,compression,time]=summarize(T,R,'tenClustS')

fprintf('tenClustS generated a summary with %d supernodes. The summary reconstruction error is  %2.2d and its compression cost is %2.2d. The method required %2.2d seconds to generate the summary.\n', R, error,compression,time); 