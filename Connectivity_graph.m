function check = Connectivity_graph(G)
numberNodes=numnodes(G);
v = dfsearch(G,1);
if (size(v,1)==numberNodes)
    check = 1;                  %connected
else
    check = 0;                  % not connected
end