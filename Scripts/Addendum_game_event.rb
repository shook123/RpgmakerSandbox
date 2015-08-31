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
  
      if $Enemies != nil then
      
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
      
      ### if this event is an enemy, check variables and switches defined by enemy id
      if temp then     
        c = page.condition
     
        if c.switch1_valid
          ### instead of switch1_id, switches specific to the enemy 
          ### object are evaluated
          
          if c.switch1_id == 41 then ### enemy is active, waiting to be woken
            return false unless $Enemies[i].active
          end
          if c.switch1_id == 21 then ### enemy is alive
            return false unless $Enemies[i].alive && $Enemies[i].initialized
          end
          if c.switch1_id == 61 then ### enemy is dead
            return false unless !$Enemies[i].alive && $Enemies[i].initialized
          end
    
        end
        if c.switch2_valid
          ### switch2 is called "as usual"
          return false unless $game_switches[c.switch2_id]
        end
        if c.variable_valid
          ### instead of variable_id, an enemy object specific AI variables
          ### is evaluated
          
          return false if $Enemies[i].ai < c.variable_value
        end
        return true
      end
    end
    
    
     ### Check if current event is CHEST 
    if $Chests != nil then
      temp = false
      i = 0
      while i < $Chests.length 
        if self.id == $Chests[i].id and $game_map.map_id == $Chests[i].map_id then
          temp = true
          break
        end
        if !$Chests[i].initialized then
          break
        end   
        i += 1
      end
     
     ### if this event is a chest, check variables and switches relevant to chest object
     if temp then
       c = page.condition
       if c.switch1_valid
         if c.switch1_id == 1 then
           ### Chest is initialized (waiting to be opened)
           return false unless $Chests[i].initialized
         end
         if c.switch1_id == 2 then
           ### Chest is open
           return false unless $Chests[i].open
         end
       end
       return true
     end
   end
    
    ### if this event is neither ENEMY nor CHEST, run original method
   return addendum_conditions_met?(page)     
  end
end
