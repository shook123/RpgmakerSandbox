class Projectile 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader :expire_at             ## time when projectile will be removed (in frames)
  attr_reader :picture_index         ## index in picture array
  attr_reader :target_x              ## x coordinate of target location (pixels)
  attr_reader :target_y              ## y coordinate of target location (pixels)

  def initialize
      @expire_at = 0
      @picture_index = 0
      @target_x = 0
      @target_y = 0
  end
    
  #--------------------------------------------------------------------------
  # * Set index in picture array $game_map.screen.pictures[]
  #--------------------------------------------------------------------------
  def set_picture_index(number)
    @picture_index = number
  end
    
  #--------------------------------------------------------------------------
  # * Show Picture
  #--------------------------------------------------------------------------
  def show_picture(e_index)
    $game_map.screen.pictures[@picture_index].show("cannon_ball", 0, \
      $Enemies[e_index].mapx, $Enemies[e_index].mapy, 100, 100, 255, 0)
  end
    
  #--------------------------------------------------------------------------
  # * Move Picture
  #--------------------------------------------------------------------------
  def move_picture(e_index)
    temp_xy_array = get_target_xy(e_index)
    @target_x = temp_xy_array[0]
    @target_y = temp_xy_array[1]
    $game_map.screen.pictures[@picture_index].move(0, @target_x, @target_y, 100, \
      100, 255, 0, 120) #last parameter is duration in frames
  end  
  
  #--------------------------------------------------------------------------
  # * Clear Picture
  #--------------------------------------------------------------------------
  def clear_picture
    $game_map.screen.pictures[@picture_index].erase
    end
    
  #--------------------------------------------------------------------------
  # * Initialize timeout for projectile
  #--------------------------------------------------------------------------
  def initialize_projectile
    #### expires at now + 2 seconds
    @expire_at = Graphics.frame_count + Graphics.frame_rate * 2
  end
  
  #--------------------------------------------------------------------------
  # * Check for timeout of projectile
  #--------------------------------------------------------------------------
  def check_if_expired
    return Graphics.frame_count > @expire_at
  end
  
  #--------------------------------------------------------------------------
  # * Return first currently not used item in the Projectiles[] array
  #--------------------------------------------------------------------------
  def get_next_free_projectile
    i = 0
    while i < $Projectiles.length 
      if !$Projectiles[i].flying?
        return i
        break
      end
      i += 1 
    end
    
    ### default if all projectiles are up in the air
    p "Too many projectiles, replacing #1"
    return 1
  end
  
  #--------------------------------------------------------------------------
  # * get distance between player and cannonball
  #--------------------------------------------------------------------------
  def get_cannonball_distance
    return Math.hypot($game_player.real_x * 32-\
    $game_map.screen.pictures[@picture_index].x,$game_player.real_y * 32-$game_map.screen.pictures[@picture_index].y)
  end
  
  #--------------------------------------------------------------------------
  # * return true if cannonball is flying (picture is initialized)
  #--------------------------------------------------------------------------
  def flying?
    not $game_map.screen.pictures[@picture_index].name == ""
  end
  
  #--------------------------------------------------------------------------
  # * get target position of projectile when enemy is attacking from range
  #--------------------------------------------------------------------------
  def get_target_xy(e_index)
    ## get x and y distance between player and enemy1
    x_distance = ($game_player.real_x * 32 - $Enemies[e_index].mapx) 
    y_distance = ($game_player.real_y * 32 - $Enemies[e_index].mapy)

    ## calculate weights
    x_weight = x_distance.to_f / (x_distance.to_f.abs + y_distance.to_f.abs)
    y_weight = y_distance.to_f / (x_distance.to_f.abs + y_distance.to_f.abs)
    
    ## scale assuming total distance is 350
    x_distance = x_weight * 350
    y_distance = y_weight * 350
    
    ## return [target_x, target_y] array
    return [$Enemies[e_index].mapx + x_distance, $Enemies[e_index].mapy + y_distance]
  end
  
  #--------------------------------------------------------------------------
  # * check if projectile hits an obstacle
  #--------------------------------------------------------------------------
  def stop_if_not_passable
    ## BUGGED: STOPS IF HITS WATER
    tempx = ($game_map.screen.pictures[@picture_index].x) / 32
    tempy = ($game_map.screen.pictures[@picture_index].y) / 32
    if $game_map.check_passage(tempx.round, tempy.round, 0x0200) || $game_map.check_passage(tempx.round, tempy.round, 0x0400)
      return true
    else
      if $game_map.check_passage(tempx.round, tempy.round, 0x0f) #|| $game_map.check_passage(tempx.round, tempy.round, 0x0800)
          return false
      end
    end
    return true
  end
  
end