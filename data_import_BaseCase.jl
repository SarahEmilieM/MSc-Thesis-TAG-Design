#Data import function with csv file containing all input data on generation, demand, the grid and OBZ structure

using CSV, DataFrames


function data_import(datapath)

    ##### Offshore wind farm data in 3 OBZs #####
    Gen_Off = CSV.read(string(datapath,"GenData_Off.csv"), DataFrame; delim=";")
    n_Zone = [1, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8, 9] #The zone of each node 


    #Read the generation data of the European countries witout back-pressure plants       
    Gen = CSV.read(string(datapath,"GenData_woBP_proj_2030.csv"), DataFrame; delim=";")
    #Read the data of the back-pressure plants    
    Gen_BP = CSV.read(string(datapath,"GenData_BP_proj_2030.csv"), DataFrame; delim=";")

    # Create a boolean mask for rows where the sixth column is equal to 1 and 0 to separate dispatable and non-dispatchable generation
    mask = Gen[:, "Dispatchable"] .== 1
    mask2 = Gen[:, "Dispatchable"] .== 0
    Dgen = Gen[mask, :] #The matrix of dispatchable generators
    Rgen = Gen[mask2, :] #The matrix of non-dispatable generators (renewables)


    Dem = CSV.read(string(datapath,"demand_proj_2030.csv"), DataFrame; delim=";") #Load demand data
    PTDF = CSV.read(string(datapath,"nPTDF.csv"), DataFrame; delim=",")[:,2:10] #Load the PTDF for EUR countries
    RAM = CSV.read(string(datapath,"RAM_all.csv"),header=false, DataFrame; delim=",")[18:28,2] #Load RAM for the EUR countries
    NTC = CSV.read(string(datapath,"NTC_OBN.csv"),header=false, DataFrame; delim=";") # NTC

    
    L = length(RAM) #Number of AC lines

    Qs = [Dgen[:,"Capacity"]; Gen_BP[:,"Electrical capacity"]] #capacity of generators in MW
    Node = [Dgen[:,"Node"]; Gen_BP[:,"Node"]] # Node number of generator
    G = length(Qs) # Number of generators, generator number also refers to node number
    ON = maximum(Node) # number of onshore nodes

    ## Create the Zone indices
    Zone = zeros(length(Node)) #initialize zone vector
    #Belgian node and zone number are both 1
    ind_BE = Node .== 1
    Zone[ind_BE] .= 1
    #All the german nodes (2 to 5) are zone 2
    ind_DE = (Node .== 2) .| (Node .== 3) .| (Node .== 4) .| (Node .== 5) #This finds indexes of all german nodes
    Zone[ind_DE] .= 2 #sets those equal to zone 2

    #For DK, FR, NL and PL they should have Zone number that is the node number minus 3
    ind_rest = (Node .>=6)
    Zone[ind_rest] .= Node[ind_rest].-3

    ##########################
    #Making the zonal PTDF
    n2 = Qs[findall(x-> x == 2, Node)] # Get capacities for fossil generators in node 2 (DE-S)
    n3 = Qs[findall(x-> x == 3, Node)] # Get capacities for fossil generators in node 3 (DE-W)
    n4 = Qs[findall(x-> x == 4, Node)] # Get capacities for fossil generators in node 4 (DE-E)
    n5 = Qs[findall(x-> x == 5, Node)] # Get capacities for fossil generators in node 5 (DE-N)
    tot = sum(n2)+sum(n3)+sum(n4)+sum(n5) # Sum of capacities
    gsk = zeros(maximum(Node),6) #Create GSK values using capacity weighted strategy 
    for i = 2:5
        gsk[i,2] = [sum(n2),sum(n3),sum(n4),sum(n5)][i-1]/tot
    end
    gsk[1,1], gsk[6,3], gsk[7,4], gsk[8, 5],  gsk[9,6] = 1,1,1,1,1 #The other nodes affecting a zone should just have GSK=1

    ZPTDF = zeros(L,6)
    for z= 1:6
        for l= 1:L
            ZPTDF[l,z] = sum(PTDF[l,n]*gsk[n,z] for n = 1:ON)
        end
    end 
    ####################


    G = length(Qs) # Number of generators, generator number also refers to node number
    Z = floor(Int,maximum(Zone)) #number of zones

    EU_ETS = 85 #carbon price in eur2023/ton https://tradingeconomics.com/commodity/carbon

    #Compute marginal costs of generators
    MC_Dgen = zeros(length(Qs),1) 
    for i in 1:length(Dgen[:,"Capacity"]) #calculate MC: total fuel cost[eur2012/MWh] / efficiency + variable O&M [eur2015/MWh]
        # Total fuel cost = fuel cost + CO2 Emissions*emission cost
        #Since variable O&M is in [eur2015/MWh] we *1.185 to convert to [eur2023/MWh]
        #Since fuel cost is given in [eur2012/GJ] we divide by 0.2777 to convert to [eur2012/MWh] and *1.028 to get [eur2023/MWh]
        #Since CO2 emission is given in kg/GJ we divide by 0.2777 to convert to kg/MWh and then /1000 to konvert to ton/MWh. 
        #Thus when multiplying with EU_ETS in eur/ton we have the unit of eur2023/MWh
        MC_Dgen[i,1] = (1/Dgen[i,"Efficiency"])*(Dgen[i,"Fuel cost [Eur2012/GJ]"]*1.028/0.2777 + (Dgen[i,"Emission CO2 kg/GJ"]/(0.2777*1000))*EU_ETS) + Dgen[i,"var O&M [Eur2015/MWh]"]*1.185
    end
    #Similarly for the Back-pressure units, we use the electrical efficiency, but otherwise the same
    for i in 1:length(Gen_BP[:,"EE"])
        MC_Dgen[length(Dgen[:,"Capacity"])+i,1] = (1/Gen_BP[i,"EE"])*(Gen_BP[i,"Fuel cost [Eur2012/GJ]"]*1.208/0.2777 + (Gen_BP[i,"Emission CO2 kg/GJ"]/(0.2777*1000))*EU_ETS) + Gen_BP[i,"var O&M [Eur2015/MWh]"]*1.185
    end

    
 ###### Renewable generation, both onshore and offshore #######

    Qr = [Rgen[:,"Capacity"]; Gen_Off[:,"Capacity"]] #Renewable generation, capacity in MW
    NR = [Rgen[:,"Node"];  Gen_Off[:,"Node"]] #Node of Renewable generation
    R = length(Qr) #Number of renewable plants
    N = maximum(NR) #Number of nodes in entire system

    ZR = zeros(length(NR)) #initialize zone vector
    #Belgian node and zone number are both 1
    in_BE = NR .== 1
    ZR[in_BE] .= 1
    #All the german nodes are zone 2
    in_DE = (NR .== 2) .| (NR .== 3) .| (NR .== 4) .| (NR .== 5)
    ZR[in_DE] .= 2
    
    #For DK, FR, NL, PL and OBN they should have Zone number that is the node number minus 3
    in_rest = (NR .>=6)
    ZR[in_rest] .= NR[in_rest].-3
    
    Sun_ind =findall(x-> x == "SUN", Rgen[:,"Fuel"]) #indices of solar PV
    Water_ind = findall(x-> x == "WATER", Rgen[:,"Fuel"]) #indices of hydro power
    On_wind_ind = findall(x-> x =="GNR_WT_WIND_ONS", Rgen[:, "Generator"]) #indices of onshore wind
    Off_wind_ind = findall(x-> x =="GNR_WT_WIND_OFF", Rgen[:, "Generator"]) #indices of offshore wind
    Hub_ind = [36,37,38] #indices of the offshore hubs


    Z = floor(Int,maximum(ZR)) #number of zones
    OnZ = floor(Int,maximum(Zone)) #number of onshore zones

    Qdz = Dem[:,"Hourly avg [MWh]"] #The average hourly demand at each node
 

    #The network matrix for NTC modelled lines
    Ih_initial = CSV.read(string(datapath,"I_hzz_off.csv"), DataFrame; delim=";")
    #The network matrix for FB modelled lines
    Il = CSV.read(string(datapath,"I_lz_2.csv"),header = false, DataFrame; delim=";")
    # Adding 3 extra columns of zeros, such that the zonal balance constraint works
    for i = 10:12
        colname = "Column$i"
        Il[!, colname] = zeros(11)
    end


    H = 10 #Number of DC lines between zones

    #Collact all the parameters in a dictionary
    data = Dict(
        "Qs" => Qs, "Node" => Node, "G" => G, "N" => N, "Qr"=> Qr, "NR"=> NR, "R"=> R, "PTDF" => PTDF, 
        "RAM_p" => RAM, "RAM_m" => RAM, "NTC" => NTC, "MC" =>MC_Dgen, "Qdz" => Qdz, "Ih_initial" => Ih_initial, "H" => H,
        "Il" => Il, "L" => L, "Dgen" => Dgen, "Zone" => Zone, "Z" => Z, "ZR" => ZR, "n_Zone" => n_Zone, "ON" => ON,
        "OnZ" => OnZ, "ZPTDF" => ZPTDF, "Sun_ind" => Sun_ind, "Water_ind" => Water_ind, "On_wind_ind" => On_wind_ind, 
        "Off_wind_ind" => Off_wind_ind, "Hub_ind" => Hub_ind
        )
    return(data)
end