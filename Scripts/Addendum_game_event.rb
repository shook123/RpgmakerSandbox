#==============================================================================
# ** ADDENDUM TO Game_Event
#------------------------------------------------------------------------------
#  This class runs a different set of conditions if the event is an ENEMY event
#  In that case the index in the $game_switches[] and $game_variables[] arrays 
#  are increased by the index of the enemy in the Enemies[] array.
#  Example: The event of the Enemy Enemies[3] is called. The page conditions are
#  checked. Instead of $game_switch[41] and $game_variables[21], 
#  $game_switch[41+3] and $game_variables[41+3] are evaluated.
#==============================================================================

class Game_Event < Game_Character
  
  alias addendum_conditions_met? conditions_met?
  def conditions_met?(page)
    
     ### run original method if Enemies not initialized
     return addendum_conditions_met?(page) unless $Enemies != nil
      
     ### Check if current event is ENEMY
     temp = false
     i = 0
     while i < $Enemies.length 
       if self.id == $Enemies[i].id then
         temp = true
         break
       end   
       i += 1
     end
     
     ### run original method if this event is NOT an ENEMY
     return addendum_conditions_met?(page) unless temp
    
### if this event is an enemy, check variables and switches defined by enemy id
     c = page.condition
     
     if c.switch1_valid
       return false unless $game_switches[c.switch1_id + i]
     end
     if c.switch2_valid
       ### switch2 is called "as usual"
       return false unless $game_switches[c.switch2_id]
     end
     if c.variable_valid
       return false if $game_variables[c.variable_id + i] < c.variable_value
     end
     return true
   end
   
end
