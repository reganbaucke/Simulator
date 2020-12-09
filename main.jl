# Load in my libraries
include("DiscreteSystem.jl")
include("PlantSimulation.jl")
using .DiscreteSystem
using .PlantSimulation


# describe initial state
function my_initial_state()
   Plant(200,[Pasturiser("OFF",0.0) for i in 1:4])
end

#
# Define a generic policy (possibly bad) to govern the operations of the plant
#
function my_factory_policy(plant)
   # do forced transitions
   transitioned_pas = map(transition,plant.bank)

   # do chosen transitions
   acted_pas = if (production_rate(transitioned_pas) < 100) && (plant.silo < 200)
      turn_on_first_available(transitioned_pas)
   else
      transitioned_pas
   end

   # add time to the plant
   final_pas = map(x -> add_duration(5.0,x),acted_pas)

   #return new plant state, with new silo level
   (Plant(silo_level(plant.silo, final_pas), final_pas), 5.0)
end


# simulate the plant from its initial state using the above policy for 240 minutes
my_simulation = build_discrete_system(my_factory_policy, my_initial_state(),0.0,240)

