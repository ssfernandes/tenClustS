%---------------------------------------------------
%AUTHORS: Sofia Fernandes, Hadi Fanaee-T, Joao Gama
%---------------------------------------------------

function Ag_=lifted_adjacency_matrix(S,Ag,dims)
%------------------------------
% INPUT
%   S [cell array]: supernode assignment where S{i} is a list of entities
%                 : forming supernode i
%   Ag [sptensor]: supergraph adjacency matrix
%	dims [int]: size of the original network
%------------------------------
% OUTPUT
%   Ag_ [sptensor]:  adjacency matrix of the reconstructed graph
%------------------------------
% DESCRIPTION
%   Computes the lifted adjacency matrix of a supergraph Ag
%------------------------------

%compute lifted matrix
Ag_=sptensor(dims);
for i=1:length(Ag.subs)
    Ag_(combvec(S{Ag.subs(i,1)},S{Ag.subs(i,2)})')=Ag(Ag.subs(i,1),Ag.subs(i,2));
end

%remove non-zeros from diagonal (because the network is assumed to be indirected)
Ag_([1:min(dims);1:min(dims)]')=0;

