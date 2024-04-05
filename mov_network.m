function Result = mov_network(init_pop,rc,v,area,bat)
%% SETUP PARAMETER
N = numel(init_pop)/2 ; %Number of sensor nodes

VarMin = 0;         % Decision Variables Lower Bound
VarMaxx = area(1);  % Decision Variables Upper Bound
VarMaxy = area(2);

MaxIt = 1;
nPop=4;
Scout_bee=nPop/2;
Onlooker_bee=nPop/2;

%% Random Initialization and Waggle dance
%{
% Empty Bee Structure
empty_bee.Position = init_pop;
empty_bee.Cost = [];

% Initialize Population Array
pop = repmat(empty_bee, nPop/2, 1);
% init first pop
for i=1:nPop/2
    for j=2:N
        while 1
            pop(i).Position(j*2)  = init_pop(j*2)   + v*(2*rand(1)-1);
            pop(i).Position(j*2-1)= init_pop(j*2-1) + v*(2*rand(1)-1);
            if Connectivity(pop(i).Position,rc)==0
                break;
            end
        end
    end
end
%}
%% MAIN
for it=1:MaxIt
    %% Global search to decrease network energy consumption
    for i=1:Scout_bee
        for j=2:N
            pop=init_pop;
            G_pop=Graph(pop,rc);
            pop_cost=Life_Time(G_pop,bat);
            while 1
                pop(j*2)  = init_pop(j*2)   + v*(2*rand(1)-1);
                pop(j*2-1)= init_pop(j*2-1) + v*(2*rand(1)-1);
                G_pop=Graph(pop,rc);
                Connect_stat= Connectivity_graph(G_pop);
                if Connect_stat == 1
                    alpop_cost = Life_Time(G_pop,bat);
                    if alpop_cost>pop_cost
                        init_pop=pop;
                    end
                    break;
                end
            end
        end
    end
    %% Local search to decrease node energy consumption
    for i=1:Onlooker_bee
        pop=init_pop;
        %randomly choose a node, prioritize node that have high energy
        %consumption
        G=Graph(init_pop,rc);
        E=E_consumption(G);
        E_ave=reshape(E/sum(E),[1 N]);
        while 1
            j=randsrc(1,1,[1:N;E_ave]);
            if j~=1
                break;
            end
        end
        while 1
            pop(j*2)  = init_pop(j*2)   + v*(2*rand(1)-1);
            pop(j*2-1)= init_pop(j*2-1) + v*(2*rand(1)-1);
            G_pop=Graph(pop,rc);
            Connect_stat= Connectivity_graph(G_pop);
            if Connect_stat == 1
                E_pop=E_consumption(G_pop);
                if E_pop(j)<E(j)
                    init_pop=pop;
                end
                break;
            end
        end
    end
    disp(it);
end
Result=init_pop;
