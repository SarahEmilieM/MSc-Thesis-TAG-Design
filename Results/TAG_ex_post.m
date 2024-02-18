%TAG calculation used for ex-post price sensitivity analysis
%In this code, the ex-post price is manually inserted in the code section
% on TAG version 2 (code lines 165-192)
%% Loading data
NP = readtable('Nprices.csv').Node_Price; % Nodal prices
ZP = readtable('Zprices.csv').Zonal_Price; % Zonal prices

OffGA = readtable('OffGA.csv').Offshore_generation_available; % Generation avaiable for the 3 offshore WFs
OffCurt = readtable('OffCurt.csv').Offshore_curtailment; % Curtailment of the 3 offshore WFs

DC_cap = table2array(readtable('NTC_OBN.csv')); % DC line capacity
AC_cap = readtable('RAM_all.csv').Var2(18:28); % AC line capacity

NTC = table2array(readtable('NTC.csv')); % DC line capacity given to the market
RAM = readtable('RAM.csv').RAM; % AC line capacity given to the market

fac = table2array(readtable('ACflows.csv')); % AC flows
fdc = table2array(readtable('DCflows.csv')); % DC flows

%% Pre-calculations
% Capacity reduction in MW
DC_red_MW = abs(DC_cap - NTC);
AC_red_MW = abs(AC_cap - RAM);

% Capacity reduction in fraction
DC_red_frac = abs(DC_cap - NTC)./DC_cap;
DC_red_frac(isnan(DC_red_frac)) = 0;
AC_red_frac = abs(AC_cap - RAM)./AC_cap;

%% TAG version 1
% Compensation prices; price in connected onshore EEZ - price OBZ
CP_NS1_1 = max(NP(6) - NP(10),0); % In N10, connected to DK1 = N6
CP_NS2_1 = max(NP(5) - NP(11),0); % In N11, connected to DE = N5 (and more)
CP_NS3_1 = max(NP(8) - NP(12),0); % In N12, connected to NL = N8

% Compensation amount; total generation available is compensated
Comp_euro_NS1_1 = OffGA(1)*CP_NS1_1;
Comp_euro_NS2_1 = OffGA(2)*CP_NS2_1;
Comp_euro_NS3_1 = OffGA(3)*CP_NS3_1;

% Vectors containing compensations by TSOs to each WF - these will be zero,
% unless something else is stated
Comp_TSO_NS1_1 = zeros(1,9);
Comp_TSO_NS2_1 = zeros(1,9);
Comp_TSO_NS3_1 = zeros(1,9);

% Compensation paid by TSOs
Comp_TSO_NS1_1(3) = Comp_euro_NS1_1; % All compensation for NS1 is paid by the DK1 TSO
Comp_TSO_NS2_1(2) = Comp_euro_NS2_1; % All compensation for NS2 is paid by the DE TSO
Comp_TSO_NS3_1(5) = Comp_euro_NS3_1; % All compensation for NS3 is paid by the NL TSO

% The TSOs pay no compensation to the WFs that are not in their EEZ is zero

%% TSO responsibilities for TAG version 2

% TSOs responsible for curtailments in each OBZ
Resp_TSO_NS1_2 = zeros(9,1);
Resp_TSO_NS2_2 = zeros(9,1);
Resp_TSO_NS3_2 = zeros(9,1);

% If there are capacity reductions and congestions on lines to NS, the
% related TSO is responsible for some of the curtailment of WFs - if there
% is any
Red_rel_2 = zeros(9,1); % Vector containing relevant reductions
% Germany - special case
if fdc(4) <= -NTC(5,11)*0.99 % If there are congestions on DC line 4
    % If there are capacity reductions and congestions on any of the internal German lines or capacity reductions on DC line 4
    if DC_red_frac(5,11) > 0 || abs(fac(3)) >= RAM(3)*0.99 & AC_red_frac(3) > 0 || abs(fac(4)) >= RAM(4)*0.99 & AC_red_frac(4) > 0 || abs(fac(6)) >= RAM(6)*0.99 & AC_red_frac(6) > 0 || abs(fac(7)) >= RAM(7)*0.99 & AC_red_frac(7) > 0 || abs(fac(9)) >= RAM(9)*0.99 & AC_red_frac(9) > 0
        % The relevant reduction is the total of all German reductions in
        % MW
        DE_Red_rel_2 = []; % Vector containing the relevant line reductions in Germany
        if DC_red_frac(5,11) > 0
            DE_Red_rel_2 = [DE_Red_rel_2, DC_red_MW(5,11)];
        end
        if abs(fac(3)) >= RAM(3)*0.99 & RAM(3) < AC_cap(3)
            DE_Red_rel_2 = [DE_Red_rel_2, AC_red_MW(3)];
        end
        if abs(fac(4)) >= RAM(4)*0.99 & RAM(4) < AC_cap(4)
            DE_Red_rel_2 = [DE_Red_rel_2, AC_red_MW(4)];
        end
        if abs(fac(6)) >= RAM(6)*0.99 & RAM(6) < AC_cap(6)
            DE_Red_rel_2 = [DE_Red_rel_2, AC_red_MW(6)];
        end
        if abs(fac(7)) >= RAM(7)*0.99 & RAM(7) < AC_cap(7)
            DE_Red_rel_2 = [DE_Red_rel_2, AC_red_MW(7)];
        end
        if abs(fac(9)) >= RAM(9)*0.99 & RAM(9) < AC_cap(9)
            DE_Red_rel_2 = [DE_Red_rel_2, AC_red_MW(9)];
        end
        Red_rel_2(2) = sum(DE_Red_rel_2);
    end
end
if DC_red_frac(6,10) > 0 & fdc(6) <= -NTC(6,10)*0.99 % If there is a capacity reduction on DC line 6 and a congestion in the direction of Denmark
    Red_rel_2(3) = DC_red_MW(6,10); % The Danish TSO is responsible for some of the congestions in NS, and we need to know what the capacity reduction is on the line to the NS
end
if DC_red_frac(8,12) > 0 & fdc(7) <= -NTC(8,12)*0.99
    % If there is a capacity reduction on DC line 7 and a congestion in the direction of Netherlands
    Red_rel_2(5) = DC_red_MW(8,12); % The Dutch TSO is responsible for some of the congestions in NS, and we need to know what the capacity reduction is on the line to the NS
end

% Responsibilities calculated based on fraction of total capacity reduction
if NP(10) == NP(11) & NP(10) == NP(12)
    % Germany responsibility
    Resp_TSO_NS1_2(2) = Red_rel_2(2)/sum(Red_rel_2);
    Resp_TSO_NS2_2(2) = Red_rel_2(2)/sum(Red_rel_2);
    Resp_TSO_NS3_2(2) = Red_rel_2(2)/sum(Red_rel_2);
    % Denmark responsibility
    Resp_TSO_NS1_2(3) = Red_rel_2(3)/sum(Red_rel_2);
    Resp_TSO_NS2_2(3) = Red_rel_2(3)/sum(Red_rel_2);
    Resp_TSO_NS3_2(3) = Red_rel_2(3)/sum(Red_rel_2);
    % Netherlands responsibility
    Resp_TSO_NS1_2(5) = Red_rel_2(5)/sum(Red_rel_2);
    Resp_TSO_NS2_2(5) = Red_rel_2(5)/sum(Red_rel_2);
    Resp_TSO_NS3_2(5) = Red_rel_2(5)/sum(Red_rel_2);
elseif NP(10) == NP(11)
    disp("a")
    % Germany responsibility
    Resp_TSO_NS1_2(2) = Red_rel_2(2)/sum(Red_rel_2(2:3));
    Resp_TSO_NS2_2(2) = Red_rel_2(2)/sum(Red_rel_2(2:3));
    % Denmark responsibility
    Resp_TSO_NS1_2(3) = Red_rel_2(3)/sum(Red_rel_2(2:3));
    Resp_TSO_NS2_2(3) = Red_rel_2(3)/sum(Red_rel_2(2:3));
    % Netherlands responsibility
    Resp_TSO_NS3_2(5) = Red_rel_2(5)/Red_rel_2(5);
elseif NP(10) == NP(12)
    % Germany responsibility
    Resp_TSO_NS2_2(2) = Red_rel_2(2)/Red_rel_2(2);
    % Denmark responsibility
    Resp_TSO_NS1_2(3) = Red_rel_2(3)/(Red_rel_2(3)+Red_rel_2(5));
    Resp_TSO_NS3_2(3) = Red_rel_2(3)/(Red_rel_2(3)+Red_rel_2(5));
    % Netherlands responsibility
    Resp_TSO_NS1_2(5) = Red_rel_2(5)/(Red_rel_2(3)+Red_rel_2(5));
    Resp_TSO_NS3_2(5) = Red_rel_2(5)/(Red_rel_2(3)+Red_rel_2(5));
elseif NP(11) == NP(12)
    % Germany responsibility
    Resp_TSO_NS2_2(2) = Red_rel_2(2)/(Red_rel_2(2)+Red_rel_2(5));
    Resp_TSO_NS3_2(2) = Red_rel_2(2)/(Red_rel_2(2)+Red_rel_2(5));
    % Denmark responsibility
    Resp_TSO_NS1_2(3) = Red_rel_3(3)/Red_rel_3(3);
    % Netherlands responsibility
    Resp_TSO_NS2_2(5) = Red_rel_2(5)/(Red_rel_2(2)+Red_rel_2(5));
    Resp_TSO_NS3_2(5) = Red_rel_2(5)/(Red_rel_2(2)+Red_rel_2(5));
else
    % Germany responsibility
    Resp_TSO_NS2_2(2) = Red_rel_2(2)/Red_rel_2(2);
    % Denmark responsibility
    Resp_TSO_NS1_2(3) = Red_rel_2(3)/Red_rel_2(3);
    % Netherlands responsibility
    Resp_TSO_NS3_2(5) = Red_rel_2(5)/Red_rel_2(5);
end

% In case we have devided by zero and there are NaN elements, these will be
% converted to zero
Resp_TSO_NS1_2(isnan(Resp_TSO_NS1_2)) = 0;
Resp_TSO_NS2_2(isnan(Resp_TSO_NS2_2)) = 0;
Resp_TSO_NS3_2(isnan(Resp_TSO_NS3_2)) = 0;

% Resp_TSO_NS1_2(2) = 0.5;
% Resp_TSO_NS1_2(4) = 0.5;
% Resp_TSO_NS2_2(2) = 0.5;
% Resp_TSO_NS2_2(4) = 0.5;
% Resp_TSO_NS3_2(2) = 0.5;
% Resp_TSO_NS3_2(4) = 0.5;

%% TAG version 2
% For each WF, TAG will only be paid in case of curtailment
% If there are no capacity reductions on lines, there will be no TAG

% Vectors containing compensations by TSOs to each WF - these will be zero,
% unless something else is stated
Comp_TSO_NS1_2 = zeros(1,9);
Comp_TSO_NS2_2 = zeros(1,9);
Comp_TSO_NS3_2 = zeros(1,9);

% NS1
if OffCurt(1) > 0
    Comp_MW_NS1_2 = OffGA(1); % Compensated amount - total generation available
    Comp_TSO_NS1_2 = transpose(Comp_MW_NS1_2*Resp_TSO_NS1_2.*13.522); % TSO compensation payments
end 

% NS2
if OffCurt(2) > 0 
    Comp_MW_NS2_2 = OffGA(2); % Compensated amount - total generation available
    Comp_TSO_NS2_2 = transpose(Comp_MW_NS2_2*Resp_TSO_NS2_2.*13.522); % TSO compensation payments
end

% NS3
if OffCurt(3) > 0 
    Comp_MW_NS3_2 = OffGA(3); % Compensated amount - total generation available
    Comp_TSO_NS3_2 = transpose(Comp_MW_NS3_2*Resp_TSO_NS3_2.*13.522); % TSO compensation payments
end
    
%% TSO responsibilities for TAG version 3

% TSOs responsible for curtailments in each OBZ
Resp_TSO_NS1_3 = zeros(9,1);
Resp_TSO_NS2_3 = zeros(9,1);
Resp_TSO_NS3_3 = zeros(9,1);

% If there are more than 30% capacity reductions and congestions on lines to NS, the
% related TSO is responsible for some of the curtailment of WFs - if there
% is any
Red_rel_3 = zeros(9,1); % Vector containing relevant reductions
DE_Red_rel_3 = []; % Vector containing the relevant line reductions in Germany
% Germany - special case
if fdc(4) <= -NTC(5,11)*0.99 % If there are congestions on DC line 4
    % If there is more than 30% capacity reduction and congestion on any of
    % the internal German lines or capacity reductions on DC line 4
    if DC_red_frac(5,11) > 0.3 || abs(fac(3)) >= RAM(3)*0.99 & AC_red_frac(3) > 0.3 || abs(fac(4)) >= RAM(4)*0.99 & AC_red_frac(4) > 0.3 || abs(fac(6)) >= RAM(6)*0.99 & AC_red_frac(6) > 0.3 || abs(fac(7)) >= RAM(7)*0.99 & AC_red_frac(7) > 0.3 || abs(fac(9)) >= RAM(9)*0.99 & AC_red_frac(9) > 0.3
        % The relevant reduction is the average of all German reductions
        % (given as fractions)
        if DC_red_frac(5,11) > 0.3
            DE_Red_rel_3 = [DE_Red_rel_3, DC_red_MW(5,11)];
        end
        if abs(fac(3)) >= RAM(3)*0.99 & AC_red_frac(3) > 0.3
            DE_Red_rel_3 = [DE_Red_rel_3, AC_red_MW(3)];
        end
        if abs(fac(4)) >= RAM(4)*0.99 & AC_red_frac(4) > 0.3
            DE_Red_rel_3 = [DE_Red_rel_3, AC_red_MW(4)];
        end
        if abs(fac(6)) >= RAM(6)*0.99 & AC_red_frac(6) > 0.3
            DE_Red_rel_3 = [DE_Red_rel_3, AC_red_MW(6)];
        end
        if abs(fac(7)) >= RAM(7)*0.99 & AC_red_frac(7) > 0.3
            DE_Red_rel_3 = [DE_Red_rel_3, AC_red_MW(7)];
        end
        if abs(fac(9)) >= RAM(9)*0.99 & AC_red_frac(9) > 0.3
            DE_Red_rel_3 = [DE_Red_rel_3, AC_red_MW(9)];
        end
        Red_rel_3(2) = sum(DE_Red_rel_3);
    end
end
if DC_red_frac(6,10) > 0.3 & fdc(6) <= -NTC(6,10)*0.99 % If there is a capacity reduction on DC line 6 and a congestion in the direction of Denmark
    Red_rel_3(3) = DC_red_MW(6,10); % The Danish TSO is responsible for some of the congestions in NS, and we need to know what the capacity reduction is on the line to the NS
end
if DC_red_frac(8,12) > 0.3 & fdc(7) <= -NTC(8,12)*0.99 % If there is a capacity reduction on DC line 7 and a congestion in the direction of Netherlands
    Red_rel_3(5) = DC_red_MW(8,12); % The Dutch TSO is responsible for some of the congestions in NS, and we need to know what the capacity reduction is on the line to the NS
end

% Responsibilities calculated based on fraction of total capacity reduction
if NP(10) == NP(11) & NP(10) == NP(12)
    % Germany responsibility
    Resp_TSO_NS1_3(2) = Red_rel_3(2)/sum(Red_rel_3);
    Resp_TSO_NS2_3(2) = Red_rel_3(2)/sum(Red_rel_3);
    Resp_TSO_NS3_3(2) = Red_rel_3(2)/sum(Red_rel_3);
    % Denmark responsibility
    Resp_TSO_NS1_3(3) = Red_rel_3(3)/sum(Red_rel_3);
    Resp_TSO_NS2_3(3) = Red_rel_3(3)/sum(Red_rel_3);
    Resp_TSO_NS3_3(3) = Red_rel_3(3)/sum(Red_rel_3);
    % Netherlands responsibility
    Resp_TSO_NS1_3(5) = Red_rel_3(5)/sum(Red_rel_3);
    Resp_TSO_NS2_3(5) = Red_rel_3(5)/sum(Red_rel_3);
    Resp_TSO_NS3_3(5) = Red_rel_3(5)/sum(Red_rel_3);
elseif NP(10) == NP(11)
    % Germany responsibility
    Resp_TSO_NS1_3(2) = Red_rel_3(2)/sum(Red_rel_3(2:3));
    Resp_TSO_NS2_3(2) = Red_rel_3(2)/sum(Red_rel_3(2:3));
    % Denmark responsibility
    Resp_TSO_NS1_3(3) = Red_rel_3(3)/sum(Red_rel_3(2:3));
    Resp_TSO_NS2_3(3) = Red_rel_3(3)/sum(Red_rel_3(2:3));
    % Netherlands responsibility
    Resp_TSO_NS3_3(5) = Red_rel_3(5)/Red_rel_3(5);
elseif NP(10) == NP(12)
    % Germany responsibility
    Resp_TSO_NS2_3(2) = Red_rel_3(2)/Red_rel_3(2);
    % Denmark responsibility
    Resp_TSO_NS1_3(3) = Red_rel_3(3)/(Red_rel_3(3)+Red_rel_3(5));
    Resp_TSO_NS3_3(3) = Red_rel_3(3)/(Red_rel_3(3)+Red_rel_3(5));
    % Netherlands responsibility
    Resp_TSO_NS1_3(5) = Red_rel_3(5)/(Red_rel_3(3)+Red_rel_3(5));
    Resp_TSO_NS3_3(5) = Red_rel_3(5)/(Red_rel_3(3)+Red_rel_3(5));
elseif NP(11) == NP(12)
    % Germany responsibility
    Resp_TSO_NS2_3(2) = Red_rel_3(2)/(Red_rel_3(2)+Red_rel_3(5));
    Resp_TSO_NS3_3(2) = Red_rel_3(2)/(Red_rel_3(2)+Red_rel_3(5));
    % Denmark responsibility
    Resp_TSO_NS1_3(3) = Red_rel_3(3)/Red_rel_3(3);
    % Netherlands responsibility
    Resp_TSO_NS2_3(5) = Red_rel_3(5)/(Red_rel_3(2)+Red_rel_3(5));
    Resp_TSO_NS3_3(5) = Red_rel_3(5)/(Red_rel_3(2)+Red_rel_3(5));
else
    % Germany responsibility
    Resp_TSO_NS2_3(2) = Red_rel_3(2)/Red_rel_3(2);
    % Denmark responsibility
    Resp_TSO_NS1_3(3) = Red_rel_3(3)/Red_rel_3(3);
    % Netherlands responsibility
    Resp_TSO_NS3_3(5) = Red_rel_3(5)/Red_rel_3(5);
end

% In case we have devided by zero and there are NaN elements, these will be
% converted to zero
Resp_TSO_NS1_3(isnan(Resp_TSO_NS1_3)) = 0;
Resp_TSO_NS2_3(isnan(Resp_TSO_NS2_3)) = 0;
Resp_TSO_NS3_3(isnan(Resp_TSO_NS3_3)) = 0;


%% TAG version 3
% For each WF, TAG will only be paid in case of curtailment and if less
% than 70% of the CNE/interconnector capacity has been given to the market

% Vectors containing compensations by TSOs to each WF - these will be zero,
% unless something else is stated
Comp_TSO_NS1_3 = zeros(1,9);
Comp_TSO_NS2_3 = zeros(1,9);
Comp_TSO_NS3_3 = zeros(1,9);

% NS1
if OffCurt(1) > 0
    Comp_MW_NS1_3 = OffCurt(1); % Compensated amount - curtailed amount
    Comp_TSO_NS1_3 = transpose(Comp_MW_NS1_3*Resp_TSO_NS1_3.*13.522); % TSO compensation payments
end 

% NS2
if OffCurt(2) > 0 
    Comp_MW_NS2_3 = OffCurt(2); % Compensated amount - curtailed amount
    Comp_TSO_NS2_3 = transpose(Comp_MW_NS2_3*Resp_TSO_NS2_3.*13.522); % TSO compensation payments
end

% NS3
if OffCurt(3) > 0 
    Comp_MW_NS3_3 = OffCurt(3); % Compensated amount - curtailed amount
    Comp_TSO_NS3_3 = transpose(Comp_MW_NS3_3*Resp_TSO_NS3_3.*13.522); % TSO compensation payments
end
      
%% Displaying and saving results

% Display
disp("Compensation by DE, DK and NL for TAG version 1")
disp("Given to NS1:")
disp([Comp_TSO_NS1_1(2:3), Comp_TSO_NS1_1(5)])
disp("Given to NS2:")
disp([Comp_TSO_NS2_1(2:3), Comp_TSO_NS2_1(5)])
disp("Given to NS3:")
disp([Comp_TSO_NS3_1(2:3), Comp_TSO_NS3_1(5)])

disp("Compensation by DE, DK and NL for TAG version 2")
disp("Given to NS1:")
disp([Comp_TSO_NS1_2(2:3), Comp_TSO_NS1_2(5)])
disp("Given to NS2:")
disp([Comp_TSO_NS2_2(2:3), Comp_TSO_NS2_2(5)])
disp("Given to NS3:")
disp([Comp_TSO_NS3_2(2:3), Comp_TSO_NS3_2(5)])

disp("Compensation by DE, DK and NL for TAG version 3")
disp("Given to NS1:")
disp([Comp_TSO_NS1_3(2:3), Comp_TSO_NS1_3(5)])
disp("Given to NS2:")
disp([Comp_TSO_NS2_3(2:3), Comp_TSO_NS2_3(5)])
disp("Given to NS3:")
disp([Comp_TSO_NS3_3(2:3), Comp_TSO_NS3_3(5)])

% Save
% TAG version 1
% Creating matrix with compensation - WFs in rows and TSOs in columns
Results1 = [Comp_TSO_NS1_1;Comp_TSO_NS2_1;Comp_TSO_NS3_1];
% writematrix(Results1,"TAG_version1.csv")

% TAG version 2
% Creating matrix with compensation - WFs in rows and TSOs in columns
Results2 = [Comp_TSO_NS1_2;Comp_TSO_NS2_2;Comp_TSO_NS3_2];
% writematrix(Results2,"TAG_version2.csv")

% TAG version 3
% Creating matrix with compensation - WFs in rows and TSOs in columns
Results3 = [Comp_TSO_NS1_3;Comp_TSO_NS2_3;Comp_TSO_NS3_3];
% writematrix(Results3,"TAG_version3.csv")

%% Plot of results - from WF point of view
% Create matrix with only the compensations given by DE, DK and NL (the
% other ones are also zero)
Results1_WFs = Results1(:,[2:3,5]);
Results2_WFs = Results2(:,[2:3,5]);
Results3_WFs = Results3(:,[2:3,5]);

y1 = zeros(3,3,3); % Making a matrix for y-values for plot - the numbers stand for; 3 TAGs, 3 WFs, 3 TSOs
y1(1,:,:) = Results1_WFs;
y1(2,:,:) = Results2_WFs;
y1(3,:,:) = Results3_WFs;

groupLabels = {"TAG 1", "TAG 2", "TAG 3"};
plotBarStackGroups(y1, groupLabels);
% Set the colors
ax = gca; 
ax.ColorOrder = lines(3);
ax.Colormap = lines(3); % It should be possible to change this to another colormap

xTick = [0.78 1 1.22 1.78 2 2.22 2.78 3 3.22];
set(gca,'xtick',xTick);
yTick = get(gca,'ytick');
set(gca,'xticklabel',[])
xTickLabel = {{'NS1 \newline';' ';' '},{'NS2';' ';'TAG 1'},{'NS3';' ';' '},{'NS1';' ';' '},{'NS2';' ';'TAG 2'},{'NS3';' ';' '},{'NS1';' ';' '},{'NS2';' ';'TAG 3'},{'NS3';' ';' '}};
for k = 1:9
    text(xTick(k),-yTick(2)/10,xTickLabel{k},'HorizontalAlignment','center')
end

legend({'DE','DK','NL'})
title('TAG payments')
ylabel('Euro')
grid on

%% Data for following plot
% Congestion rent on lines
CR_AC = readtable('congestion_rent_AC.csv').Congestion_rent_AC;
CR_DC = readtable('congestion_rent_DC.csv').Congestion_rent_DC;

% Congestion rent to offshore for each TSO - OBS: If we are dealing with
% onshore congestions, we might want to compare to another number
CR_TSO = zeros(1,9);
CR_TSO(2) = CR_DC(4)+0.5*CR_AC(5); 
CR_TSO(3) = CR_DC(6);
CR_TSO(5) = CR_DC(7);
CR_TSO(4) = 0.5*CR_AC(5); % Specifically added for this case

% Total TAG for each TSO for each TAG design
Results1_TSOs = sum(Results1);
Results2_TSOs = sum(Results2);
Results3_TSOs = sum(Results3);

% The TAG payments' percentage of CR to offshore
TAG_of_CR_1 = (Results1_TSOs./CR_TSO).*100;
TAG_of_CR_2 = (Results2_TSOs./CR_TSO).*100;
TAG_of_CR_3 = (Results3_TSOs./CR_TSO).*100;

% Matrix with all results
y2 = [TAG_of_CR_1(:,1:6); TAG_of_CR_2(:,1:6); TAG_of_CR_3(:,1:6)];
y2(isnan(y2)) = 0; % Change NaNs to 0

%% Plot of results - from TSO point of view

figure
bar(y2, 'grouped')
%title('TAGs % of offshore congestion rent for TSO in given hour' )
title('TAGs % of CR on restricted line for TSO in given hour' )
ylim([0,max(y2, [], 'all')*1.1])
set(gca,'XTickLabel',{'TAG 1','TAG 2','TAG 3'})
legend({"BE" "DE" "DK" "FR" "NL" "PL"})


