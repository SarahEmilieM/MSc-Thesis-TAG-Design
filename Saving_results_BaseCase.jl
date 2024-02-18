
# ResultsFolder = "C://Users//sigri//Documents//DTU//Master thesis//Julia//Base Case//Results BaseCase"
ResultsFolder = "C://Users//sarah//OneDrive - Danmarks Tekniske Universitet//Msc Thesis//Thesis Model//Results"


### Zonal prices
ZP = JuMP.dual.(bal) # Extracting the result
df_ZP = DataFrame(Zonal_Price = ZP) # Defining the column name
CSV.write(ResultsFolder*"//Zprices.csv", df_ZP) # Making csv file, and define file name


### Prices in nodes
NP = zeros(N)
for n = 1:N
    for z = 1:Z
        if ZN[n] == z
            NP[n] = ZP[z]
        end
    end
end
df_NP = DataFrame(Node_Price = NP) # Defining the column name
CSV.write(ResultsFolder*"//Nprices.csv", df_NP) # Making csv file, and define file name


### AC flows
AC_flow = zeros(L)
for l = 1:L
    AC_flow[l] = sum(ZPTDF[l,z]*value(pFB[z]) for z in 1:OnZ)
end
df_ACf = DataFrame(AC_flow = AC_flow) # Defining the column name
CSV.write(ResultsFolder*"//ACflows.csv", df_ACf) # Making csv file, and define file name

# RAM 
df_RAM = DataFrame(RAM = RAM) # Defining the column name
CSV.write(ResultsFolder*"//RAM.csv", df_RAM) # Making csv file, and define file name


### DC flows
DC_flow_on = zeros(7) # Onshore DC flows
for h = 1:7
    DC_flow_on[h] = value(fh[h])
end

# NTC
CSV.write(ResultsFolder*"//NTC.csv", NTC) # Making csv file, and define file name


### Generator details
# Marginal cost
df_MC = DataFrame(Marginal_cost_generator = dropdims(MC,dims=2))
CSV.write(ResultsFolder*"//MC.csv", df_MC) # Making csv file, and define file name
# Capacity of dispatchable generators
df_Qg = DataFrame(Capacity_generator = Qg)
CSV.write(ResultsFolder*"//Qg.csv", df_Qg) # Making csv file, and define file name
# Renewable capacity
df_Qr = DataFrame(Renewable_capacity = Qr)
CSV.write(ResultsFolder*"//Renewable_capacity.csv", df_Qr) # Making csv file, and define file name


### Offshore wind
# Redistribute offshore curtailment and flows
include("Redistributing_offshore_flows.jl")


# # Generation available 
df_OffGA = DataFrame(Offshore_generation_available = PF[Hub].*Qr[Hub])
CSV.write(ResultsFolder*"//OffGA.csv", df_OffGA)

# Curtailment
df_OffCurt = DataFrame(Offshore_curtailment = c_off) # The redistributed curtailment
CSV.write(ResultsFolder*"//OffCurt.csv", df_OffCurt)

# Save DC flows - with redistributed flows offshore
DC_flow = [DC_flow_on; JuMP.value.(DC_flow_off[1:3])]
df_DCf = DataFrame(DC_flow = DC_flow) # Defining the column name
CSV.write(ResultsFolder*"//DCflows.csv", df_DCf) # Making csv file, and define file name

### Congestion rent
# Saving variables to calculate congestion rent.
# Congestion rent should be price diff between two neighboring zones * the flow between them.
CR_AC = zeros(L)
for l =1:L
    CR_AC[l]= abs(sum(Il[l,n]*NP[n] for n in 1:OnN))*abs(AC_flow[l])
end
CR_DC = zeros(H)
for h =1:H
    CR_DC[h]= abs(sum(Ih_1z[h,n]*NP[n] for n in 1:N))*abs(DC_flow[h])
end

df_CR_AC = DataFrame(Congestion_rent_AC = CR_AC) # Defining the column name
CSV.write(ResultsFolder*"//congestion_rent_AC.csv", df_CR_AC) # Making csv file, and define file name

df_CR_DC = DataFrame(Congestion_rent_DC = CR_DC) # Defining the column name
CSV.write(ResultsFolder*"//congestion_rent_DC.csv", df_CR_DC) # Making csv file, and define file name