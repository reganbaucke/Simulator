# Load in my libraries
include("DiscreteSystem.jl")
include("PlantSimulation.jl")
using .DiscreteSystem
using .PlantSimulation


# describe initial state, 4 clean and off pasturisers and a silo level of 200
function my_initial_state()
   Plant(200,[Pasturiser("OFF","CLEAN",0.0) for i in 1:4])
end

#
# Define a generic policy (possibly bad) to govern the operations of the plant, this policy has a time resolution of 5 minutes
# 
# This policy has three parts:
#     for all pasturisers, transition them out of their current state if imposed by the rules e.g. if a pasturiser has been in cleaning for 3 hours, move to off state
#     after these pasturisers have made their forced transitions, turn on a pasturiser if the current production rate and silo level are sufficiently low
#     after this change to the bank of pasturisers, add some "running time" to these pasturisers in their new state

function my_factory_policy(plant)
   # do forced transitions
   transitioned_pas = map(transition,plant.bank)

   # turn on a pasturiser if neccesary
   acted_pas = if (production_rate(transitioned_pas) < 100) && (plant.silo < 200)
      turn_on_first_available(transitioned_pas)
   else
      transitioned_pas
   end

   # clean a pasturiser if there is one free
   acted_pas = if (map(x->x.mode != "CLEANING",acted_pas) |> all) 
      clean_first_available(acted_pas)
   else
      acted_pas
   end

   # add time to the plant
   final_pas = map(x -> add_duration(5.0,x),acted_pas)

   #return new plant state, with new silo level, and move forward in time 5 minutes
   (Plant(silo_level(plant.silo, final_pas), final_pas), 5.0)
end


# simulate the plant from its initial state using the above policy for 240 minutes
my_simulation = build_discrete_system(my_factory_policy, my_initial_state(),0.0,240)


# with this my simulation object (just an array of states and times) we would be able to ask certain questions about it
# such as: is it feasible?
#          feasibility_test(my_condition, my_simulation)
# and: how many cleans did we do
#          how_many_cleans(my_simulation)