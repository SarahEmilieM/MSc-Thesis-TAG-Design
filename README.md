# MSc Thesis: Use of congestion revenues to manage the volume and price risks related to offshore bidding zones in combination with hybrid wind projects

## Background
This model was created in connection with making the MSc Thesis: 
"Use of congestion revenues to manage the volume and price risks related to offshore bidding zones in combination with hybrid wind projects" by Sarah E. C. Magid and Sigrid Winge.
This was done at the Technical University of Denmark(DTU) under the supervision of Lena Kitzing (DTU) and Leonardo Meeus (Florence School of Regulation, a part of the European University Institute). 
The mathematical model equations are based on the paper by Michiel Kenis et. al, 2023: "Off-shore Bidding Zones Under Flow-Based Market Coupling".

The model is simulating hourly snapshots of the transmission system in the Central/Northern European region by 2030. 
The system includes three connected offshore bidding zones in the North Sea connected to Denmark, Germany, and the Netherlands. 
They constitute a total capacity of 17 GW offshore wind energy. 
The day-ahead market is modeled with a linear optimization model incorporating flow-based market coupling. 
Further description of the data and results can be read in our MSc Thesis which will be published at DTU orbit: https://orbit.dtu.dk/en/ 

## How to run the code
Download the four main Julia files as well as the two folders "Data" and "Results" and save them on your computer.
Open the BaseCase.jl file and follow the descriptions given in the comments, such that the code can be run on your computer.
The print statements in the BaseCase.jl file will provide basic information on the scenario results. 
If you furthermore want to visualize the system and TAG payout results, you should use the Matlab files in the Results folder.
