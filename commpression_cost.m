%---------------------------------------------------
%AUTHORS: Sofia Fernandes, Hadi Fanaee-T, Joao Gama
%---------------------------------------------------

function cost=commpression_cost(X)
%------------------------------
% INPUT
%   X [sptensor]: supergraph adjacency matrix
%------------------------------
% OUTPUT
%   cost [int]: compression cost of the summary (2*ceil(log2(#nodes)*(#edges))) 
%------------------------------

cost=2*ceil(log2(max(size(X))))*length(X.subs);