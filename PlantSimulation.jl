
# This is a module which defines a Plant, Pasturisers and some basic 
# behaviours useful for describing and simulating plant operating policies

module PlantSimulation

# basic structs
# a pasturiser has a operating status and time in that state
struct Pasturiser
   status
   time
end

# a plant is a silo and a bank of pasturiser
struct Plant 
   silo
   bank
end

# constructors for pasturisers
function boot_up(pasturiser)
   Pasturiser("BOOTING UP",0.0)
end
function turn_on(pasturiser)
   Pasturiser("ON",0.0)
end
function turn_off(pasturiser)
   Pasturiser("OFF",0.0)
end
function clean(pasturiser)
   Pasturiser("CLEANING",0.0)
end

# for a given bank of pasturisers, calculate the production_rate
function production_rate(bank)
   map(bank) do pas
      if (pas.status == "ON") || (pas.status == "BOOTING UP")
         55.0
      else
         0.0
      end
   end |> sum
end


function silo_level(old,bank)
   old + (production_rate(bank)-100.0)/12.0
end

# create a new bank which is the same as the old bank but with the first "off" pasturiser booted up
function turn_on_first_available(bank)
   turned_on = false
   result = Pasturiser[]
   for pas in bank
      if (pas.status != "OFF") || turned_on
         push!(result, pas)
      else
         push!(result,boot_up(pas))
         turned_on = true
      end
   end
   result
end

# define the forced transition functions, if a pasturiser has been in a certain state 
# for a given amount of time, make the transition to the appropriate state
function transition_from_booting(pasturiser)
   if pasturiser.status == "BOOTING UP" && pasturiser.time >= 60
      Pasturiser("ON",0.0)
   else
      pasturiser
   end
end
function transition_from_cleaning(pasturiser)
   if pasturiser.status == "CLEANING" && pasturiser.time >= 180
      Pasturiser("OFF",0.0)
   else
      pasturiser
   end
end
function transition_from_on(pasturiser)
   if pasturiser.status == "ON" && pasturiser.time >= 420
      Pasturiser("OFF",0.0)
   else
      pasturiser
   end
end
transition = transition_from_booting ∘ transition_from_cleaning ∘ transition_from_on


# Add some running time to pasturisers
function add_duration(time,pasturiser)
   Pasturiser(pasturiser.status,pasturiser.time + time)
end

export Pasturiser, Plant, transition, boot_up, turn_on, clean, production_rate, silo_level, turn_on_first_available, add_duration

end