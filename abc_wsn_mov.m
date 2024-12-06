clear;
clc;
close all;
figure;
%% loading full coverage network
load("full60it2.mat")

%% parameter setup
% network parameter
rc=10;
rs=10;
area=[100 100];
N = numel(pop)/2;
L=zeros(1,N);           % number of time a sensor move
data_count=1;           % number of successfully transfered packets
lost_count=1;           % number of lost packets

%battery parameter
node_bat = 1000;
sink_bat = 2000;
bat= repmat(node_bat,[N 1]);    % matrix of network nodes' battery
bat(1)=sink_bat;
E_ratio=[];                     % matrix of lifetime over iterations

%moving parameter
bat_min=0;                      % min percentage of battery
v=2;                            % max velocity of node

% graph network
G_init=Graph(pop,rc);
pop_init=pop;

%% MAIN
%while 1
while any(bat(:,:)> node_bat*bat_min) 
    %% recalculate the Graph to check if network moved
    G=Graph(pop,rc);

    %% erase energy exhausted nodes
    bat_ex=find(bat<=0);
    for k=1:numel(bat_ex)
        G=rmedge(G,findedge(G,bat_ex(k),neighbors(G,bat_ex(k))));
    end

    %% run network
    [bat,data_point,success] = run_network(G,pop,bat);
    if success==1
        disp(['Data packets transfered ' num2str(data_count)])
        data_count = data_count +1;
    else
        disp(['Lost packet at ' num2str(data_point) '  ,' num2str(lost_count) ' Data_packets lost'])
        lost_count = lost_count+1;
    end
    % fitness
    Full_connected = Connectivity_graph(G,bat_ex);
    E_ratio=[E_ratio; Life_Time(G,bat)];

    %% move network
    if Full_connected ~= 1 || any(bat(:,:) < 0.7*node_bat)
        [pop,L] = mov_network(pop,rc,rs,v,area,bat,L);
    end

    %% disp network
    G=Graph(pop,rc);
    %figure;
    %Cov=Cov_Func(pop,rs,area);
    clf();
    for i = 1:2:(numel(pop))
        plot (pop(1,i) , pop(1,i+1),'ro');
        hold on;
        text (pop(1,i) , pop(1,i+1), num2str(i/2+0.5),'FontSize',15);
        %hold on;
        %viscircles ([pop(1,i) pop(1,i+1)],rs,'Color', 'k');
    end
    
    for i = 1:1:numel(G.Edges.EndNodes)/2
        plot([pop(G.Edges.EndNodes(i,1)*2-1),pop(G.Edges.EndNodes(i,2)*2-1)],[pop(G.Edges.EndNodes(i,1)*2),pop(G.Edges.EndNodes(i,2)*2)],'Color','blue','linewidth',1);
    end
    
    plot(data_point(1),data_point(2),'ro','Color','g')

    xlim([0 100])
    ylim([0 100])
    %title(['Coverage Ratio: ', num2str(Cov*100),'%'])
    grid on;
    drawnow;
    %pause(0.01);

    % end 1 It
end
% End main It

%% Plot
figure;
plot(G);
hold on;
figure;
plot(G_init);

