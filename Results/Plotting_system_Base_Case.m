% Create a plot of the system with spot prices and flows on each line
%% Load data for system plot
nodes = [2 8 6 10 8 8 1 2 14 5 5 3;6 4 7 7 10 13 1 8 6 13 11 11]; % Coordinates for nodes
nl = [1 7; 1 8; 2 3; 2 4; 2 7; 3 4; 3 5; 3 8; 4 5; 4 9; 5 6]; % Nodes connected to AC lines 
nh = [1 3; 3 8; 5 6; 5 11; 6 8; 6 10; 8 12; 10 11; 10 12; 11 12];  % Nodes connected to DC lines

ACflow_tab = readtable('ACflows.csv');
ACflow = table2array(ACflow_tab); % AC flows
L = size(nl,1); % number of AC lines

fdc_tab = readtable('DCflows.csv');
fdc = table2array(fdc_tab); % DC flows
H = size(nh,1); % number of DC lines

NP_tab = readtable('Nprices.csv'); % Prices in nodes
NP = table2array(NP_tab);

RAM_tab = readtable('RAM.csv');
RAM = table2array(RAM_tab); % RAM values

NTC_tab = readtable('NTC.csv');
NTC = table2array(NTC_tab); % NTC values in matrix

pmax = max([nodes(1,:),nodes(2,:)])+1; % Axis limit

AC_color = 'blue';
DC_color = 'green';
con_color = 'red'; % Congestion color

%% Plot system with flows, prices and congestions
mhs = 0.9; % Max head size of arrows

figure
% AC lines 
% Plotting lines and arrows
for l = 1:L % For every AC line
    snl = nl(l,1); % start node for line
    enl = nl(l,2); % end node for line

    hold on
    plot(nodes(1,[snl,enl]), nodes(2,[snl,enl]),AC_color)
    if ACflow(l) > 0 % it seems like this flow which is PTDF*pFB has the same sign as f_l, 
        % therefore I assume that the flow direction can be defined in the
        % same way as for f_l (positive = flow from node with lowest number
        % to node with highest number) 
        st = snl; % Start of flow
        en = enl; % End of flow
    else
        st = enl; % Start of flow
        en = snl;  % End of flow
    end
    quiver(nodes(1,st),nodes(2,st),(nodes(1,en)-nodes(1,st))/2,(nodes(2,en)-nodes(2,st))/2,0,'Color',AC_color,'MaxHeadSize',mhs)
end

hold on

% Adding flow value as text - they will be colored red, if there is congestion
% AC line 1
if abs(ACflow(1)) > RAM(1)*0.99
    text(mean([nodes(1,1),nodes(1,7)]), mean([nodes(2,1),nodes(2,7)]),string(round(abs(ACflow(1)))),'Color', con_color,'HorizontalAlignment','right',VerticalAlignment='bottom') % Line 1
else 
    text(mean([nodes(1,1),nodes(1,7)]), mean([nodes(2,1),nodes(2,7)]),string(round(abs(ACflow(1)))),'Color', AC_color,'HorizontalAlignment','right',VerticalAlignment='bottom') % Line 1
end
% AC line 2
if abs(ACflow(2)) > RAM(2)*0.99
    text(mean([nodes(1,1),nodes(1,8)]), mean([nodes(2,1),nodes(2,8)]),string(round(abs(ACflow(2)))),'Color',con_color,'HorizontalAlignment','right') % Line 2
else
    text(mean([nodes(1,1),nodes(1,8)]), mean([nodes(2,1),nodes(2,8)]),string(round(abs(ACflow(2)))),'Color',AC_color,'HorizontalAlignment','right') % Line 2
end
% AC line 3
if abs(ACflow(3)) > RAM(3)*0.99
        text(mean([nodes(1,2),nodes(1,3)]), mean([nodes(2,2),nodes(2,3)]),string(round(abs(ACflow(3)))),'Color',con_color,'HorizontalAlignment','right',VerticalAlignment='top') % Line 3
else
    text(mean([nodes(1,2),nodes(1,3)]), mean([nodes(2,2),nodes(2,3)]),string(round(abs(ACflow(3)))),'Color',AC_color,'HorizontalAlignment','right',VerticalAlignment='top') % Line 3
end
% AC line 4
if abs(ACflow(4)) > RAM(4)*0.99
    text(mean([nodes(1,2),nodes(1,4)]), mean([nodes(2,2),nodes(2,4)]),string(round(abs(ACflow(4)))),'Color',con_color,'HorizontalAlignment','left',VerticalAlignment='top') % Line 4
else
    text(mean([nodes(1,2),nodes(1,4)]), mean([nodes(2,2),nodes(2,4)]),string(round(abs(ACflow(4)))),'Color',AC_color,'HorizontalAlignment','left',VerticalAlignment='top') % Line 4
end
% AC line 5
if abs(ACflow(5)) > RAM(5)*0.99
    text(mean([nodes(1,2),nodes(1,7)]), mean([nodes(2,2),nodes(2,7)]),string(round(abs(ACflow(5)))),'Color',con_color,'HorizontalAlignment','left',VerticalAlignment='top') % Line 5
else
    text(mean([nodes(1,2),nodes(1,7)]), mean([nodes(2,2),nodes(2,7)]),string(round(abs(ACflow(5)))),'Color',AC_color,'HorizontalAlignment','left',VerticalAlignment='top') % Line 5
end
% AC line 6
if abs(ACflow(6)) > RAM(6)*0.99
    text(mean([nodes(1,3),nodes(1,4)]), mean([nodes(2,3),nodes(2,4)]),string(round(abs(ACflow(6)))),'Color',con_color,VerticalAlignment='top') % Line 6
else
    text(mean([nodes(1,3),nodes(1,4)]), mean([nodes(2,3),nodes(2,4)]),string(round(abs(ACflow(6)))),'Color',AC_color,VerticalAlignment='top') % Line 6
end
% AC line 7
if abs(ACflow(7)) > RAM(7)*0.99
    text(mean([nodes(1,3),nodes(1,5)]), mean([nodes(2,3),nodes(2,5)]),string(round(abs(ACflow(7)))),'Color',con_color,'HorizontalAlignment','left',VerticalAlignment='top') % Line 7
else
    text(mean([nodes(1,3),nodes(1,5)]), mean([nodes(2,3),nodes(2,5)]),string(round(abs(ACflow(7)))),'Color',AC_color,'HorizontalAlignment','left',VerticalAlignment='top') % Line 7
end
% AC line 8
if abs(ACflow(8)) > RAM(8)*0.99
    text(mean([nodes(1,3),nodes(1,8)]), mean([nodes(2,3),nodes(2,8)]),string(round(abs(ACflow(8)))),'Color',con_color,'HorizontalAlignment','right',VerticalAlignment='top') % Line 8
else
    text(mean([nodes(1,3),nodes(1,8)]), mean([nodes(2,3),nodes(2,8)]),string(round(abs(ACflow(8)))),'Color',AC_color,'HorizontalAlignment','right',VerticalAlignment='top') % Line 8
end
% AC line 9
if abs(ACflow(9)) > RAM(9)*0.99
    text(mean([nodes(1,4),nodes(1,5)]), mean([nodes(2,4),nodes(2,5)]),string(round(abs(ACflow(9)))),'Color',con_color,'HorizontalAlignment','left',VerticalAlignment='bottom') % Line 9
else
    text(mean([nodes(1,4),nodes(1,5)]), mean([nodes(2,4),nodes(2,5)]),string(round(abs(ACflow(9)))),'Color',AC_color,'HorizontalAlignment','left',VerticalAlignment='bottom') % Line 9
end
% AC line 10
if abs(ACflow(10)) > RAM(10)*0.99
    text(mean([nodes(1,4),nodes(1,9)]), mean([nodes(2,4),nodes(2,9)]),string(round(abs(ACflow(10)))),'Color',con_color,'HorizontalAlignment','left',VerticalAlignment='bottom') % Line 10
else
    text(mean([nodes(1,4),nodes(1,9)]), mean([nodes(2,4),nodes(2,9)]),string(round(abs(ACflow(10)))),'Color',AC_color,'HorizontalAlignment','left',VerticalAlignment='bottom') % Line 10
end 
% AC line 11
if abs(ACflow(11)) > RAM(11)*0.99
    text(mean([nodes(1,5),nodes(1,6)]), mean([nodes(2,5),nodes(2,6)]),string(round(abs(ACflow(11)))),'Color',con_color,'HorizontalAlignment','right',VerticalAlignment='top') % Line 11
else
    text(mean([nodes(1,5),nodes(1,6)]), mean([nodes(2,5),nodes(2,6)]),string(round(abs(ACflow(11)))),'Color',AC_color,'HorizontalAlignment','right',VerticalAlignment='top') % Line 11
end


% DC lines
% Plotting lines and arrows
for h = [1 4 5 6 7 8 9 10] % For every DC line, except line 2 and 3
    snh = nh(h,1);% start node for line
    enh = nh(h,2);% end node for line

    hold on
    plot(nodes(1,[snh,enh]), nodes(2,[snh,enh]),DC_color)
    if fdc(h) > 0
        st = snh; % Start of flow
        en = enh; % End of flow
    else
        st = enh; % Start of flow
        en = snh;  % End of flow
    end
    quiver(nodes(1,st),nodes(2,st),(nodes(1,en)-nodes(1,st))/2,(nodes(2,en)-nodes(2,st))/2,0,'Color',DC_color,'MaxHeadSize',mhs)
end

% Plot line 2 and 3, including arrows
plot([nodes(1,[3]),mean([nodes(1,[3]),nodes(1,[8])])+1,mean([nodes(1,[3]),nodes(1,[8])]),nodes(1,[8])], [nodes(2,[3]),mean([nodes(2,[8]),nodes(2,[3])]),mean([nodes(2,[8]),nodes(2,[3])])+0.25,nodes(2,[8])],'Color', DC_color) % DC line 2
if fdc(2) > 0
    stx = mean([nodes(1,[3]),nodes(1,[8])])+1
    enx = mean([nodes(1,[3]),nodes(1,[8])])
    sty = mean([nodes(2,[8]),nodes(2,[3])])
    eny = mean([nodes(2,[8]),nodes(2,[3])])+0.25
else
    stx = mean([nodes(1,[3]),nodes(1,[8])])
    enx = mean([nodes(1,[3]),nodes(1,[8])])+1
    sty = mean([nodes(2,[8]),nodes(2,[3])])+0.25
    eny = mean([nodes(2,[8]),nodes(2,[3])])
end
quiver(stx,sty,(enx-stx)/2,(eny-sty)/2,0,'Color',DC_color,'MaxHeadSize',mhs)

plot([nodes(1,[5]),nodes(1,[5])+0.2,nodes(1,[5])+0.2,nodes(1,[6])], [nodes(2,[5]),mean([nodes(2,[6]),nodes(2,[5])])-0.5 ,mean([nodes(2,[6]),nodes(2,[5])])+0.5, nodes(2,[6])],'Color', DC_color) % DC line 3
if fdc(3) > 0 
    xx = nodes(1,[5])+0.2
    sty = mean([nodes(2,[6]),nodes(2,[5])])-0.5
    eny = mean([nodes(2,[6]),nodes(2,[5])])+0.5
else
    xx = nodes(1,[5])+0.2
    sty = mean([nodes(2,[6]),nodes(2,[5])])+0.5
    eny = mean([nodes(2,[6]),nodes(2,[5])])-0.5
end
quiver(xx,sty,(xx-xx)/2,(eny-sty)/2,0,'Color',DC_color,'MaxHeadSize',mhs)

% Adding flow values as text, they will be red, if there is congestion
% DC line 1
if fdc(1) > 0 & fdc(1) > 0.99*NTC(3,1) | fdc(1) < 0 & abs(fdc(1)) > 0.99*NTC(1,3)
    text(mean([nodes(1,1),nodes(1,3)]), mean([nodes(2,1),nodes(2,3)]),string(round(abs(fdc(1)))),'Color',con_color,'HorizontalAlignment','left',VerticalAlignment='top')
else
    text(mean([nodes(1,1),nodes(1,3)]), mean([nodes(2,1),nodes(2,3)]),string(round(abs(fdc(1)))),'Color',DC_color,'HorizontalAlignment','left',VerticalAlignment='top')
end
% DC line 2
if fdc(2) > 0 & fdc(2) > 0.99*NTC(8,3) | fdc(2) < 0 & abs(fdc(2)) > 0.99*NTC(3,8)
    text(mean([nodes(1,[3]),nodes(1,[8])]), mean([nodes(2,[8]),nodes(2,[3])])+0.25,string(round(abs(fdc(2)))),'Color',con_color,'HorizontalAlignment','left',VerticalAlignment='bottom')
else
    text(mean([nodes(1,[3]),nodes(1,[8])]), mean([nodes(2,[8]),nodes(2,[3])])+0.25,string(round(abs(fdc(2)))),'Color',DC_color,'HorizontalAlignment','left',VerticalAlignment='bottom')
end
% DC line 3
if fdc(3) > 0 & fdc(3) > 0.99*NTC(6,5) | fdc(3) < 0 & abs(fdc(3)) > 0.99*NTC(5,6)
    text(nodes(1,[5])+0.2, mean([nodes(2,[6]),nodes(2,[5])]),string(round(abs(fdc(3)))),'Color',con_color,'HorizontalAlignment','left',VerticalAlignment='middle')
else
    text(nodes(1,[5])+0.2, mean([nodes(2,[6]),nodes(2,[5])]),string(round(abs(fdc(3)))),'Color',DC_color,'HorizontalAlignment','left',VerticalAlignment='middle')
end
% DC line 4
if fdc(4) > 0 & fdc(4) > 0.99*NTC(11,5) | fdc(4) < 0 & abs(fdc(4)) > 0.99*NTC(5,11)
    text(mean([nodes(1,5),nodes(1,11)]), mean([nodes(2,5),nodes(2,11)]),string(round(abs(fdc(4)))),'Color',con_color,'HorizontalAlignment','center',VerticalAlignment='top')
else
    text(mean([nodes(1,5),nodes(1,11)]), mean([nodes(2,5),nodes(2,11)]),string(round(abs(fdc(4)))),'Color',DC_color,'HorizontalAlignment','center',VerticalAlignment='top')
end
% DC line 5
if fdc(5) > 0 & fdc(5) > 0.99*NTC(8,6) | fdc(5) < 0 & abs(fdc(5)) > 0.99*NTC(6,8)
    text(0.9*mean([nodes(1,6),nodes(1,8)]), 0.9*mean([nodes(2,6),nodes(2,8)]),string(round(abs(fdc(5)))),'Color',con_color,'HorizontalAlignment','center',VerticalAlignment='middle')
else
    text(0.9*mean([nodes(1,6),nodes(1,8)]), 0.9*mean([nodes(2,6),nodes(2,8)]),string(round(abs(fdc(5)))),'Color',DC_color,'HorizontalAlignment','center',VerticalAlignment='middle')
end
% DC line 6
if fdc(6) > 0 & fdc(6) > 0.99*NTC(10,6) | fdc(6) < 0 & abs(fdc(6)) > 0.99*NTC(6,10)
    text(mean([nodes(1,6),nodes(1,10)]), mean([nodes(2,6),nodes(2,10)]),string(round(abs(fdc(6)))),'Color',con_color,'HorizontalAlignment','center',VerticalAlignment='bottom')
else
    text(mean([nodes(1,6),nodes(1,10)]), mean([nodes(2,6),nodes(2,10)]),string(round(abs(fdc(6)))),'Color',DC_color,'HorizontalAlignment','center',VerticalAlignment='bottom')
end
% DC line 7
if fdc(7) > 0 & fdc(7) > 0.99*NTC(12,8) | fdc(7) < 0 & abs(fdc(7)) > 0.99*NTC(8,12)
    text(mean([nodes(1,8),nodes(1,12)]), mean([nodes(2,8),nodes(2,12)]),string(round(abs(fdc(7)))),'Color',con_color,'HorizontalAlignment','right',VerticalAlignment='bottom')
else
    text(mean([nodes(1,8),nodes(1,12)]), mean([nodes(2,8),nodes(2,12)]),string(round(abs(fdc(7)))),'Color',DC_color,'HorizontalAlignment','right',VerticalAlignment='bottom')
end
% DC line 8
if fdc(8) > 0 & fdc(8) > 0.99*NTC(11,10) | fdc(8) < 0 & abs(fdc(8)) > 0.99*NTC(10,11)
    text(mean([nodes(1,10),nodes(1,11)]), mean([nodes(2,10),nodes(2,11)]),string(round(abs(fdc(8)))),'Color',con_color,'HorizontalAlignment','left',VerticalAlignment='bottom')
else
    text(mean([nodes(1,10),nodes(1,11)]), mean([nodes(2,10),nodes(2,11)]),string(round(abs(fdc(8)))),'Color',DC_color,'HorizontalAlignment','left',VerticalAlignment='bottom')
end
% DC line 9
if fdc(9) > 0 & fdc(9) > 0.99*NTC(12,10) | fdc(9) < 0 & abs(fdc(9)) > 0.99*NTC(10,12)
    text(mean([nodes(1,10),nodes(1,12)]), mean([nodes(2,10),nodes(2,12)]),string(round(abs(fdc(9)))),'Color',con_color,'HorizontalAlignment','right',VerticalAlignment='bottom')
else
    text(mean([nodes(1,10),nodes(1,12)]), mean([nodes(2,10),nodes(2,12)]),string(round(abs(fdc(9)))),'Color',DC_color,'HorizontalAlignment','right',VerticalAlignment='bottom') 
end
% DC line 10
if fdc(10) > 0 & fdc(10) > 0.99*NTC(12,11) | fdc(10) < 0 & abs(fdc(10)) > 0.99*NTC(11,12)
    text(mean([nodes(1,11),nodes(1,12)]), mean([nodes(2,11),nodes(2,12)]),string(round(abs(fdc(10)))),'Color',con_color,'HorizontalAlignment','center',VerticalAlignment='top')
else
    text(mean([nodes(1,11),nodes(1,12)]), mean([nodes(2,11),nodes(2,12)]),string(round(abs(fdc(10)))),'Color',DC_color,'HorizontalAlignment','center',VerticalAlignment='top')
end

% Nodes
hold on 
plot(nodes(1,:),nodes(2,:), 'r.', 'MarkerSize',10)
% Node prices
text([nodes(1,1),nodes(1,6:8),nodes(1,10:12)],[nodes(2,1),nodes(2,6:8),nodes(2,10:12)],{string(round(NP(1),2)),string(round(NP(6),2)),string(round(NP(7),2)),string(round(NP(8),2)),string(round(NP(10),2)),string(round(NP(11),2)),string(round(NP(12),2))},'VerticalAlignment','bottom','HorizontalAlignment' ,'right')
text(nodes(1,2:3),nodes(2,2:3),{string(round(NP(2),2)),string(round(NP(3),2))},'VerticalAlignment','top','HorizontalAlignment' ,'center')
text([nodes(1,4),nodes(1,9)],[nodes(2,4),nodes(2,9)],{string(round(NP(4),2)),string(round(NP(9),2))},'VerticalAlignment','bottom','HorizontalAlignment' ,'left')
text(nodes(1,5),nodes(2,5),{string(round(NP(5),2))},'VerticalAlignment','top','HorizontalAlignment' ,'center')

xlim([0,pmax])
ylim([0,pmax])

hold off
