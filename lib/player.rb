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
      @direction_changed = false
      @current_frame = 0
      @animation_time = 0.4 # Animation delay in SECONDS
      @player = @player_sheet_down.subimage 0, 0, @width, @height # Set the start image 
      @player_walking_up = false
      @up_key_released = true
      @current_direction = "none"

      # -- Fighting --
      @player_strike_sheet_up = Gosu::Image.new("src/player/player_hit_up.png")
      @player_strike_sheet_down = Gosu::Image.new("src/player/player_hit_down.png")
      @player_strike_sheet_right = Gosu::Image.new("src/player/player_hit_right.png")
      @player_strike_sheet_left = Gosu::Image.new("src/player/player_hit_left.png")

      @strike = false
      @striking_current_frame = 0
      @last_time_frame_switch_strike = Process.clock_gettime(Process::CLOCK_MONOTONIC) # Reset the timer used to check the delay between fighting animations
      @animation_time_strike = 1#0.15

      # Initalize the player inventory
      @player_inventory = Inventory.new 
      @player_inventory.__init__() 

      
    end
  
    def warp(x, y)
      @x, @y = x, y
    end
  
    def move_up(map_x, map_y, animate)
      # Check so the player can walk
      if (check_tile_walkable(@x, @y-@speed, @width_front, @height, map_x, map_y))
        # For animating the equipped item
        @player_walking_up = true
        @up_key_released = false

        @current_direction = "up"

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
        # For animating the equipped item
        if (@up_key_released)
          @player_walking_up = false
        end

        @current_direction = "down"

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
        # For animating the equipped item
        if (@up_key_released)
          @player_walking_up = false
        end

        @current_direction = "left"

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
          # For animating the equipped item
          if (@up_key_released)
            @player_walking_up = false
          end

          @current_direction = "right"

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
  
    def reset_animation(dir)
      if (dir == "up")
        @up_key_released = true
      end
      @last_time_frame_switch-=@animation_time # So that the player turns instantly after a button is released
      @direction_changed = true
    end

    def animation_strike(animation_sheet, offset)
      # Check if its time to switch frame
      if (Process.clock_gettime(Process::CLOCK_MONOTONIC) - @last_time_frame_switch_strike >= @animation_time_strike)
        if (@striking_current_frame == (@animation_span[-1].to_i + 1)) # Check if the last frame equals the last number in the animation span
          # Reset all variables for next time the animation runs
          @player = animation_sheet.subimage(2*offset, 0, @width, @height) # Switch the player frame to the new frame - using the predefined offset multiplied by the current frame
          @striking_current_frame = 0 
          @strike = false
        end
  
        @player = animation_sheet.subimage(@striking_current_frame*offset, 0, @width, @height) # Switch the player frame to the new frame - using the predefined offset multiplied by the current frame
          
        # Add to the frame
        @striking_current_frame+=1
  
        # Reset the timer
        @last_time_frame_switch_strike = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end

    
    # This method displays the equipped item
    def display_equipped_item()
      # Check if the player strikes
      # IMPORTANT TO NOTE: IF YOU WERE TO UPGRADE THE ANIMATION IN THE FUTURE YOU NEED TO ADD MORE IF STATEMENTS HERE
      if (@strike)
        if (@striking_current_frame == 0 || @striking_current_frame == 3) # Normal position for hand
          x = @x+@width/2
          y = @y+@height/2

        elsif (@striking_current_frame == 1) # The overhead strike
          if (@current_direction == "left")
            x = @x+@width/2
          else
            x = @x+@width

          end
          y = @y-@height/2

        elsif (@striking_current_frame == 2) # The middle strike
          if (@current_direction == "left")
            x = @x+@width/2-20
          else
            x = @x+@width/2
          end
          y = @y
         
        end

  
      else
          # Set the x and y for the item if the player is not striking. The right and front position have the same. 
          if (@current_direction == "left")
            x = @x+@width/2-10
          else
            x = @x+@width/2
          end

          y = @y+@height/2

      end
      @player_inventory.set_coordinates_item_equipped(x, y)

      # Get the item image
      item = @player_inventory.get_item_equipped
      item_image = @player_inventory.getItemImage(item)

      # Draw it at its location
      if (item != 0)
          item_image.draw(x,y)
      end

  end
    

    def strike()
      @strike = true
    end

    def get_width()
      return @width
    end

    def get_height()
      return @height
    end


  
    def draw
      @player.draw @x, @y, 0
      #@font.draw("x:#{@x}\ny:#{@y}", 100, 200, 0)

      # Check if it exists an item to be equipped and that the player isnt walking up
      if (@player_inventory.get_item_equipped != 0 && !@player_walking_up)
          display_equipped_item()
      end


      if (@strike)
        case @current_direction
        when "up"
          animation_strike(@player_strike_sheet_up, @offset_animation_front)
        when "down"
          animation_strike(@player_strike_sheet_down, @offset_animation_front)
        when "right"
          animation_strike(@player_strike_sheet_right, @offset_animation_side)
        when "left"
          animation_strike(@player_strike_sheet_left, @offset_animation_side)

        end
        
      end
  
    end
    
end