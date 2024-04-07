function Result = mov_network(init_pop,rc,rs,v,area,bat)
%% SETUP PARAMETER
N = numel(init_pop)/2 ; %Number of sensor nodes


MaxIt = 1;
nPop=2;
Scout_bee=nPop/2;
Onlooker_bee=nPop/2;

%% MAIN
for it=1:MaxIt
    %% Global search to decrease network energy consumption
    for i=1:Scout_bee
        pop_cov  = Cov_Func(init_pop,rs,area);
        for j=2:N
            alpop=init_pop;
            G_initpop=Graph(init_pop,rc);
            pop_cost=Life_Time(G_initpop,bat);
            while 1
                alpop(j*2)  = init_pop(j*2)   + v*(2*rand(1)-1);
                alpop(j*2-1)= init_pop(j*2-1) + v*(2*rand(1)-1);
                G_alpop=Graph(alpop,rc);
                Connect_stat= Connectivity_graph(G_alpop);
                if Connect_stat == 1
                    alpop_cost = Life_Time(G_alpop,bat);
                    alpop_cov  = Cov_Func(alpop,rs,area);
                    if alpop_cost>pop_cost && alpop_cov>=pop_cov
                        init_pop=alpop;
                    end
                    break;
                end
            end
        end
    end
    %% Local search to decrease node energy consumption
    for i=1:Onlooker_bee
        alpop=init_pop;
        %randomly choose a node, prioritize node that have high energy
        %consumption
        G_initpop=Graph(init_pop,rc);
        E=E_consumption(G_initpop);
        E_ave=reshape(E/sum(E),[1 N]);
        while 1
            j=randsrc(1,1,[1:N;E_ave]);
            if j~=1
                break;
            end
        end
        while 1
            alpop(j*2)  = init_pop(j*2)   + v*(2*rand(1)-1);
            alpop(j*2-1)= init_pop(j*2-1) + v*(2*rand(1)-1);
            G_alpop=Graph(alpop,rc);
            Connect_stat= Connectivity_graph(G_alpop);
            if Connect_stat == 1
                E_pop=E_consumption(G_alpop);
                if E_pop(j)<E(j)
                    init_pop=alpop;
                end
                break;
            end
        end
    end
    %disp(it);
end
Result=init_pop;
