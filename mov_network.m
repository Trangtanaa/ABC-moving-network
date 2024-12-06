function [Result,L] = mov_network(init_pop,rc,rs,v,area,bat,L)
%moving the network
%global trying to move network to improve both LT and CV
%local trying to move low bat nodes lower their energy consumption 
%% SETUP PARAMETER
N = numel(init_pop)/2 ; %Number of sensor nodes

LT_decrease=0.99;
LT_increase=1.005;
cov_decrease=0.994;
MaxIt = 1;
nPop=2;
Scout_bee=nPop/2;
Onlooker_bee=nPop/2;
bat_ex=find(bat<=0);

%% MAIN
for it=1:MaxIt
    G_initpop=Graph(init_pop,rc); % Graph chua loai node het NL
    G_alpop=G_initpop;        % Graph da loai cac node het NL
    for k=1:numel(bat_ex)
        G_alpop=rmedge(G_alpop,findedge(G_alpop,bat_ex(k),neighbors(G_alpop,bat_ex(k))));
    end 
    Connect_stat_1= Connectivity_graph(G_alpop,bat_ex);
    %% if network not connected
    if Connect_stat_1==0
       
        batchs = conncomp(G_alpop);
        degs   = degree(G_alpop);
        sink_batch=batchs(1);
        unconnected_nodes=[];
        % define unconnected nodes
        for i=2:N
            if batchs(i)~=sink_batch && degs(i)~=0
                unconnected_nodes=[unconnected_nodes i];
            end
        end


        
    %% if network still connected    
    else
    %% Global search to decrease network energy consumption
    for i=1:Scout_bee
        pop_cov  = Cov_Func(init_pop,rs,area);
        BFS=flip(bfsearch(G_alpop,1));
        for k=1: (numel(BFS)-1)
            j=BFS(k);
            alpop=init_pop;
            G_initpop=Graph(init_pop,rc);
            pop_cost=Life_Time(G_initpop,bat);
            while 1
                alpop(j*2)  = init_pop(j*2)   + v*(2*rand(1)-1);
                alpop(j*2-1)= init_pop(j*2-1) + v*(2*rand(1)-1);
                G_alpop=Graph(alpop,rc);
                for k=1:numel(bat_ex)
                    G_alpop=rmedge(G_alpop,findedge(G_alpop,bat_ex(k),neighbors(G_alpop,bat_ex(k))));
                end
                Connect_stat_global= Connectivity_graph(G_alpop,bat_ex);
                if Connect_stat_global == 1
                    alpop_cost = Life_Time(G_alpop,bat);
                    alpop_cov  = Cov_Func(alpop,rs,area);
                    if alpop_cost>=pop_cost && alpop_cost<=pop_cost*LT_increase && alpop_cov>=pop_cov*cov_decrease
                        init_pop=alpop;
                        L(j)=L(j)+1;
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
        %consumption or LOW BAT
        %G_initpop=Graph(init_pop,rc);
        E=E_consumption(G_initpop,bat);
        E_bat=bat(1)-bat;
        E_ave=reshape(E_bat/sum(E_bat),[1 N]);
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
            for k=1:numel(bat_ex)
                G_alpop=rmedge(G_alpop,findedge(G_alpop,bat_ex(k),neighbors(G_alpop,bat_ex(k))));
            end
            Connect_stat_local= Connectivity_graph(G_alpop,bat_ex);
            if Connect_stat_local == 1
                E_alpop=E_consumption(G_alpop,bat);
                if E_alpop(j)<E(j) && E_alpop(j)>E(j)*LT_decrease
                    init_pop=alpop;
                    L(j)=L(j)+1;
                end
                break;
            end
        end
    end
    end
    %disp(it);
end
Result=init_pop;
