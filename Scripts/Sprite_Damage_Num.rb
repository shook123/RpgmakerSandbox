class Sprite_Damage_Num < Sprite
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    attr_reader   :time_established             # time the last fade tick was applied (frames)
    attr_reader   :time_last_fade_tick          # frame the last fade tick was applied (frames)
    attr_reader   :current_frame                # current frame
    attr_reader   :damage_text                  # current damage number
    
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(Viewport.new)
    create_bitmap
    update_position
    update
    self.visible = false
    @time_established = 0
    @time_last_fade_tick = 0
    @current_frame = 0
  end
  
  #--------------------------------------------------------------------------
  # * Free
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    super
  end
  
  #--------------------------------------------------------------------------
  # * Create Bitmap
  #--------------------------------------------------------------------------
  def create_bitmap
    self.bitmap = Bitmap.new(48, 48)
    self.bitmap.font.size = 16
    self.bitmap.font.color.set(195, 80, 80)
    draw
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update_now
    @current_frame = 0
    @time_last_fade_tick = 0
    @time_established = Graphics.frame_count
    self.bitmap.font.size = 16
    self.bitmap.font.color.set(195, 80, 80)
    draw
    update_position
    self.set_damage_text
  end
  
  #--------------------------------------------------------------------------
  # * Set damage value
  #--------------------------------------------------------------------------
  def set_damage_text
    @damage_text = $game_variables[14]
  end
  
  #--------------------------------------------------------------------------
  # * draw
  #--------------------------------------------------------------------------
  def draw
    self.bitmap.clear
    self.bitmap.draw_text(self.bitmap.rect, @damage_text, 1)
  end
  
  #--------------------------------------------------------------------------
  # * set visible
  #--------------------------------------------------------------------------
  def set_visible
    self.visible = true
  end
  
  #--------------------------------------------------------------------------
  # * set invisible
  #--------------------------------------------------------------------------
  def set_invisible
    self.visible = false
  end

  #--------------------------------------------------------------------------
  # * get info if invisible
  #--------------------------------------------------------------------------
  def is_visible
    return self.visible
  end
  
  #--------------------------------------------------------------------------
  # * Move up and slightl change color every 3 frames
  #--------------------------------------------------------------------------
  def fade
    @current_frame += 1
    if @time_last_fade_tick + 2 < @current_frame then
      @time_last_fade_tick = @current_frame
      self.y -= 2
      self.bitmap.font.color.set(self.bitmap.font.color.red - 4, \
          self.bitmap.font.color.green - 2, self.bitmap.font.color.blue - 2)
      self.draw
    end
      
  end
  
  #--------------------------------------------------------------------------
  # * Initialize Position
  #--------------------------------------------------------------------------
  def update_position
    self.x = $game_player.screen_x - 20
    self.y = $game_player.screen_y - 50
    self.z = 200
  end
end
