function bat = run_network(G,bat)
% this section will simulate a unit of operation of the network
% Selecting a random node as a source of the data . Selecting a path from
% that source to the sink node depends on the (1) lowest battery node in the
% path , (2) the total energy consumption of the path and (3) the shortest
% path.

MAX_bat=1000;
a=10;
bat_eme=0.2*a;
EM=0.03*a;
ET=0.2*a;
ER=0.02*a;
maxpaths=50;

N=numnodes(G);

%% choosing node
K = 2:N;
k = K(randi([1 numel(K)]));
%% choosing path from all paths
[paths] = allpaths(G,k,1,'MaxNumPaths',maxpaths);
%paths = paths(1:maxpaths);

check_minbat= Inf(size(paths,1),1);        %mat check if a node's energy is lower than 50%
%check_ec=zeros(size(paths,1),1);             %mat that get energy consume of paths 

%% check lowest battery node in the path
E = E_consumption(G);
for i=1:size(paths,1)
    for j = 2:numel(paths{i})
        if E(paths{i}(j))<check_minbat(i)
            check_minbat(i)=E(paths{i}(j));
        end
    end
end
[~,path_index]=max(check_minbat);          % if all paths have node < 50, take the less e_consum path
path = paths{path_index};

%% check path total energy consumption
%{
for i=1:size(paths,1)                       % check every path              {i} is index of paths
    for j = 2: numel(paths{i})              % check every nodes in a path   (j) is index of node in that paths
        if j==1                             % path{i}(j) la j-th node in i-th path
           check_ec(i) = check_ec(i) + (EM+ET*G.Edges.Weight(findedge(G,paths{i}(j+1),paths{i}(j)))) ;
        elseif j==numel(paths{i})
           check_ec(i) = check_ec(i) + (EM+ER*G.Edges.Weight(findedge(G,paths{i}(j-1),paths{i}(j)))) ; 
        else
           check_ec(i) = check_ec(i) + (EM+ER*G.Edges.Weight(findedge(G,paths{i}(j-1),paths{i}(j)))+ET*G.Edges.Weight(findedge(G,paths{i}(j+1),paths{i}(j)))) ; 
        end
    end
end
%% if not, take the shortest path
if sum(sum(check_minbat))==0
    [~,path_index]=max(check_ec);          % if all paths have node < 50, take the less e_consum path
    path = paths{path_index};
end
%}
%% execute path
%path = shortestpath(G,k,1);
if(path)
    for i=1:size(path,2)
        if i==1
           bat(path(i)) = bat(path(i))-(EM+ET*G.Edges.Weight(findedge(G,path(i+1),path(i)))) ;
        elseif i==size(path,2)
           bat(path(i)) = bat(path(i))-(EM+ER*G.Edges.Weight(findedge(G,path(i-1),path(i)))) ; 
        else
           bat(path(i)) = bat(path(i))-(EM+ER*G.Edges.Weight(findedge(G,path(i-1),path(i)))+ET*G.Edges.Weight(findedge(G,path(i+1),path(i)))) ; 
        end
    end
else
    disp('lost packet')
end

