# a system is a mapping from a time to a state
# a policy is a mapping from a state to a new state after some time


# my_system = build system(my_policy, my_starting state, how_long)
# my_state = my_system(my_time)

# is_feasible(my_system)

struct funky_state
   value
end

function build_discrete_system(my_policy, my_starting_state, start_time ,how_long)
   (new_state, duration) = my_policy(my_starting_state)
   if how_long <= 0.0
      return [ (new_state,start_time, duration)]
   else
      return vcat([(my_starting_state, start_time ,duration)], build_discrete_system(my_policy,new_state, start_time + duration ,how_long-duration) )
   end
end

function my_policy(my_state)
   if my_state.value == 5
      return (funky_state(0),2.5)
   else
      return (funky_state(my_state.value+1),2.5)
   end
end

struct pasturiser
   status
   time
end

struct plant 
   silo
   bank
end

function my_initial_state()
   plant(200,[pasturiser("OFF",0.0) for i in 1:4])
end

function my_factory_policy(state)
   # do forced transitions
   transitioned_pas = map(transition,state.bank)

   # do chosen transitions
   acted_pas = if production_rate(transitioned_pas) < 100 && state.silo < 200
      turn_on_first_available(tr)
   else
      transitioned_pas
   end

   # add time to the plant
   final_pas = map(x -> add_duration(5.0,x),acted_pas)

   #return new plant state, with new silo level
   plant(silo_level(state.silo, final_pas), final_pas)
end

function production_rate(bank)
   map(bank) do pas
      if (pas.status == "ON") || (pas.status == "BOOTING UP")
         55.0
      else
         0.0
      end
   end |> sum
end

function silo_leve(old,bank)
   old + (production_rate(bank)-100.0)/12.0
end

function boot_up(pasturiser)
   pasturiser("BOOTING UP",0.0)
end

function turn_on(pasturiser)
   pasturiser("ON",0.0)
end

function turn_off(pasturiser)
   pasturiser("OFF",0.0)
end

function clean(pasturiser)
   pasturiser("CLEANING",0.0)
end

function turn_on_first_available(bank)
   turned_on == false
   result = pasturiser[]
   for pas in bank
      if (pas.status != "OFF") || turned_on
         push!(result, pas)
      else
         push!(result,pasturiser("ON",0.0))
      end
   end
   result
end


function transition_from_booting(pasturiser)
   if pasturiser.status == "BOOTING UP" && pasturiser.time >= 60
      pasturiser("ON",0.0)
   else
      pasturiser
   end
end
function transition_from_cleaning(pasturiser)
   if pasturiser.status == "CLEANING" && pasturiser.time >= 180
      pasturiser("OFF",0.0)
   else
      pasturiser
   end
end
function transition_from_on(pasturiser)
   if pasturiser.status == "ON" && pasturiser.time >= 480
      pasturiser("OFF",0.0)
   else
      pasturiser
   end
end

transition = transition_from_booting ∘ transition_from_cleaning ∘ transition_from_on

function add_duration(time,pasturiser)
   pasturiser(pasturiser.status,pasturiser.time + time)
end