#==============================================================================
#    Fix Pictures to Map
#    Version: 1.1a
#    Author: modern algebra (rmrk.net)
#    Date: July 28, 2011
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This allows you to set the position of a picture by the X and Y position
#   of the map, rather than the screen, so that the picture won't move with you
#   when the screen scrolls. It also has a couple other features, such as 
#   allowing you to set the Z value to show below characters, or below the 
#   tiles to add another parallax (kind of).
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script into its own slot above Main and below Materials in the
#   Script Editor (F11).
#
#    This switch is run by two switches and one variable that you specify. 
#   They are:
#      FPM_SWITCH - This switch toggles the fix pictures feature. When this 
#          switch is ON and a picture is shown, then that picture will be fixed
#          to the map coordinates you specify, not to the screen. This means 
#          that if the screen scrolls, the picture will not scroll with it. It
#          is useful if you want to use a picture as an additional map layer, 
#          or as a parallax. Note that this still sets it to pixels, so if you
#          want a picture to show up at the map coordinates 1, 2, you would set 
#          it to 32, 64. To specify which switch should be used to control this 
#          feature, go to line 46 and change the value to the ID of the switch 
#          you want to use to control this feature.
#      FPM_Z_VARIABLE - This allows you to set the priority of the picture. 
#          When showing a picture, the value of this ariable will determine the 
#          z value of the picture. When the variable with this ID is set to 0, 
#          the pictures are shown at their normal z value. Setting this 
#          variable to 1 will place it below characters but above non-star 
#          tiles. Setting this variable to 2 will draw the picture above all 
#          tiles and characters except for "Above Characters" Events. Setting 
#          it to 3 will put it below all tiles and characters but above the 
#          parallax. Setting it to 4 will put it below everything, including 
#          the parallax. Setting it to any other value directly sets the z of
#          that sprite to that value. To specify which variable controls this 
#          feature, go to line 47 and set FPM_Z_VARIABLE to the ID of the 
#          variable you want to use.
#==============================================================================
FPM_SWITCH = 10         # See line 22
FPM_Z_VARIABLE = 10     # See line 32
#==============================================================================
# ** Game_Picture
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    attr_reader - map_locked
#    aliased method - initialize, show
#==============================================================================

class Game_Picture
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader :map_locked
  attr_reader :fpm_z
  attr_reader :fpm_vp
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Object Initialization
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malg_fixpicmp_initz_6yh3 initialize
  def initialize (number)
    @map_locked = false
    @fpm_vp = false
    malg_fixpicmp_initz_6yh3 (number) # Run Original Method
    @fpm_z = 100 + self.number
  end

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Show Picture
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_fxpm_showpic_2dx4 show
  def show (name, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    ma_fxpm_showpic_2dx4(name, origin, x, y, zoom_x, zoom_y, opacity, blend_type) # Run Original Method
    @map_locked = $game_switches[FPM_SWITCH] 
    @fpm_vp = ($game_variables[FPM_Z_VARIABLE] != 0 && $game_variables[FPM_Z_VARIABLE] <= 300)
    @fpm_z = case $game_variables[FPM_Z_VARIABLE]
    when 0 then 100 + self.number
    when 1 then 0
    when 2 then 199
    when 3 then -50
    when 4 then -150
    else
      @fpm_z = $game_variables[FPM_Z_VARIABLE]
    end
  end
end

#==============================================================================
# ** Sprite_Picture
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new attr_accessor - fpm_vp1, fpm_vp2
#    aliased method - update
#==============================================================================

class Sprite_Picture
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :fpm_vp1
  attr_accessor :fpm_vp2
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Frame Update
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_fpm_updt_oxoy_5tb3 update
  def update ()
    pic_name = @picture_name
    ma_fpm_updt_oxoy_5tb3 # Run Original Method
    if pic_name != @picture_name
      self.viewport = @picture.fpm_vp ? @fpm_vp1 : @fpm_vp2
      @picture_name = pic_name if self.viewport.nil?
      self.ox, self.oy = 0, 0 # Reset OX and OY for new picture
    end
    # Update X position if the picture is fixed to map coordinates
    if @picture.map_locked
      self.ox, self.oy = $game_map.display_x * 32, $game_map.display_y * 32
    end
    self.z = @picture.fpm_z
  end
end

#==============================================================================
# ** Spriteset_Map
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - create_pictures
#==============================================================================

class Spriteset_Map
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Pictures
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malg_fxpix_crtpi_5oq1 create_pictures
  def create_pictures ()
    malg_fxpix_crtpi_5oq1  # Run Original Method
    @picture_sprites.each { |sprite| sprite.fpm_vp1, sprite.fpm_vp2 = @viewport1, @viewport2 }
  end
end