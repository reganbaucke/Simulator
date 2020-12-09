
# This is a module which defines a Plant, Pasturisers and some basic 
# behaviours useful for describing and simulating plant operating policies

module PlantSimulation

# basic structs
# a pasturiser has a operating mode and time in that state
struct Pasturiser
   mode
   clean_status
   time
end

# a plant is a silo and a bank of pasturiser
struct Plant 
   silo
   bank
end

# constructors for pasturisers
function boot_up(pasturiser)
   Pasturiser("BOOTING UP","DIRTY",0.0)
end
function turn_on(pasturiser)
   Pasturiser("ON","DIRTY",0.0)
end
function turn_off(pasturiser)
   Pasturiser("OFF","DIRTY",0.0)
end
function clean(pasturiser)
   Pasturiser("CLEANING","DIRTY",0.0)
end

# for a given bank of pasturisers, calculate the production_rate
function production_rate(bank)
   map(bank) do pas
      if (pas.mode == "ON") || (pas.mode == "BOOTING UP")
         55.0
      else
         0.0
      end
   end |> sum
end


# calculate a silo a new silo level based on the old one and the
# new production rate
function silo_level(old,bank)
   old + (production_rate(bank)-100.0)/12.0
end

# create a new bank which is the same as the old bank but with the first "off" pasturiser booted up
function turn_on_first_available(bank)
   turned_on = false
   result = Pasturiser[]
   for pas in bank
      if (pas.mode != "OFF") || turned_on || (pas.clean_status == "DIRTY")
         push!(result, pas)
      else
         push!(result,boot_up(pas))
         turned_on = true
      end
   end
   result
end

# create a new bank which is the same as the old bank but with the first dirty and off pasturiser being cleaned
function clean_first_available(bank)
   cleaned = false
   result = Pasturiser[]
   for pas in bank
      if (!cleaned) && (pas.mode == "OFF") && (pas.clean_status == "DIRTY")
         push!(result,Pasturiser("CLEANING","DIRTY",0.0))
      else
         push!(result,pas)
      end
   end
   result
end

# define the forced transition functions, if a pasturiser has been in a certain state 
# for a given amount of time, make the transition to the appropriate state
function transition_from_booting(pasturiser)
   if pasturiser.mode == "BOOTING UP" && pasturiser.time >= 60
      Pasturiser("ON","DIRTY",0.0)
   else
      pasturiser
   end
end
function transition_from_cleaning(pasturiser)
   if pasturiser.mode == "CLEANING" && pasturiser.time >= 180
      Pasturiser("OFF","CLEAN",0.0)
   else
      pasturiser
   end
end
function transition_from_on(pasturiser)
   if pasturiser.mode == "ON" && pasturiser.time >= 420
      Pasturiser("OFF","DIRTY",0.0)
   else
      pasturiser
   end
end
transition = transition_from_booting ∘ transition_from_cleaning ∘ transition_from_on

# Add some running time to pasturisers
function add_duration(time,pasturiser)
   Pasturiser(pasturiser.mode,pasturiser.clean_status,pasturiser.time + time)
end

export Pasturiser, Plant, transition, boot_up, turn_on, clean, production_rate, silo_level, turn_on_first_available, clean_first_available, add_duration

end