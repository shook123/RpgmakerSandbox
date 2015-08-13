class Game_Player
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader :cooldown     #cooldown in frames
  attr_reader :last_attack  #time of last attack in frames

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias addendum_initialize initialize
  def initialize
    @cooldown = Graphics.frame_rate * 3 ### 3 seconds in frames
    addendum_initialize  # Run Original Method
    @last_attack = 0
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
end

