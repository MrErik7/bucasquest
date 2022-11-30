require_relative "map_col"
require_relative "inventory"

class Player
    def initialize
      @height = 50
      @width_front = 35
      @width_side = 27
      @width = @width_front

      @x = @y = 0
      @health = 0
      @speed = 2

      # Animation ---
      @player_sheet_up = Gosu::Image.new("src/player/up_player.png")
      @player_sheet_down = Gosu::Image.new("src/player/down_player.png")
      @player_sheet_right = Gosu::Image.new("src/player/right_player.png")
      @player_sheet_left = Gosu::Image.new("src/player/left_player.png")

      @offset_animation_front= 10+@width_front
      @offset_animation_side = 10+@width_side
      
      @animation_span = Array(0..2)
      @last_time_frame_switch = Process.clock_gettime(Process::CLOCK_MONOTONIC) # Reset the timer used to check the delay between animations
      @moving = false
      @current_direction = "none"
      @direction_changed = false
      
      @current_frame = 0
      @animation_time = 0.4 # Animation delay in SECONDS
      @player = @player_sheet_down.subimage 0, 0, @width, @height # Set the start image 
  
      # Initalize the player inventory
      @player_inventory = Inventory.new 
      @player_inventory.__init__() 

      # Animation variables
=begin
      @animation_up_span = Array(0..2)
      @animation_right_span = Array(3..5)
      @animation_down_span = Array(6..8)
      @animation_left_span = Array(9..11)
  
      @animation_up_idle = 12
      @animation_right_idle = 13
      @animation_down_idle = 14
      @animation_left_idle = 15
=end

    end
  
    def warp(x, y)
      @x, @y = x, y
    end
  
    def move_up(map_x, map_y, animate)
      # Check so the player can walk
      if (check_tile_walkable(@x, @y-@speed, @width_front, @height, map_x, map_y))
  
        # Moves the player
        @y -= @speed
  
        # Reassigns the player image to the next frame 
        # Set the width corresponding to the width
        if (animate)
          @width = @width_front
          animation_walk(@player_sheet_up, @offset_animation_front)
        end
      end
  
    end
    
    def move_down(map_x, map_y, animate)
      # Check so the player can walk 
      if (check_tile_walkable(@x, @y+@speed, @width_front, @height, map_x, map_y))
        # Moves the player
        @y += @speed
  
        # Reassigns the player image to the next frame 
        if (animate)
          @width = @width_front
          animation_walk(@player_sheet_down, @offset_animation_front)
        end
      end
    end
  
    def move_left(map_x, map_y, animate)
      # Check so the player can walk 
      if (check_tile_walkable(@x-@speed, @y, @width_side, @height, map_x, map_y))
  
        # Moves the player
        @x -= @speed
  
        # Reassigns the player image to the next frame 
        # Set the width corresponding to the width
        if (animate)
          @width = @width_side
          animation_walk(@player_sheet_left, @offset_animation_side)
        end
      end
  
    end
    
    def move_right(map_x, map_y, animate)
        # Check so the player can walk 
        if (check_tile_walkable(@x+@speed, @y, @width_side, @height, map_x, map_y))
  
        # Moves the player
        @x += @speed
  
        # Reassigns the player image to the next frame 
        # Set the width corresponding to the width
        if (animate)
          @width = @width_side
          animation_walk(@player_sheet_right, @offset_animation_side)
        end
      end
  
    end

    def pos()
      return @x, @y
    end

    def get_inventory()
      return @player_inventory
    end
  
    def animation_walk(animation_sheet, offset)
      # Check which frame to start from
      if (!@moving || @direction_changed) # If the player isnt moving or has changed direction --> assign him to the first frame in his list 
        @current_frame = 0
        @direction_changed = false
      end
  
  
      # Check if its time to switch frame
      if (Process.clock_gettime(Process::CLOCK_MONOTONIC) - @last_time_frame_switch >= @animation_time)
  
        if (@current_frame == (@animation_span[-1].to_i + 1)) # Check if the last frame equals the last number in the animation span
          @current_frame = @animation_span[0].to_i # Then reset the animation
        end
  
        @player = animation_sheet.subimage(@current_frame*offset, 0, @width, @height) # Switch the player frame to the new frame - using the predefined offset multiplied by the current frame
        
        # Keeping track if the player is in motion or not
        @moving = true
  
        # Add to the frame
        @current_frame+=1
  
        # Reset the timer
        @last_time_frame_switch = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end
  
    def set_animation_frame(direction)
      # Check which animation frame
      case direction
  
      when "up"
        animation_sheet = @animation_sheet_up
  
      when "left"
        animation_sheet = @animation_sheet_left
  
      when "down"
        animation_sheet = @animation_sheet_down
  
      when "right"
        animation_sheet = @animation_sheet_right
  
      end
  
      # Check so that if the @moving is to be true --> the current direction the player is travelling in must be equal to those of the key released
      if (@current_direction == direction)
        # Change the variable moving so that the script will know the player is no longer moving
        # But first check so that no other keys are pressed down
        if (!(Gosu.button_down? Gosu::KB_W) && !(Gosu.button_down? Gosu::KB_A) && !(Gosu.button_down? Gosu::KB_S) && !(Gosu.button_down? Gosu::KB_D))
          @moving = false
          
          # Sets the animation frame to one static image
          @player = animation_sheet.subimage(@current_frame*@width + @offset, 0, @width, @height) # Switch the player frame to the new frame - using the predefined offset multiplied by the current frame
  
        end
        @current_direction = direction
      else
        @direction_changed = true
  
      end
  
    end
  
    def draw
      @player.draw @x, @y, 0
      #@font.draw("x:#{@x}\ny:#{@y}", 100, 200, 0)
  
    end
    
end