# This is a tiny module which simulates policies for a given length of time

module DiscreteSystem

# This function takes a policy (map from state to state), a starting state and a time period and generates a sequence
# of states with their corresponding time stamps

# work by recursion: from the initial state, it evaluates the state with the policy, and then calls itself on the new state
function build_discrete_system(my_policy, my_starting_state, start_time ,how_long)
   (new_state, duration) = my_policy(my_starting_state)
   if how_long <= 0.0
      return [ (new_state,start_time, duration)]
   else
      return vcat([(my_starting_state, start_time ,duration)], build_discrete_system(my_policy,new_state, start_time + duration ,how_long-duration) )
   end
end

export build_discrete_system

end