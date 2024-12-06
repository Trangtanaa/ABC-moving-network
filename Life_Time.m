function result = Life_Time(G,bat)
%whole network energy consumption, which decrease linearly every cycle if
%the network doesnot move

EM=0.03;
ET=0.2;
ER=0.02;
al_bat=0;
N=numnodes(G);
for k=2:N
    path = shortestpath(G,k,1);
    for i=1:size(path,2)
        if i==1
           al_bat = al_bat+(EM+ET*G.Edges.Weight(findedge(G,path(i+1),path(i)))) ;
        elseif i==size(path,2)
           al_bat = al_bat+(EM+ER*G.Edges.Weight(findedge(G,path(i-1),path(i)))) ; 
        else
           al_bat = al_bat+(EM+ER*G.Edges.Weight(findedge(G,path(i-1),path(i)))+ET*G.Edges.Weight(findedge(G,path(i+1),path(i)))) ; 
        end
    end
end
result = sum(sum(bat))/(al_bat);