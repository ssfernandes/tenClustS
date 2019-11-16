%---------------------------------------------------
%AUTHORS: Sofia Fernandes, Hadi Fanaee-T, Joao Gama
%---------------------------------------------------

function [S,Ag,Ag_,error,compression,time]=summarize(Wnew,R,type)
%------------------------------
% INPUT
%   Wnew [sptensor]: current tensor window of format (entities)X(entities)X(time) where T(:,:,t) is the adjacency  
%				   : matrix of the network at time stamp t in the window
%   R [[x,y]-array]: summarization parameters with x=the number of summary supernodes and y=the number of CP tensor 
%				   : decomposition components (for tenClustS only)
%   type [str]: summarization method {'kM_euc','kM_cos','tenClustS'}
%------------------------------
% OUTPUT
%   S [cell]: supernodes assignment
%   Ag [sptensor]: adjacency matrix of the summary generated 
%   Ag_ [sptensor]: lifted adjacency  matrix (of the reconstructed network)
%   error [double]: reconstruction error  of the summary generated
%   compression[double]: compression cost of the summary generated
%   time [double]: running time required to generate the summary
%------------------------------
% DESCRIPTION
%   Given the tensor window, construct the summary supergraph and compute its reconstruction error and compression cost
%------------------------------

%------------------------------
%  		PARAMETER INIT
%------------------------------

%set random seed for reproducibility
rng(0); 

%store original tensor window 
W=Wnew;

%process parameters
if length(R)==2 % use different number of components and number of supernodes 
    F=R(2); % number of CP components
    R=R(1); % number of supernodes
else % use the same number of components as the number of supernodes
    F=R;
end

%get window size
L=size(Wnew,3);

%remove nodes with no activity in the window
[Wnew,ids]=compacttensor(Wnew);
entities=1:size(Wnew,1); 

%------------------------------
%    SUPERNODE ASSIGNMENT
%------------------------------
tic;
if strcmp(type,'kM_euc') 
	%   kM_euc
	%------------
	
	%collapse tensor window into single matrix 
    T=sptensor(Wnew.subs(:,1:2),1,size(Wnew,1:2));
    T=sparse(T.subs(:,1),T.subs(:,2), T.vals,size(T,1),size(T,2)); %format conversion
    
    %apply kmeans with eucledian distance to the representation obtained
    clusters=kmeans(T,R,'Replicates',5);
    
elseif strcmp(type,'kM_cos')
	%   kM_cos
	%------------
	
	%collapse tensor window into single matrix 
    T=sptensor(Wnew.subs(:,1:2),1,size(Wnew,1:2));
    T=sparse(T.subs(:,1),T.subs(:,2), T.vals,size(T,1),size(T,2)); %format conversion
    
    %apply kmeans with cosine distance to the representation obtained
    clusters=kmeans(T,R,'Distance','cosine','Replicates',5);    
     
elseif strcmp(type,'tenClustS')
	%   tenClustS
	%---------------
        
	%apply tensor decomposition to window	
	[Wr]=cp_als(Wnew,F,'init','nvecs','dimorder',[3,1,2]);
   
	%generate node representation
	for r=1:F 
		E(:,r)=Wr.lambda(r)*Wr.U{1}(:,r);
	end
         
    %assign supernodes/clusters by applying
    clusters=kmeans(E,R,'Replicates',5);
else
    warning('Invalid summarization method. Please consider one of the following methods: kM_euc, kM_cos, tenClustS', 'ERROR', 'error')
end
 
%------------------------------
%    SUPEREDGE COMPUTATION
%------------------------------
%store supernodes/clusters
S=cell(1,R);
for r=1:R
    S{r}=entities(clusters==r);
end 
if exist('ids','var') %map nodes to their original ids
    X={};
    for i=1:length(S)
        for j=1:length(S{i})
            X{i}(j)=ids(S{i}(j));
        end
    end
    S=X;
end

%generate adjacency matrix for the tensor window
Aw=sptensor(W.subs(:,1:2),1, [size(W,1),size(W,2)]); % adjacency matrix with all the links existing in the window
    
%generate supergraph adjacency matrix
Ag=sptensor([R,R]); %initialization
for r1=1:R %aggregation by supernode
    Gr1=ismember(Aw.subs,S{r1}); %select subs having an element on cluster r1
    nr1=length(S{r1}); %get the number of nodes in supernode r1
    wr1r1=sum(Aw.vals(sum(Gr1,2)==2)); %get the number of edges in cluster (in duplicated)
    if nr1>1
        Ag(r1,r1)=wr1r1/(L*nr1*(nr1-1)); %generate weight
    else
        Ag(r1,r1)=wr1r1/(L);
    end
    for r2=(r1+1):R
        Gr2=ismember(Aw.subs,S{r2}); %select subs having an element on cluster r2
        nr2=length(S{r2}); %select subs having an element on supernode r2
        wr1r2=sum(Aw.vals(sum([Gr1(:,1),Gr2(:,2)],2)==2)); %get number of edges between cluster r1 and r2
        if (nr1>0 && nr2>0)
            Ag(r1,r2)=wr1r2/(L*nr1*nr2); %generate weight
            Ag(r2,r1)=Ag(r1,r2);
        end
    end
end
time=toc;

%------------------------------
%	  QUALITY ASSESSMENT
%------------------------------
%generate lifted matrix (reconstructed graph)
Ag_=lifted_adjacency_matrix(S,Ag, [size(W,1),size(W,2)]);

%compute summary quality regarding reconstruction error and compression
error=summary_error(W,Ag_);
compression=commpression_cost(Ag);






