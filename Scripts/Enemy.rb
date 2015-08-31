class Enemy
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader   :id                      # event id
  attr_reader   :hp                      # enemy hp
  attr_reader   :meele_damage            # enemy meele damage
  attr_reader   :range_damage            # enemy range damage
  attr_reader   :alive                   # alive switch
  attr_reader   :cooldown                # enemy cooldown time in frames
  attr_reader   :last_attack             # time last attack was carried out
  attr_reader   :damage_num              # object to display damage numbers if attacked
  attr_reader   :initialized             # Turned on when enemy is started (alive or corpse)
  attr_reader   :index                   # own index in $Enemies array
  attr_reader   :active                  # if enemy is waiting to wake
  attr_reader   :ai                      # ai variable - controls which page
                                         # of the enemy event is running

  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize
    @id = 0 ## event id
    @ai = 0
    @hp = 30
    @meele_damage = 30
    @range_damage = 10
    @last_attack = 0
    @cooldown = 3 * Graphics.frame_rate ### 3 seconds in frames
    @alive = false
    @index = 0
    @active = false
    @damage_taken = 0
    @initialized = false ## this turns true when Enemy is alive or dead
    
  end
  
  #--------------------------------------------------------------------------
  # * Activate enemy
  #--------------------------------------------------------------------------
  def wake ### index is the index of this object in the $Enemies array
    ### if enemy is inactive then activate, if enemy is already active, do nothing
    if !$game_switches[21 + @index] then
      @initialized = true
      @alive = true
      $game_switches[21 + @index] = true
    end
  end
  
   #--------------------------------------------------------------------------
   # * Upon map change refresh Enemy array
   #--------------------------------------------------------------------------  
   def map_change
     i = 0
     while i < $Enemies.length 
       $Enemies[i] = Enemy.new
       $Enemies[i].set_index(i)
       i += 1
    end
   end
   #--------------------------------------------------------------------------
   # * Get next free Enemy object (not alive or dead) in $Enemies array
   #--------------------------------------------------------------------------  
   def get_next_free_enemy(event_id)
     i = 1
     while i < $Enemies.length 
       if !$Enemies[i].active
         $Enemies[i].set_id(event_id)
         $Enemies[i].set_active
         $Enemies[i].set_map_id
         return i
         break
       end
       i += 1 
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get next free Enemy object (not alive or dead) in $Enemies array
  #--------------------------------------------------------------------------  
  def find_enemy_with_id(event_id)
     i = 0
     p event_id
     while i < $Enemies.length
       p $Enemies[i].id
       if $Enemies[i].id == event_id then
         return i
       end
       i += 1
     end
     return nil
   end
  
   #--------------------------------------------------------------------------
   # * refresh all "damage number" sprites (required after menu is shown)
   #--------------------------------------------------------------------------  
   def refresh_damage_numbers
     i = 1
     while i < $Enemies.length 
       if $Enemies[i].initialized
         $Enemies[i].init_damage_num
       end
       i += 1 
     end
   end
   
   #--------------------------------------------------------------------------
   # * Check if at least one enemy is alive
   #--------------------------------------------------------------------------  
   def any_enemy_alive?
     i = 0
     while i < $Enemies.length 
       if $Enemies[i].alive
         return true
         break
      end
      i += 1
    end
    ### if no enemy is alive, return false
     return false
   end
   
  #--------------------------------------------------------------------------
  # * Set this enemies event id
  #--------------------------------------------------------------------------  
  def set_id(parameter)
    @id = parameter
  end
  
  #--------------------------------------------------------------------------
  # * Set this enemies map id
  #--------------------------------------------------------------------------  
  def set_map_id
    @map_id = $game_map.map_id
  end  
  #--------------------------------------------------------------------------
  # * Set this enemies index in $Enemies array
  #--------------------------------------------------------------------------  
  def set_index(parameter)
    @index = parameter
  end
  
  #--------------------------------------------------------------------------
  # * Set this enemies index in $Enemies array
  #--------------------------------------------------------------------------  
  def set_active
    @active = true
  end
  
  #--------------------------------------------------------------------------
  # * Set this enemies behaviour by changing the AI variable
  #--------------------------------------------------------------------------  
  def set_ai(parameter)
    @ai = parameter
  end
  #--------------------------------------------------------------------------
  # * Initialize damage number
  #--------------------------------------------------------------------------  
  def init_damage_num
    @damage_num = Sprite_Damage_Dealt.new(@id)
  end
  
  #--------------------------------------------------------------------------
  # * Enemy takes damage, check if still alive
  #--------------------------------------------------------------------------
  def take_damage(damage)
    @hp -= damage
    @alive = (@hp > 0) ### false if hp is o or smaller
    $game_map.events[@id].animation_id = 7 ### sword animation -> change to dynamic
    @damage_num.set_visible
    @damage_num.set_damage_text(damage)
    @damage_num.update_now
    
    ### if dead, change switches so that enemy events corpse is shown
    if !@alive then
      $game_switches[21+@index] = false
      $game_switches[61+@index] = true
    end
  end
  
  #--------------------------------------------------------------------------
  # * Return true if cooldown is over
  #--------------------------------------------------------------------------
  def off_cooldown?
    return !(@last_attack + @cooldown > Graphics.frame_count)
  end
  
  #--------------------------------------------------------------------------
  # * Start cooldown
  #--------------------------------------------------------------------------
  def reset_cooldown
    @last_attack = Graphics.frame_count
  end
  
  #--------------------------------------------------------------------------
  # * Get map x coordinate in pixels
  #--------------------------------------------------------------------------
  def mapx
    return $game_map.events[@id].real_x * 32
  end
  
  #--------------------------------------------------------------------------
  # * Get map y coordinate in pixels
  #--------------------------------------------------------------------------
  def mapy
    return $game_map.events[@id].real_y * 32
  end
  
  #--------------------------------------------------------------------------
  # * get distance between enemy1 and player
  #--------------------------------------------------------------------------
  def get_distance
    return Math.hypot($game_player.real_x * 32 -\
    self.mapx, $game_player.real_y * 32 - self.mapy)
  end  
  
  #--------------------------------------------------------------------------
  # * check if distance smaller than or equal to parameter
  #--------------------------------------------------------------------------
  def distance_lower_than(parameter)
    return (self.get_distance <= parameter)
  end  
  
  #--------------------------------------------------------------------------
  # * check if distance higher than or equal to parameter
  #--------------------------------------------------------------------------
  def distance_higher_than(parameter)
    return (self.get_distance >= parameter)
  end  
    
  #--------------------------------------------------------------------------
  # * if enemy is within meele range return true
  #--------------------------------------------------------------------------
  def Inrange?
    ## check if enemy is in meele range (ahead of player or ahead and one step left or right)
    ##  d : Direction (2,4,6,8) up left right buttom
    xmax = $game_player.real_x * 32 + 16
    xmin = $game_player.real_x * 32  - 16
    ymax = $game_player.real_y * 32  + 16
    ymin = $game_player.real_y * 32  - 16

    ## set hit range in relation to player facing direction
    if $game_player.direction == 8 then ## facing up
      xmin -= 32
      xmax += 32
      ymin -= 32
      ymax -= 32
    end
    
    if $game_player.direction == 2 then ## facing bottom
      xmin -= 32
      xmax += 32
      ymin += 32
      ymax += 32
    end
    
    if $game_player.direction == 4 then ## facing left
      xmin -= 32
      xmax -= 32
      ymin -= 32
      ymax += 32
    end    
  
    if $game_player.direction == 6 then ## facing right
      xmin += 32
      xmax += 32
      ymin -= 32
      ymax += 32
    end
  
    ## check if enemy is in hit range
    if self.mapx < xmax && self.mapx > xmin && \
      self.mapy < ymax && self.mapy > ymin then
      return true
    else
      return false      
    end
  end

end
