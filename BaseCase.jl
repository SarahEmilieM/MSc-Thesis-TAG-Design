using JuMP
using Gurobi
using DataFrames
using CSV
using DelimitedFiles

# Insert your current working directory and the datapath to your folder with input data
# Create a folder for results, and insert the path for this folder in the file 'Saving_results_BaseCase.jl'
# From code line 75 you are instructed on how to change settings to recreate the scenarios

# cd("C://Users//sigri//Documents//DTU//Master thesis//Julia//Base Case")
# datapath = "C://Users//sigri//Documents//DTU//Master thesis//Julia//Base Case//"

cd("c://Users//sarah//OneDrive - Danmarks Tekniske Universitet//Msc Thesis//Thesis Model")
datapath = "c://Users//sarah//OneDrive - Danmarks Tekniske Universitet//Msc Thesis//Thesis Model//Data//"

include("data_import_BaseCase.jl")

data = data_import(datapath) # Importing data dictionary

### Sets and parameters ###
Z = data["Z"] # Number of of zones
N = data["N"] # Number of of nodes
OnN = data["ON"] # Number of onshore nodes
OnZ = data["OnZ"] # Number of onshore zones
ZN = data["n_Zone"] # The zone number of each node

# Demand
Qdz = data["Qdz"] # Demand in average hour for each zone [MWh]

# Dispatchable generators
G = data["G"] # Number of generators
MC = data["MC"] # Marginal cost of generators [Euro/MWh]
Qg = data["Qs"] # Capacity of generators [MW]
ZG = data["Zone"] # Zone number of dispatchable generators

# Renewable generation
R = data["R"] # Number of RES generators 
Qr = data["Qr"] # RES capacity
ZR = data["ZR"] # Zone of RES generation

# Indices of the different renewable type of plants, such that PF can differ between them
SUN = data["Sun_ind"] #Solar PV plant indices
WTR = data["Water_ind"] #Hydropower plant indices
On_W = data["On_wind_ind"] #Onshore wind balmorel indices
Off_W = data["Off_wind_ind"] #Offshore wind balmorel indices
Hub = data["Hub_ind"] #North Sea hub indices
PF = ones(R) # Initialization of Power factor of renwable energy

# AC lines
L = data["L"] # Number of AC lines
ZPTDF = data["ZPTDF"] # PTDF matrix
RAM = data["RAM_p"] # RAM of the AC lines

# Conventions about direction of flows on cross-zonal AC lines (rows) seen from the perspecive of the node in the column
Il = data["Il"]

# DC lines
H = data["H"] # Number of DC lines
NTC = data["NTC"] # DC NTC

# Conventions about direction of flows on cross-zonal DC lines (rows) seen from the perspecive of the node in the column, towards the node in the 3rd dimension.
Ih_initial = data["Ih_initial"]
array = Matrix(Ih_initial)
# We multiply with (-1) to get the correct values
Ih_2z = -reshape(array, H, 12, 12) # The 3 dimensional Ih
Ih_1z = dropdims(sum(Ih_2z, dims = 3), dims=3) # The 2 dimensional Ih

MC_r = zeros(length(ZR)) #Initialization of marginal costs of renewables





############## Scenario settings ################

# In this section you can change the parameters to replicate the scenarios of our Thesis.
# The parameters that can be changed are:
# Demand, Qdz
# Power Factor of renewables, PF
# RAM of AC lines, RAM
# NTC capacities of DC lines, NTC
# Marginal costs of renewables, MC

# Demand
Qdz = Qdz*(1.0) # Change average demand in all zones by percentage
#Qdz[2] = floor(Qdz[2]*1.15) #Adding consumption in DE
#Qdz[3] = floor(Qdz[3]*1.15) #Adding consumption in DK
#Qdz[5] = floor(Qdz[5]*1.15) #Adding consumption in NL

#Power factor, PF
PF[SUN] .= 0.1 #Change PF of solar PV
PF[WTR] .= 0.1 #Change PF of Hydropower
PF[On_W] .= 0.2 #Change PF of onshore wind turbines
PF[Off_W] .= 0.5 #Change PF of radially connected offshore wind turbines
PF[Hub] .= 0.8 #Change PF of the North Sea offshore wind farms



# The german interzonal lines are number: 3, 4, 6, 7 and 9. 
# RAM[3:4] = RAM[3:4]*0.2
# RAM[6:7] = RAM[6:7]*0.2
# RAM[6] = RAM[6]*0.2
# RAM[9] = RAM[9]*0.2

#The AC line from DE-FR is number 5
# RAM[5] = RAM[5]*0.8 # DE-FR

#The AC and DC lines between DK-DE have the number 11 (AC) and index 6,4 (DC) respectively
# RAM[11] = RAM[11]*0.75 # DK-DE_ AC
# NTC[6,5] = floor(NTC[6,5]*0.75) # DK-DE_ DC
# NTC[5,6] = floor(NTC[5,6]*0.75)

#The AC and DC lines between NL-DE have the number 8 (AC) and index 8,3 (DC) respectively
# RAM[8] = RAM[8]*0.8 #NL-DE_ AC
# NTC[8,3] = floor(NTC[8,3]*0.8) #NL-DE_ DC
# NTC[3,8] = floor(NTC[3,8]*0.8) #NL-DE_ DC

#The AC line from NL-BE is number 2
# RAM[2] = RAM[2]*0.75 #NL-BE

#The AC line from DE-PL is number 10
# RAM[10] = RAM[10]*0.9 #DE-PL

# The Hub-to-shore lines
# NTC[11,5] = floor(NTC[11,5]*0.8) # Line from DE to NS2 
# NTC[5,11] = floor(NTC[5,11]*0.8)
# NTC[10,6] = floor(NTC[10,6]*0.8) # Line from DK to NS1
# NTC[6,10] = floor(NTC[6,10]*0.8)
# NTC[12,8] = floor(NTC[12,8]*0.8) # Line from NL to NS3
# NTC[8,12] = floor(NTC[8,12]*0.8)

#Limiting/increasing the NTC between the three OWF's in the North Sea
# NTC[10:12,10:12] = NTC[10:12,10:12].*2

# Marginal costs of onshore and radially connected renewables to simulate negative bids
MC_r[findall(x-> x == 1, ZR)] .= -0.1
MC_r[findall(x-> x == 2, ZR)] .= -0.1
MC_r[findall(x-> x == 3, ZR)] .= -0.1
MC_r[findall(x-> x == 4, ZR)] .= -0.1
MC_r[findall(x-> x == 5, ZR)] .= -0.1
MC_r[findall(x-> x == 6, ZR)] .= -0.1


## Model ##
m = Model(Gurobi.Optimizer)

@variable(m, 0<= v[1:G] <= 1) # Relative production of non-intermittent generator, will be a percentage.  
@variable(m, fl[1:L]) # Flow on AC lines
@variable(m, fh[1:H]) # Flow on DC lines
@variable(m, c[1:R]>=0) # Curtailment of renewables
@variable(m, pFB[1:OnZ]) # Flow-based power flow in/out of zone

# Objective; minimizing the day-ahead generation cost
@objective(m, Min, sum(MC[g]*Qg[g]*v[g] for g=1:G) + sum(MC_r[r]*(PF[r]*Qr[r] - c[r]) for r in 1:R) )


# Limiting curtailment of renewables
@constraint(m, [r=1:R], c[r] <= PF[r]*Qr[r])

# Zonal power balance
@constraint(m, bal[z=1:Z], sum(Qg[g]*v[g] for g in 1:G if ZG[g] == z ) - Qdz[z] + sum(PF[r]*Qr[r] - c[r] for r in 1:R if ZR[r] == z) - sum(fl[l]*Il[l,n] for l=1:L, n=1:OnN if ZN[n] == z) - sum(fh[h]*Ih_1z[h,n] for h=1:H, n=1:N if ZN[n] == z) == 0)

# Defining the flow based power flows
@constraint(m, [z=1:OnZ], pFB[z] ==  sum(fl[l]*Il[l,n] for l=1:L, n=1:OnN if ZN[n] == z))

# Limitation on flow on AC lines
@constraint(m, [l=1:L], -RAM[l] <= sum(ZPTDF[l,z]*pFB[z] for z=1:OnZ) <= RAM[l])

# Limitation on flow on DC lines
@constraint(m, [n1=1:N,n2=2:N], -NTC[n1,n2] <= sum(fh[h]*Ih_2z[h,n1,n2] for h in 1:H) <= NTC[n2,n1]) 

#************************************************************************
# Solve
solution = optimize!(m)
println("Termination status: $(termination_status(m))")
#************************************************************************

# Save results as csv files
include("Saving_results_BaseCase.jl") 


# Solution
if termination_status(m) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(m))")

    for z = 1:Z
        println("------------")
        println("Zone ", z)
        println("Demand in zone: ", Qdz[z])
        for g =1:G
            if ZG[g] == z
                if value(v[g]) > 0
                    println("Generator ", g," with MC ", round(MC[g]; digits=2)," is producing ", round(Qg[g]*value(v[g]); digits=3), " MW, corresponding to ", round(100*value(v[g]); digits=2), "%")
                end
            end
        end
        for r = 1:R
            if ZR[r] == z
                if value(c[r]) > 0 
                    println("Renewable ", r, " is curtailed with ", round(value(c[r]); digits=2), " MW, corresponding to ", round((value(c[r])/Qr[r])*100; digits=2), "%")
                end
            end
        end
    end
    println("Total demand: ", sum(Qdz[z] for z in 1:Z))
    println("Total production: ", sum(Qg[g]*value(v[g]) for g in 1:G) + sum(PF[r]*Qr[r] - value(c[r]) for r in 1:R))
    println("Price in each Zone: ", round.(ZP; digits=2))
else

println("No optimal solution available")

end
