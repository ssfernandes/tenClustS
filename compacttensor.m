%---------------------------------------------------
%AUTHORS: Sofia Fernandes, Hadi Fanaee-T, Joao Gama
%---------------------------------------------------

function [X,active_ids]=compacttensor(T)
%-----------------------------------------
%INPUT
%   > T: sparse tensor
%---------------------------------
% the function removes the mode 1/mode 2 slices having no non zero entries

th=0;

%get number of ids
N=max(size(T,1:2));

old_subs=T.subs;

%get ids with at least a non-zero entries
active_ids=union(unique(T.subs(:,1)),unique(T.subs(:,2)));
new_ids=[];
for i=1:length(active_ids)
    if sum(T.subs(:,1)==active_ids(i))>th
        new_ids=[new_ids,active_ids(i)];
    end
end
active_ids=new_ids;

%generate new ids
new_N=length(active_ids);

%generate new tensor subs
new_subs=zeros(size(old_subs));
for i=1:new_N
    new_subs(find(old_subs(:,1)==active_ids(i)),1)=i;
    new_subs(find(old_subs(:,2)==active_ids(i)),2)=i;
end
new_subs(:,3)=old_subs(:,3);

%discard subs assoicated to less active ids
new_subs(or((new_subs(:,1)==0),(new_subs(:,2)==0)),:)=[];

%generate tensor 
X=sptensor(new_subs,1);

while length(unique(X.subs(:,1)))~=size(X,1)
    %get ids with at least a non-zero entries
    active_ids=union(unique(X.subs(:,1)),unique(X.subs(:,2)));
    new_ids=[];
    for i=1:length(active_ids)
        if sum(X.subs(:,1)==active_ids(i))>0
            new_ids=[new_ids,active_ids(i)];
        end
    end
    active_ids=new_ids;

    %generate new ids
    new_N=length(active_ids);

    %generate new tensor subs
    old_subs=X.subs;
    new_subs=zeros(size(old_subs));
    for i=1:new_N
        new_subs(find(old_subs(:,1)==active_ids(i)),1)=i;
        new_subs(find(old_subs(:,2)==active_ids(i)),2)=i;
    end
    new_subs(:,3)=old_subs(:,3);

    %discard subs assoicated to less active ids
    new_subs(or((new_subs(:,1)==0),(new_subs(:,2)==0)),:)=[];

    %generate tensor 
    X=sptensor(new_subs,1);
end
