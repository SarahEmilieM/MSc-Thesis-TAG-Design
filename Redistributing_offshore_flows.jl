# Redistributed curtailments offshore
gen_av = PF[Hub].*Qr[Hub]# Generation available for offshore hubs
c_off = zeros(3) 
if NP[10] == NP[11] && NP[10] == NP[12] # If offshore prices are the same
    # If 1/3 off total curtailment is less than generation available for each hub
    if (1/3)*sum(JuMP.value.(c[Hub])) <= gen_av[1] && (1/3)*sum(JuMP.value.(c[Hub])) <= gen_av[2] && (1/3)*sum(JuMP.value.(c[Hub])) <= gen_av[3]
        # Each hub will have 1/3 of the curtailment
        c_off[1] = (1/3)*sum(JuMP.value.(c[Hub]))
        c_off[2] = (1/3)*sum(JuMP.value.(c[Hub]))
        c_off[3] = (1/3)*sum(JuMP.value.(c[Hub]))
    # If gen_av[1] < 1/3 curtailment
    elseif (1/3)*sum(JuMP.value.(c[Hub])) > gen_av[1]
        c_off[1] = gen_av[1]
        if (1/2)*(sum(JuMP.value.(c[Hub]))-gen_av[1]) > gen_av[2]
            c_off[2] = gen_av[2]
            c_off[3] = (sum(JuMP.value.(c[Hub]))-gen_av[1]-gen_av[2])
        elseif (1/2)*(sum(JuMP.value.(c[Hub]))-gen_av[1]) > gen_av[3]
            c_off[2] = (sum(JuMP.value.(c[Hub]))-gen_av[1]-gen_av[3])
            c_off[3] = gen_av[3]
        else
            c_off[2] = (1/2)*(sum(JuMP.value.(c[Hub]))-gen_av[1])
            c_off[3] = (1/2)*(sum(JuMP.value.(c[Hub]))-gen_av[1])
        end
    # If gen_av[2] < 1/3 curtailment
    elseif (1/3)*sum(JuMP.value.(c[Hub])) > gen_av[2]
        c_off[2] = gen_av[2]
        if (1/2)*(sum(JuMP.value.(c[Hub]))-gen_av[2]) > gen_av[1]
            c_off[1] = gen_av[1]
            c_off[3] = (sum(JuMP.value.(c[Hub]))-gen_av[1]-gen_av[2])
        elseif (1/2)*(sum(JuMP.value.(c[Hub]))-gen_av[2]) > gen_av[3]
            c_off[1] = (sum(JuMP.value.(c[Hub]))-gen_av[2]-gen_av[3])
            c_off[3] = gen_av[3]
        else
            c_off[1] = (1/2)*(sum(JuMP.value.(c[Hub]))-gen_av[2])
            c_off[3] = (1/2)*(sum(JuMP.value.(c[Hub]))-gen_av[2])
        end
    # If gen_av[3] < 1/3 curtailment
    elseif (1/3)*sum(JuMP.value.(c[Hub])) > gen_av[3]
        c_off[3] = gen_av[3]
        if (1/2)*(sum(JuMP.value.(c[Hub]))-gen_av[3]) > gen_av[1]
            c_off[1] = gen_av[1]
            c_off[2] = (sum(JuMP.value.(c[Hub]))-gen_av[1]-gen_av[3])
        elseif (1/2)*(sum(JuMP.value.(c[Hub]))-gen_av[3]) > gen_av[2]
            c_off[1] = (sum(JuMP.value.(c[Hub]))-gen_av[2]-gen_av[3])
            c_off[2] = gen_av[2]
        else
            c_off[1] = (1/2)*(sum(JuMP.value.(c[Hub]))-gen_av[3])
            c_off[2] = (1/2)*(sum(JuMP.value.(c[Hub]))-gen_av[3])
        end
    end
elseif NP[10] == NP[11] # If only the price in NS1 and NS2 are the same
    c_off[3] = JuMP.value.(c[Hub[3]])
    if (1/2)*sum(JuMP.value.(c[Hub[1:2]])) > gen_av[1]
        c_off[1] = gen_av[1]
        c_off[2] = sum(JuMP.value.(c[Hub[1:2]])) - gen_av[1]
    elseif (1/2)*sum(JuMP.value.(c[Hub[1:2]])) > gen_av[2]
        c_off[1] = sum(JuMP.value.(c[Hub[1:2]])) - gen_av[2]
        c_off[2] = gen_av[2]
    else
        c_off[1] = (1/2)*sum(JuMP.value.(c[Hub[1:2]]))
        c_off[2] = (1/2)*sum(JuMP.value.(c[Hub[1:2]]))
    end
elseif NP[10] == NP[12] # If only the price in NS1 and NS3 are the same
    c_off[2] = JuMP.value.(c[Hub[2]])
    if (1/2)*(JuMP.value.(c[Hub[1]])+JuMP.value.(c[Hub[3]])) > gen_av[1]
        c_off[1] = gen_av[1]
        c_off[3] = (JuMP.value.(c[Hub[1]])+JuMP.value.(c[Hub[3]])) - gen_av[1]
    elseif (1/2)*(JuMP.value.(c[Hub[1]])+JuMP.value.(c[Hub[3]])) > gen_av[3]
        c_off[1] = (JuMP.value.(c[Hub[1]])+JuMP.value.(c[Hub[3]])) - gen_av[3]
        c_off[3] = gen_av[3]
    else
        c_off[1] = (1/2)*(JuMP.value.(c[Hub[1]])+JuMP.value.(c[Hub[3]]))
        c_off[3] = (1/2)*(JuMP.value.(c[Hub[1]])+JuMP.value.(c[Hub[3]]))
    end
elseif NP[11] == NP[12] # If only NS2 and NS3 has the same price
    c_off[1] = JuMP.value.(c[Hub[1]])
    if (1/2)*sum(JuMP.value.(c[Hub[2:3]])) > gen_av[2]
        c_off[2] = gen_av[2]
        c_off[3] = sum(JuMP.value.(c[Hub[2:3]])) - gen_av[2]
    elseif (1/2)*sum(JuMP.value.(c[Hub[2:3]])) > gen_av[3]
        c_off[2] = sum(JuMP.value.(c[Hub[2:3]])) - gen_av[3]
        c_off[3] = gen_av[3]
    else
        c_off[2] = (1/2)*sum(JuMP.value.(c[Hub[2:3]]))
        c_off[3] = (1/2)*sum(JuMP.value.(c[Hub[2:3]]))
    end
else
    c_off[1] = JuMP.value.(c[Hub[1]])
    c_off[2] = JuMP.value.(c[Hub[2]])
    c_off[3] = JuMP.value.(c[Hub[3]])
end

# Generation from offshore WFs
gen_NS1 = PF[Hub[1]]*Qr[Hub[1]]-value(c_off[1])
gen_NS2 = PF[Hub[2]]*Qr[Hub[2]]-value(c_off[2])
gen_NS3 = PF[Hub[3]]*Qr[Hub[3]]-value(c_off[3])

H_off = 3 # Number of offshore DC lines

# Model to redistribute flows
m_off = Model(Gurobi.Optimizer)

@variable(m_off, DC_flow_off[1:3])
@variable(m_off, DC_flow_off_abs[1:3] >= 0)

@objective(m_off, Min, sum(DC_flow_off_abs[h] for h = 1:H_off))

@constraint(m_off, gen_NS1 - DC_flow_off[1] - DC_flow_off[2] + DC_flow_on[6] == 0)
@constraint(m_off, gen_NS2 + DC_flow_off[1] - DC_flow_off[3] + DC_flow_on[4] == 0)
@constraint(m_off, gen_NS3 + DC_flow_off[2] + DC_flow_off[3] + DC_flow_on[7] == 0)
@constraint(m_off, -NTC[10,11] <= DC_flow_off[1] <= NTC[10,11])
@constraint(m_off, -NTC[10,12] <= DC_flow_off[2] <= NTC[10,12])
@constraint(m_off, -NTC[11,12] <= DC_flow_off[3] <= NTC[11,12])

@constraint(m_off, - DC_flow_off_abs[1] <= DC_flow_off[1])
@constraint(m_off, DC_flow_off[1] <= DC_flow_off_abs[1])
@constraint(m_off, - DC_flow_off_abs[2] <= DC_flow_off[2])
@constraint(m_off, DC_flow_off[2] <= DC_flow_off_abs[2])
@constraint(m_off, - DC_flow_off_abs[3] <= DC_flow_off[3])
@constraint(m_off, DC_flow_off[3] <= DC_flow_off_abs[3])

#************************************************************************
# Solve
solution = optimize!(m_off)
println("Termination status: $(termination_status(m_off))")
#************************************************************************

# OBS: if the above model can't find a solution, it is probably because you have one of the 
# uncommon cases where the redistributed curtailments offshore are not feasible.
# In that case, you will need to manually define the c_off parameters so they are feasible,
# before running the m_off model
