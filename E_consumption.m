function Result = E_consumption(G)
% The result is a matrix evaluate the distribution of energy consumption of
% every node in the network

EM=0.03;
ET=0.2;
ER=0.02;

N = numnodes(G);
E = zeros(N,1);
for i=2:N
    path=shortestpath(G,i,1);       %path co dang               [5 2 3 23 1]
    for node = 1:numel(path)        %node la index cua path      1 2 3 4  5
        if node ==1                 %path(node) la so thu tu cua node trong path do
            E(path(node))=E(path(node))+(EM+ET*G.Edges.Weight(findedge(G,path(node+1),path(node))));
        elseif node == numel(path)
            E(path(node))=E(path(node))+(EM+ER*G.Edges.Weight(findedge(G,path(node-1),path(node)))) ;
        else
            E(path(node))=E(path(node))+(EM+ER*G.Edges.Weight(findedge(G,path(node-1),path(node)))+ET*G.Edges.Weight(findedge(G,path(node+1),path(node)))) ;
        end
    end
end
Result=E;