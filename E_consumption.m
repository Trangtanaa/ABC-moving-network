function Result = E_consumption(G,bat)
% The result is a matrix evaluate the distribution of energy consumption of
% every node in the network
maxpaths=100;
EM=0.03;
ET=0.2;
ER=0.02;

N = numnodes(G);
E = zeros(N,1);
for k=2:N
    %path=shortestpath(G,i,1);       %path co dang               [5 2 3 23 1]
    [paths] = allpaths(G,k,1,'MaxNumPaths',maxpaths);
    if (size(paths,1)~=0)
    check_minbat= inf(size(paths,1),1); 
    for i =1:size(paths,1)                       %check every path
        for j = 2:numel(paths{i})               %check path's members
            if bat(paths{i}(j))<check_minbat(i)
                check_minbat(i)=bat(paths{i}(j));
            end
        end
    end
    [~,path_index]=max(check_minbat);          
    path = paths{path_index};
    else
        path=[];
    end
if (path)
    for node = 1:numel(path)        %node la index cua path      1 2 3 4  5
        if node ==1                 %path(node) la so thu tu cua node trong path do
            E(path(node))=E(path(node))+(EM+ER*G.Edges.Weight(findedge(G,path(node+1),path(node))));
        elseif node == numel(path)
            E(path(node))=E(path(node))+(EM+ER*G.Edges.Weight(findedge(G,path(node-1),path(node)))) ;
        else
            E(path(node))=E(path(node))+(EM+ER*G.Edges.Weight(findedge(G,path(node-1),path(node)))+ET*G.Edges.Weight(findedge(G,path(node+1),path(node)))) ;
        end
    end
end
end
Result=E;