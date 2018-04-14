%---------------------------------------------------
%AUTHORS: Sofia Fernandes, Hadi Fanaee-T, Joao Gama
%---------------------------------------------------

function [error]=summary_error(X,Xr)
%------------------------------
% INPUT
%   X [sptensor]: original window network in tensor format
%   Xr [sptensor]: summary lifted adjacency matrix (which approximates the original window)
%------------------------------
% OUTPUT
%   error [double]: reconstruction error of the summary
%------------------------------
% DESCRIPTION
%   Computes the reconstruction error of the supergraph associated to the lifted adjacency matrix Xr
%------------------------------

%get window length
L=size(X,3);
N1=size(X,1);
N2=size(X,2);

%------------------------------
%       ERROR COMPUTATION
%------------------------------
error=0;
for l=1:L
	%compute error in the l^th timestamp
    E=X(:,:,l)-Xr; 
	
	%accumulate error
    error=error+sum((abs(E.vals)));
end
error=error/(L*N1*N2);


