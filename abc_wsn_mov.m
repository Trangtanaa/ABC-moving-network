clear;
clc;
close all;
%% loading full coverage network
load("full60it2.mat")
%% parameter setup
% network parameter
rc=10;
rs=10;
area=[100 100];
N = numel(pop)/2;
data_count=0;

%bat parameter
node_bat = 1000;
sink_bat = 2000;
bat= repmat(node_bat,[N 1]);
bat(1)=sink_bat;
E_ratio=[];

%moving parameter
life_min=0;
v=2;
data_packets=1;

% graph the network
G_init=Graph(pop,rc);
%% MAIN
%while 1
while all(bat(:,:)> node_bat*life_min) 
    %% recalculate the Graph to check if network moved
    G=Graph(pop,rc);
    %% erase energy exhausted nodes
    bat_ck=find(bat<=0);
    for k=1:numel(bat_ck)
        G=rmedge(G,findedge(G,bat_ck(k),neighbors(G,bat_ck(k))));
    end
    %% run network
    bat = run_network(G,bat);
    data_count = data_count +1;

    % fitness
    Full_connected = Connectivity_graph(G);
    E_ratio=[E_ratio; Life_Time(G,bat)];
    %% selection and move
    if Full_connected ~= 1 || any(bat(:,:) < 0.5*node_bat)
        pop = mov_network(pop,rc,v,area,bat);
    end
    disp(['Data_packets transfered ' num2str(data_packets)])
    data_packets=data_packets+1;
end
%% Plot
plot(G);
hold on;
figure;
plot(G_init);

